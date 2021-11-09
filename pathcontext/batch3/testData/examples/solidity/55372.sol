pragma solidity ^0.4.24;

 

contract ERC20 {

  function totalSupply() public view returns (uint256);



  function balanceOf(address who) public view returns (uint256);



  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);



  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}

 

library SafeMath {



   

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

     

     

     

    if (a == 0) {

      return 0;

    }



    c = a * b;

    assert(c / a == b);

    return c;

  }



   

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

     

     

     

    return a / b;

  }



   

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



   

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}

 

  

contract Torbucks is ERC20 {
  using SafeMath for uint256;

   
   
  string public constant name = "Torbuck";  
  string public constant symbol = "TOR";  
  uint8 public constant decimals = 2;  
  uint256 public constant INITIAL_SUPPLY = 1000000 * (10 ** uint256(decimals));


   
  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  struct account{
      string alias;
      bool isManager;
      bool isSet;
      address next;
  }
  mapping (address => account) wallets;

   
  uint256 totalSupply_;
  address owner;
  address walletListHead;


   
  constructor() public {
    owner = msg.sender;
    totalSupply_ = INITIAL_SUPPLY;
    balances[address(this)] = INITIAL_SUPPLY;
    wallets[address(this)].isSet = true;
    wallets[address(this)].alias = "Torbuck Piggybank";
    wallets[address(this)].next = address(0);
    walletListHead = address(this);
    emit Transfer(address(0), address(this), INITIAL_SUPPLY);
  }

   
  modifier onlyOwner(){
      require(msg.sender == owner);
      _;
  }
  modifier onlyManager(){
      require(wallets[msg.sender].isManager);
      _;
  }
  modifier onlyManagerOrOwner(){
      require(wallets[msg.sender].isManager || msg.sender == owner);
      _;
  }

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_to == address(this));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _address) public view returns (uint256) {
    return balances[_address];
  }

   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(wallets[msg.sender].isManager);
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    require(wallets[_spender].isManager);
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function getHeadWalletList() public view returns (address){
      return walletListHead;
  }

  function getWallet(address index) public view returns (string _alias, address _next, bool _isManager, bool _isSet, uint256 _balance){
      _alias = wallets[index].alias;
      _next = wallets[index].next;
      _isManager = wallets[index].isManager;
      _isSet = wallets[index].isSet;
      _balance = balances[index];
  }

   

  function vaultToWallet(address _to, uint256 _value) public onlyManager returns (bool){
      require(wallets[_to].isSet);
      if(balances[address(this)] >= _value){
          balances[address(this)] = balances[address(this)].sub(_value);
          balances[_to] = balances[_to].add(_value);
          emit Transfer(address(this), _to, _value);
          return true;
      }
      return false;
  }

  function walletToVault(address _from, uint256 _value) public onlyManager returns (bool){
      require(wallets[_from].isSet);
      if(balances[_from] >= _value){
          balances[_from] = balances[_from].sub(_value);
          balances[address(this)] = balances[address(this)].add(_value);
          emit Transfer(_from, address(this), _value);
          return true;
      }
      return false;
  }

  function emptyWallet(address _wallet) public onlyManager returns (bool) {
      require(wallets[_wallet].isSet);
      require(balances[_wallet] > 0);
      uint256 _value = balances[_wallet];
      balances[_wallet] = balances[_wallet].sub(_value);
      balances[address(this)] = balances[address(this)].add(_value);
      emit Transfer(_wallet, address(this), _value);
  }

  function managerSelfRemove() public onlyManager returns (bool) {
      wallets[msg.sender].isManager = false;
      return true;
  }

  function removeWallet(address _wallet) public onlyManager returns (bool) {
      require(wallets[_wallet].isSet);
      require(balances[_wallet] == 0);
      wallets[_wallet].isSet = false;
      return true;
  }

   
   function addWallet(address _newWallet, string _alias) public onlyManagerOrOwner returns (bool){
       require(wallets[_newWallet].isSet != true);
       wallets[_newWallet].alias = _alias;
       wallets[_newWallet].isManager = false;
       wallets[_newWallet].isSet = true;

        
       if (wallets[_newWallet].next != address(0)){return true;}

        
       wallets[_newWallet].next = walletListHead;
       walletListHead = _newWallet;
       return true;
   }

   

   
  function addManager(address _manager) public onlyOwner returns (bool) {
        require(wallets[_manager].isSet);
        require(wallets[_manager].isManager == false);
        wallets[_manager].isManager = true;
        return true;
  }

   
  function removeManager(address _manager) public onlyOwner returns (bool){
      require(wallets[_manager].isSet);
      require(wallets[_manager].isManager);
      wallets[_manager].isManager = false;
      return true;
  }

   
  function kill() public onlyOwner {
      selfdestruct(owner);
   }

   
   

}