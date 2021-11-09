 

 

pragma solidity ^0.6.0;

 
contract Context {
     
     
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 


pragma solidity ^0.6.0;

 
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

 


pragma solidity ^0.6.0;

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 


pragma solidity ^0.6.2;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 


pragma solidity ^0.6.0;





 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

 


pragma solidity ^0.6.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 


pragma solidity ^0.6.0;



contract Miner is ERC20, Ownable {
    uint8 private constant DECIMALS = 18;

    address private _minter;

    constructor() public ERC20("Miner", "MINER") Ownable() {
         
        _minter = address(0);
        _setupDecimals(DECIMALS);
    }

     
    function setMinter(address minter) public onlyOwner {
        require(minter != address(0), "Miner/zero-address");
        _minter = minter;
    }

     
    function getMinter() public view returns (address) {
        return _minter;
    }

    function mint(uint256 amount) public onlyMinter {
        _mint(_msgSender(), amount);
    }

     
    modifier onlyMinter {
        require(getMinter() == _msgSender(), "Miner/invalid-minter");
        _;
    }
}

 


pragma solidity ^0.6.0;




 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 


pragma solidity ^0.6.0;





enum ProposalType { Mint, Access, Withdrawal }

enum AccessAction { None, Grant, Revoke }

struct Proposal {
    address proposer;
    uint256 expires;
    uint256 signatures;
    bool open;
    ProposalType proposalType;
}

struct Veto {
    address proposer;
    uint256 endorsements;
    bool enforced;
    uint256 proposal;
}

struct MintProposal {
    uint256 amount;
}

struct WithdrawalProposal {
    address recipient;
    uint256 amount;
}

struct AccessProposal {
    address signatory;
    AccessAction action;
}

struct Signatory {
    AccessAction action;
}

contract Treasury is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for Miner;

    Miner private _token;

    uint8 public constant MINIMUM_SIGNATORIES = 3;

    mapping(address => Signatory) public signatories;
    address[] public signatoriesIndex;
    uint256 public grantedCount;

    Proposal[] public proposals;
     
    mapping(uint256 => mapping(address => bool)) public signed;
    mapping(uint256 => address[]) public signatures;

    Veto[] public vetoes;
    mapping(uint256 => bool) public vetoedProposals;
    mapping(uint256 => mapping(address => bool)) public vetoed;
    mapping(uint256 => address[]) public vetoers;

    mapping(uint256 => AccessProposal) public accessProposals;
    mapping(uint256 => MintProposal) public mintProposals;
    mapping(uint256 => WithdrawalProposal) public withdrawalProposals;

    constructor(Miner token) public {
        _token = token;
        _grantSignatory(_msgSender());
    }

    function inSigningPeriod() public view returns (bool) {
        if (proposals.length == 0) {
            return false;
        }

        uint256 i = proposals.length.sub(1);
        return _inSigningPeriod(i);
    }

    function _inSigningPeriod(uint256 i) private view returns (bool) {
        return proposals[i].expires > now;
    }

     
    function proposeMint(uint256 amount)
        external
        onlySignatory()
        noPendingProposals()
        minimumSignatories()
    {
        require(amount > 0, "Treasury/zero-amount");

        mintProposals[proposals.length] = MintProposal(amount);

        _propose(ProposalType.Mint);
    }

     
    function proposeGrant(address signatory)
        external
        onlySignatory()
        noPendingProposals()
    {
        require(signatory != address(0), "Treasury/invalid-address");
        require(
            signatories[signatory].action != AccessAction.Grant,
            "Treasury/access-granted"
        );

        uint256 index = getProposalsCount();

        accessProposals[index] = AccessProposal(signatory, AccessAction.Grant);

        _propose(ProposalType.Access);
    }

     
    function proposeRevoke(address signatory)
        external
        onlySignatory()
        noPendingProposals()
    {
        require(
            grantedCount > MINIMUM_SIGNATORIES,
            "Treasury/minimum-signatories"
        );
        require(signatory != address(0), "Treasury/invalid-address");
        require(
            signatories[signatory].action == AccessAction.Grant,
            "Treasury/no-signatory-or-revoked"
        );

        uint256 index = getProposalsCount();

        accessProposals[index] = AccessProposal(signatory, AccessAction.Revoke);

        _propose(ProposalType.Access);
    }

     
    function proposeWithdrawal(address recipient, uint256 amount)
        external
        onlySignatory()
        noPendingProposals()
        minimumSignatories()
    {
        require(amount > 0, "Treasury/zero-amount");

        withdrawalProposals[proposals.length] = WithdrawalProposal(
            recipient,
            amount
        );

        _propose(ProposalType.Withdrawal);
    }

     
    function vetoProposal()
        external
        onlySignatory()
        minimumSignatories()
        latestProposalPending()
    {
        uint256 totalProposals = getProposalsCount();

        uint256 index = totalProposals.sub(1);

        require(!vetoedProposals[index], "Treasury/veto-pending");

        Veto memory veto = Veto(msg.sender, 0, false, index);

        vetoedProposals[index] = true;
        vetoes.push(veto);

        endorseVeto();
    }

     
    function endorseVeto()
        public
        latestProposalPending()
        onlySignatory()
    {
        uint256 totalVetoes = getVetoCount();

        require(totalVetoes > 0, "Treasury/no-vetoes");

        uint256 index = totalVetoes.sub(1);

        require(
            vetoed[index][msg.sender] != true,
            "Treasury/signatory-already-vetoed"
        );

        Proposal storage vetoedProposal = proposals[vetoes[index].proposal];

        vetoed[index][msg.sender] = true;
        vetoers[index].push(msg.sender);

        vetoes[index].endorsements = vetoes[index].endorsements.add(1);

        if (vetoes[index].endorsements >= getRequiredSignatoryCount()) {
            proposals[vetoes[index].proposal].open = false;
            vetoes[index].enforced = true;

            _revokeSignatory(vetoedProposal.proposer);

            emit Vetoed(index, vetoes[index].proposal);
        }
    }

    function _propose(ProposalType proposalType) private returns (uint256) {
        Proposal memory proposal = Proposal(
            msg.sender,
            now + 48 hours,
            0,
            true,
            proposalType
        );

        proposals.push(proposal);

        sign();
    }

     
    function getSignatoryCount() public view returns (uint256) {
        return signatoriesIndex.length;
    }

     
    function getProposalsCount() public view returns (uint256) {
        return proposals.length;
    }

     
    function getVetoCount() public view returns (uint256) {
        return vetoes.length;
    }

     
    function getSignatures(uint256 proposal)
        external
        view
        returns (address[] memory)
    {
        return signatures[proposal];
    }

     
    function getVetoEndorsements(uint256 veto)
        external
        view
        returns (address[] memory)
    {
        return vetoers[veto];
    }

     
    function sign() public onlySignatory() latestProposalPending() {
        require(proposals.length > 0, "Treasury/no-proposals");
        uint256 index = getProposalsCount().sub(1);

        require(
            signed[index][msg.sender] != true,
            "Treasury/signatory-already-signed"
        );

        signatures[index].push(msg.sender);
        signed[index][msg.sender] = true;
        proposals[index].signatures = proposals[index].signatures.add(1);

        if (proposals[index].signatures >= getRequiredSignatoryCount()) {
            proposals[index].open = false;

            if (proposals[index].proposalType == ProposalType.Mint) {
                _printerGoesBrr(mintProposals[index].amount);
            } else if (
                proposals[index].proposalType == ProposalType.Withdrawal
            ) {
                _withdraw(
                    withdrawalProposals[index].recipient,
                    withdrawalProposals[index].amount
                );
            } else {
                _updateSignatoryAccess();
            }
        }

        emit Signed(index);
    }

    function getRequiredSignatoryCount() public view returns (uint256) {
        return grantedCount.div(2).add(1);
    }

    function _updateSignatoryAccess() private {
        uint256 index = getProposalsCount().sub(1);
         
        address signatory = accessProposals[index].signatory;

        if (accessProposals[index].action == AccessAction.Grant) {
            _grantSignatory(signatory);

            emit AccessGranted(signatory);
        } else {
            _revokeSignatory(signatory);

            emit AccessRevoked(signatory);
        }
    }

    function _grantSignatory(address signatory) private {
         
        if (signatories[signatory].action != AccessAction.Revoke) {
            signatoriesIndex.push(signatory);
        }

        signatories[signatory] = Signatory(AccessAction.Grant);
        grantedCount = grantedCount.add(1);
    }

    function _revokeSignatory(address signatory) private {
        signatories[signatory] = Signatory(AccessAction.Revoke);
        grantedCount = grantedCount.sub(1);
    }

    function _printerGoesBrr(uint256 amount) private {
        _token.mint(amount);

        Minted(amount);
    }

    function _withdraw(address recipient, uint256 amount) private {
        _token.transfer(recipient, amount);

        emit Withdrawn(recipient, amount);
    }

    modifier onlySignatory() {
        require(
            signatories[msg.sender].action == AccessAction.Grant,
            "Treasury/invalid-signatory"
        );
        _;
    }

    modifier latestProposalPending() {
        uint256 totalProposals = getProposalsCount();

        if (totalProposals > 0) {
            uint256 index = totalProposals.sub(1);

            require(
                proposals[index].open && inSigningPeriod(),
                "Treasury/proposal-expired"
            );
        }
        _;
    }

    modifier noPendingProposals() {
        uint256 totalProposals = getProposalsCount();

        if (totalProposals > 0) {
            uint256 index = totalProposals.sub(1);

            require(
                !proposals[index].open || !inSigningPeriod(),
                "Treasury/proposal-pending"
            );
        }
        _;
    }

    modifier minimumSignatories() {
        require(
            grantedCount >= MINIMUM_SIGNATORIES,
            "Treasury/minimum-signatories"
        );
        _;
    }

    event Signed(uint256 index);

    event AccessGranted(address signatory);
    event AccessRevoked(address signatory);

    event Minted(uint256 amount);

    event Withdrawn(address recipient, uint256 amount);

    event Vetoed(uint256 veto, uint256 proposal);
}