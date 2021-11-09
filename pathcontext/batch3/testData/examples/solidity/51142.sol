 

pragma solidity ^0.4.24;


 
contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

     
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

     
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


 
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


     
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

     
    modifier whenPaused() {
        require(paused);
        _;
    }

     
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

     
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}


 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);  
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


 
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
        external returns (bool);

    function transferFrom(address from, address to, uint256 value)
        external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


 
contract ViviCoinDistributor is Pausable {
    using SafeMath for uint256;


     

     
    IERC20 public viviCoin;


     

     
    uint256 private _fee;

     
    mapping(address => uint256) private _tokenBalances;


     

     
    constructor(
        address tokenAddress,
        uint256 fee
    )
        public
    {
        _setToken(tokenAddress);
        _fee = fee;
    }


     

     
    function setToken(address tokenAddress)
        external
        onlyOwner
    {
        _setToken(tokenAddress);
    }

     
    function setFee(uint256 newFee)
        external
        onlyOwner
    {
        _fee = newFee;
    }

     
    function getTokensBack(uint256 amount)
        external
        onlyOwner
    {
        require(amount <= totalTokensOfThisContract(), "not enough tokens on this contract");
        require(viviCoin.transfer(owner, amount), "tokens are not transferred");
    }

     
    function withdrawEth()
        external
        onlyOwner
    {
         
        _forwardFunds(owner, address(this).balance);
    }

     
    function increaseBeneficiaryBalance(
        address beneficiary,
        uint256 amount
    )
        external
        onlyOwner
    {
        _increaseBalance(beneficiary, amount);
    }

     
    function increaseArrayOfBeneficiariesBalances(
        address[] beneficiaries,
        uint256[] amounts
    )
        external
        onlyOwner
    {
        require(beneficiaries.length == amounts.length, "array lengths have to be equal");
        require(beneficiaries.length > 0, "array lengths have to be greater than zero");

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            _increaseBalance(beneficiaries[i], amounts[i]);
        }
    }

     
    function decreaseBeneficiaryBalance(
        address beneficiary,
        uint256 amount
    )
        external
        onlyOwner
    {
        _decreaseBalance(beneficiary, amount);
    }

     
    function decreaseArrayOfBeneficiariesBalances(
        address[] beneficiaries,
        uint256[] amounts
    )
        external
        onlyOwner
    {
        require(beneficiaries.length == amounts.length, "array lengths have to be equal");
        require(beneficiaries.length > 0, "array lengths have to be greater than zero");

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            _decreaseBalance(beneficiaries[i], amounts[i]);
        }
    }


     

     
     
    function withdrawTokens()
        external
        payable
        whenNotPaused
    {
         
        require(msg.value >= _fee, "insufficient funds for withdrawal fee");

        uint256 amount = _tokenBalances[msg.sender];
        require(amount > 0, "no tokens for withdrawal");

         
        _tokenBalances[msg.sender] = 0;

        require(viviCoin.transfer(msg.sender, amount), "tokens are not transferred");
    }


     

     
    function totalTokensOfThisContract()
        public
        view
        returns(uint256)
    {
        return viviCoin.balanceOf(this);
    }

     
    function tokenBalanceOf(address beneficiary)
        public
        view
        returns (uint256)
    {
        return _tokenBalances[beneficiary];
    }

     
    function getActualFee()
        public
        view
        returns(uint256)
    {
        return _fee;
    }


     

     
    function _setToken(address tokenAddress)
        internal
    {
        viviCoin = IERC20(tokenAddress);
        require(totalTokensOfThisContract() >= 0, "The token being added is not ERC20 token");
    }

     
    function _forwardFunds(
        address wallet,
        uint256 amount
    )
        internal
    {
        wallet.transfer(amount);
    }

     
    function _increaseBalance(
        address beneficiary,
        uint256 amount
    )
        internal
    {
        require(beneficiary != address(0), "Address cannot be 0x0");
        require(amount > 0, "Amount cannot be zero");

          
        _tokenBalances[beneficiary] = _tokenBalances[beneficiary].add(amount);
    }

     
    function _decreaseBalance(
        address beneficiary,
        uint256 amount
    )
        internal
    {
        require(beneficiary != address(0), "Address cannot be 0x0");
        require(amount > 0, "Amount cannot be zero");

          
        _tokenBalances[beneficiary] = _tokenBalances[beneficiary].sub(amount);
    }
}