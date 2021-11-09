pragma solidity ^0.5.17;

 
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

interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function mint(address account, uint256 amount) external;

     
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

 

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

         
         
         
        bytes32 codehash;

            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }

     
    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

         
        (bool success, ) = recipient.call.value(amount)("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

 

pragma solidity ^0.5.0;

 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
         
         
         
         
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

     
    function callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
             
             
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract VampTokenSale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address public collector = 0x3F86ceCDe92902173C88554C27720c846Ea18248;
    string public name = "VAMP Presale";

    IERC20 public VAMP = IERC20(0xeFe8AfF127Df9e1ea70233EDE4E04fcF0652d475);
    address public beneficiary;

    uint256 public hardCap;
    uint256 public softCap;
    uint256 public tokensPerUSDT;
    uint256 public purchaseLimitStageOne = 500 * 1e6;
    uint256 public purchaseLimitStageTwo = 2000 * 1e6;
    uint256 public purchaseLimitStageThree = 10000 * 1e6;

    uint256 public tokensSold = 0;
    uint256 public usdtRaised = 0;
    uint256 public investorCount = 0;
    uint256 public weiRefunded = 0;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public stageOne = 2 hours;
    uint256 public stageTwo = 4 hours;
    uint256 public timeHardCapReached;

    bool public softCapReached = false;
    bool public crowdsaleFinished = false;
    
    mapping(address => uint256) sold;
    mapping(address => uint256) whitelistAmount;
    mapping(address => bool) whitelistedAddress;
    mapping(address => uint256) tokensAlreadyBought;

    event GoalReached(uint256 amountRaised);
    event HardCapReached(uint256 hardcap);
    event NewContribution(
        address indexed holder,
        uint256 tokenAmount,
        uint256 etherAmount
    );
    event Refunded(address indexed holder, uint256 amount);

    modifier onlyAfter(uint256 time) {
        require(now >= time);
        _;
    }

    modifier onlyBefore(uint256 time) {
        require(now <= time);
        _;
    }

      modifier claimEnabled() {
        require(block.timestamp.add(1 hours) >= timeHardCapReached);
        _;
    }

    constructor (  
        uint256 _startTime  
        
    ) public {
        hardCap = 550000 * 1e6;
        tokensPerUSDT = 10000000000000;
        startTime = _startTime;
        endTime = _startTime + 48 hours;
        timeHardCapReached = endTime;
        
    }

    function() payable external {
        revert("not purchased by eth");
         
    }
    function canClaim() public view returns (bool){
         if(block.timestamp.add(1 hours) >= timeHardCapReached){
             return true;
         } else {
             return false;
         }
    }

   
    
    function addWhiteListedAddresses(address[] memory _addresses) public onlyOwner {
        require(_addresses.length > 0);
        for (uint i = 0; i < _addresses.length; i++) {
         whitelistedAddress[_addresses[i]] = true;
    }
    }
    
    function isWhitelisted(address _address) public view returns (bool) {
        if(whitelistedAddress[_address]) {
            return true;
        } else {
            return false;
        }
    }
    function simulatebuy(uint256 amount) public view returns (uint256) {
          uint256 tokens = amount * tokensPerUSDT;
          return tokens;
    }
    
    function tokensBought(address _address) public view returns (uint256) {
        return tokensAlreadyBought[_address];
    }
    
    function tokensAlreadySold() public view returns (uint256) {
        return tokensSold;
    }
    
    function raisedUSDT() public view returns (uint256) {
        return usdtRaised;
    }
    function usdtDeposited(address _address) public view returns (uint256) {
        return whitelistAmount[_address].add(sold[_address]);
    }
    
    function getStage() public view returns (uint256) {
         if (block.timestamp <= startTime.add(stageOne)) {
             return 1;
         } else if(block.timestamp >= startTime.add(stageOne) &&
            block.timestamp <= startTime.add(stageTwo)) {
                return 2;
            } else {
                return 3;
            }
    }
    

    function withdrawTokens() public onlyOwner onlyAfter(timeHardCapReached) {
        VAMP.safeTransfer(collector, VAMP.balanceOf(address(this)));
    }

    function claimTokens() public claimEnabled() {
        if(isWhitelisted(msg.sender)){
            if(whitelistAmount[msg.sender] > 0) {
            VAMP.safeTransfer(msg.sender, whitelistAmount[msg.sender]);
            whitelistAmount[msg.sender] = 0;
            } 
            }  
        
        if(sold[msg.sender] > 0){
        VAMP.safeTransfer(msg.sender, sold[msg.sender]);
        sold[msg.sender] = 0;
        }
       
    }

    function purchase(uint256 amount) public {
      doPurchase(amount);
    }
     function doPurchase(uint256 amount)
        private
        onlyAfter(startTime)
        onlyBefore(endTime)
    {
        assert(crowdsaleFinished == false);

        require(usdtRaised.add(amount) <= hardCap,"cant deposit without triggering hardcap");
        if (block.timestamp <= startTime.add(stageOne) && isWhitelisted(msg.sender)) {
             
            uint256 tokens = amount * tokensPerUSDT;
            require(
                amount <= purchaseLimitStageOne,
                "Over purchase limit in stage one"
            );
            require(
                whitelistAmount[msg.sender].add(amount) <= purchaseLimitStageOne,
                "can't purchase more than allowed amount stage one"
            );
            usdt.safeTransferFrom(msg.sender, collector, amount);
            whitelistAmount[msg.sender] = whitelistAmount[msg.sender].add(
                amount
            );
            usdtRaised = usdtRaised.add(amount);
            tokensSold = tokensSold.add(tokens);
            tokensAlreadyBought[msg.sender] = tokens;
        } else if (
            block.timestamp >= startTime.add(stageOne) &&
            block.timestamp <= startTime.add(stageTwo)
        ) {
             

            uint256 tokens = amount * tokensPerUSDT;
            require(
                amount <= purchaseLimitStageTwo,
                "Over purchase limit in stage two"
            );
            require(
                sold[msg.sender].add(amount) <=
                    purchaseLimitStageTwo,
                "can't purchase more than allowed amount stage two"
            );

            usdt.safeTransferFrom(msg.sender, collector, amount);
            sold[msg.sender] = sold[msg.sender].add(
                amount
            );
            usdtRaised = usdtRaised.add(amount);
            sold[msg.sender] += tokens;
            tokensSold = tokensSold.add(tokens);
            tokensAlreadyBought[msg.sender] = tokens;
        } else if (block.timestamp > startTime.add(stageTwo)) {
             
             require(
                amount <= purchaseLimitStageThree,
                "Over purchase limit in stage three"
            );
               require(
                sold[msg.sender].add(amount) <=
                    purchaseLimitStageThree,
                "can't purchase more than allowed amount stage three"
            );
            uint256 tokens = amount * tokensPerUSDT;
            usdt.safeTransferFrom(msg.sender, collector, amount);
            usdtRaised = usdtRaised.add(amount);
            sold[msg.sender] += tokens;
            tokensSold = tokensSold.add(tokens);
            tokensAlreadyBought[msg.sender] = tokens;
        }
         if (usdtRaised == hardCap) {
          timeHardCapReached = block.timestamp;
          crowdsaleFinished = true;
          emit HardCapReached(timeHardCapReached);
        }

    }
}