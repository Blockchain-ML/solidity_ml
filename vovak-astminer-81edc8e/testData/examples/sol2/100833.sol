 

pragma solidity ^0.5.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.5.0;

library SafeBitMath {

    function safe64(uint n, string memory errorMessage) internal pure returns (uint64) {
        require(n < 2 ** 64, errorMessage);
        return uint64(n);
    }

    function safe128(uint n, string memory errorMessage) internal pure returns (uint128) {
        require(n < 2 ** 128, errorMessage);
        return uint128(n);
    }

    function add128(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub128(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {
        require(b <= a, errorMessage);
        return a - b;
    }

}

 

pragma solidity ^0.5.13;

library EvmUtil {

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

}

 

pragma solidity ^0.5.13;
pragma experimental ABIEncoderV2;




 
contract DMGToken is IERC20 {

    string public constant name = "DMM: Governance";

    string public constant symbol = "DMG";

    uint8 public constant decimals = 18;

    uint public totalSupply;

     
    mapping(address => mapping(address => uint128)) internal allowances;

     
    mapping(address => uint128) internal balances;

     
    mapping(address => address) public delegates;

     
    struct Checkpoint {
        uint64 fromBlock;
        uint128 votes;
    }

     
    mapping(address => mapping(uint64 => Checkpoint)) public checkpoints;

     
    mapping(address => uint64) public numCheckpoints;

    bytes32 public domainSeparator;

     
    bytes32 public constant DOMAIN_TYPE_HASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

     
    bytes32 public constant DELEGATION_TYPE_HASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

     
    bytes32 public constant TRANSFER_TYPE_HASH = keccak256("Transfer(address recipient,uint256 rawAmount,uint256 nonce,uint256 expiry)");

     
    bytes32 public constant APPROVE_TYPE_HASH = keccak256("Approve(address spender,uint256 rawAmount,uint256 nonce,uint256 expiry)");

     
    mapping(address => uint) public nonces;

     
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

     
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

     
    constructor(address account) public {
         
        totalSupply = 250000000e18;
        require(totalSupply == uint128(totalSupply), "DMG: total supply exceeds 128 bits");

        domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPE_HASH, keccak256(bytes(name)), EvmUtil.getChainId(), address(this))
        );

        balances[account] = uint128(totalSupply);
        emit Transfer(address(0), account, totalSupply);
    }

     
    function allowance(address account, address spender) external view returns (uint) {
        return allowances[account][spender];
    }

     
    function approve(address spender, uint rawAmount) external returns (bool) {
        uint128 amount;
        if (rawAmount == uint(- 1)) {
            amount = uint128(- 1);
        } else {
            amount = SafeBitMath.safe128(rawAmount, "DMG::approve: amount exceeds 128 bits");
        }

        _approveTokens(msg.sender, spender, amount);
        return true;
    }

     
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }

     
    function transfer(address dst, uint rawAmount) external returns (bool) {
        uint128 amount = SafeBitMath.safe128(rawAmount, "DMG::transfer: amount exceeds 128 bits");
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

     
    function burn(uint rawAmount) external returns (bool) {
        uint128 amount = SafeBitMath.safe128(rawAmount, "DMG::burn: amount exceeds 128 bits");
        _burnTokens(msg.sender, amount);
        return true;
    }

     
    function transferFrom(address src, address dst, uint rawAmount) external returns (bool) {
        address spender = msg.sender;
        uint128 spenderAllowance = allowances[src][spender];
        uint128 amount = SafeBitMath.safe128(rawAmount, "DMG::allowances: amount exceeds 128 bits");

        if (spender != src && spenderAllowance != uint128(- 1)) {
            uint128 newAllowance = SafeBitMath.sub128(spenderAllowance, amount, "DMG::transferFrom: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

     
    function delegate(address delegatee) public {
        return _delegate(msg.sender, delegatee);
    }

    function nonceOf(address signer) public view returns (uint) {
        return nonces[signer];
    }

     
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPE_HASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "DMG::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "DMG::delegateBySig: invalid nonce");
        require(now <= expiry, "DMG::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

     
    function transferBySig(address recipient, uint rawAmount, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 structHash = keccak256(abi.encode(TRANSFER_TYPE_HASH, recipient, rawAmount, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "DMG::transferBySig: invalid signature");
        require(nonce == nonces[signatory]++, "DMG::transferBySig: invalid nonce");
        require(now <= expiry, "DMG::transferBySig: signature expired");

        uint128 amount = SafeBitMath.safe128(rawAmount, "DMG::transferBySig: amount exceeds 128 bits");
        return _transferTokens(signatory, recipient, amount);
    }

     
    function approveBySig(address spender, uint rawAmount, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 structHash = keccak256(abi.encode(APPROVE_TYPE_HASH, spender, rawAmount, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "DMG::approveBySig: invalid signature");
        require(nonce == nonces[signatory]++, "DMG::approveBySig: invalid nonce");
        require(now <= expiry, "DMG::approveBySig: signature expired");

        uint128 amount;
        if (rawAmount == uint(- 1)) {
            amount = uint128(- 1);
        } else {
            amount = SafeBitMath.safe128(rawAmount, "DMG::approveBySig: amount exceeds 128 bits");
        }
        _approveTokens(signatory, spender, amount);
    }

     
    function getCurrentVotes(address account) external view returns (uint128) {
        uint64 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

     
    function getPriorVotes(address account, uint blockNumber) public view returns (uint128) {
        require(blockNumber < block.number, "DMG::getPriorVotes: not yet determined");

        uint64 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

         
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

         
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint64 lower = 0;
        uint64 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint64 center = upper - (upper - lower) / 2;
             
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint128 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _transferTokens(address src, address dst, uint128 amount) internal {
        require(src != address(0), "DMG::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "DMG::_transferTokens: cannot transfer to the zero address");

        balances[src] = SafeBitMath.sub128(balances[src], amount, "DMG::_transferTokens: transfer amount exceeds balance");
        balances[dst] = SafeBitMath.add128(balances[dst], amount, "DMG::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);

        _moveDelegates(delegates[src], delegates[dst], amount);
    }

    function _approveTokens(address owner, address spender, uint128 amount) internal {
        allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _burnTokens(address src, uint128 amount) internal {
        require(src != address(0), "DMG::_burnTokens: cannot burn from the zero address");

        balances[src] = SafeBitMath.sub128(balances[src], amount, "DMG::_burnTokens: burn amount exceeds balance");
        emit Transfer(src, address(0), amount);

        totalSupply = SafeBitMath.sub128(uint128(totalSupply), amount, "DMG::_burnTokens: burn amount exceeds total supply");

        _moveDelegates(delegates[src], address(0), amount);
    }

    function _moveDelegates(address srcRep, address dstRep, uint128 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint64 srcRepNum = numCheckpoints[srcRep];
                uint128 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint128 srcRepNew = SafeBitMath.sub128(srcRepOld, amount, "DMG::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint64 dstRepNum = numCheckpoints[dstRep];
                uint128 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint128 dstRepNew = SafeBitMath.add128(dstRepOld, amount, "DMG::_moveVotes: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint64 nCheckpoints, uint128 oldVotes, uint128 newVotes) internal {
        uint64 blockNumber = SafeBitMath.safe64(block.number, "DMG::_writeCheckpoint: block number exceeds 64 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

}