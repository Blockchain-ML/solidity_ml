pragma solidity ^0.4.18;

 

 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() public {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

 
 

contract TokenLoot is Ownable {

   
   
  address public neverdieSigner;
   
  ERC20 public sklToken;
   
  ERC20 public xpToken;
   
  ERC20 public goldToken;
   
  ERC20 public silverToken;
   
  ERC20 public scaleToken;
   
  ERC20 public stgToken;
   
  ERC20 public magToken;
   
  ERC20 public dexToken;
   
  ERC20 public luckToken;
   
  mapping (address => uint256) public nonces;


   
  event ReceiveLoot(address indexed sender,
                    uint256 _amountSKL,
                    uint256 _amountXP,
                    uint256 _amountGold,
                    uint256 _amountSilver,
                    uint256 _amountScale,
                    uint256 _nonce);

  event ReceiveDailyLoot(address indexed sender,
                    uint256 _amountSTG,
                    uint256 _amountDEX,
                    uint256 _amountMAG,
                    uint256 _amountLUCK,
                    uint256 _nonce);


   
  function setSKLContractAddress(address _to) public onlyOwner {
    sklToken = ERC20(_to);
  }

  function setXPContractAddress(address _to) public onlyOwner {
    xpToken = ERC20(_to);
  }

  function setGoldContractAddress(address _to) public onlyOwner {
    goldToken = ERC20(_to);
  }

  function setSilverContractAddress(address _to) public onlyOwner {
    silverToken = ERC20(_to);
  }

  function setScaleContractAddress(address _to) public onlyOwner {
    scaleToken = ERC20(_to);
  }

  function setSTGContractAddress(address _to) public onlyOwner {
    stgToken = ERC20(_to);
  }

  function setLUCKContractAddress(address _to) public onlyOwner {
    luckToken = ERC20(_to);
  }

  function setMAGContractAddress(address _to) public onlyOwner {
    magToken = ERC20(_to);
  }

  function setDEXContractAddress(address _to) public onlyOwner {
    dexToken = ERC20(_to);
  }

  function setNeverdieSignerAddress(address _to) public onlyOwner {
    neverdieSigner = _to;
  }

   
   
   
   
   
   
   
  function TokenLoot(address _xpContractAddress,
                     address _sklContractAddress,
                     address _goldContractAddress,
                     address _silverContractAddress,
                     address _scaleContractAddress,
                     address _stgContractAddress,
                     address _dexContractAddress,
                     address _magContractAddress,
                     address _luckContractAddress,
                     address _signer) {
    xpToken = ERC20(_xpContractAddress);
    sklToken = ERC20(_sklContractAddress);
    goldToken = ERC20(_goldContractAddress);
    silverToken = ERC20(_silverContractAddress);
    scaleToken = ERC20(_scaleContractAddress);
    stgToken = ERC20(_stgContractAddress);
    magToken = ERC20(_magContractAddress);
    dexToken = ERC20(_dexContractAddress);
    luckToken = ERC20(_luckContractAddress);
    
    neverdieSigner = _signer;
  }

   
   
   
   
   
   
   
   
   
   
  function receiveTokenLoot(uint256 _amountSKL, 
                            uint256 _amountXP, 
                            uint256 _amountGold, 
                            uint256 _amountSilver,
                            uint256 _amountScale,
                            uint256 _nonce, 
                            uint8 _v, 
                            bytes32 _r, 
                            bytes32 _s) {

     
    require(_nonce > nonces[msg.sender]);
    nonces[msg.sender] = _nonce;

     
    address signer = ecrecover(keccak256(abi.encodePacked(msg.sender, 
                                         _amountSKL, 
                                         _amountXP, 
                                         _amountGold,
                                         _amountSilver,
                                         _amountScale,
                                         _nonce)), _v, _r, _s);
    require(signer == neverdieSigner);

     
    if (_amountSKL > 0) assert(sklToken.transfer(msg.sender, _amountSKL));
    if (_amountXP > 0) assert(xpToken.transfer(msg.sender, _amountXP));
    if (_amountGold > 0) assert(goldToken.transfer(msg.sender, _amountGold));
    if (_amountSilver > 0) assert(silverToken.transfer(msg.sender, _amountSilver));
    if (_amountScale > 0) assert(scaleToken.transfer(msg.sender, _amountScale));

     
    emit ReceiveLoot(msg.sender, 
                     _amountSKL, 
                     _amountXP, 
                     _amountGold, 
                     _amountSilver, 
                     _amountScale, 
                     _nonce);
  }

   
   
   
   
   
   
   
   
   
  function receiveTokenLoot(uint256 _amountSTG,
                            uint256 _amountMAG,
                            uint256 _amountDEX,
                            uint256 _amountLUCK,
                            uint256 _nonce, 
                            uint8 _v, 
                            bytes32 _r, 
                            bytes32 _s) {

     
    require(_nonce > nonces[msg.sender]);
    nonces[msg.sender] = _nonce;

     
    address signer = ecrecover(keccak256(abi.encodePacked(msg.sender, 
                                         _amountSTG,
                                         _amountDEX,
                                         _amountMAG,
                                         _amountLUCK,
                                         _nonce)), _v, _r, _s);
    require(signer == neverdieSigner);

     
    if (_amountSTG > 0) assert(stgToken.transfer(msg.sender, _amountSTG));
    if (_amountMAG > 0) assert(magToken.transfer(msg.sender, _amountMAG));
    if (_amountDEX > 0) assert(dexToken.transfer(msg.sender, _amountDEX));
    if (_amountLUCK > 0) assert(luckToken.transfer(msg.sender, _amountLUCK));

     
    emit ReceiveDailyLoot(msg.sender, 
                          _amountSTG,
                          _amountDEX,
                          _amountMAG,
                          _amountLUCK,
                          _nonce);
  }

   
  function () payable public { 
      revert(); 
  }

   
  function withdraw() public onlyOwner {
    uint256 allSKL = sklToken.balanceOf(this);
    uint256 allXP = xpToken.balanceOf(this);
    uint256 allGold = goldToken.balanceOf(this);
    uint256 allSilver = silverToken.balanceOf(this);
    uint256 allScale = scaleToken.balanceOf(this);
    uint256 allSTG = stgToken.balanceOf(this);
    uint256 allDEX = dexToken.balanceOf(this);
    uint256 allMAG = magToken.balanceOf(this);
    uint256 allLUCK = luckToken.balanceOf(this);
    if (allSKL > 0) sklToken.transfer(msg.sender, allSKL);
    if (allXP > 0) xpToken.transfer(msg.sender, allXP);
    if (allGold > 0) goldToken.transfer(msg.sender, allGold);
    if (allSilver > 0) silverToken.transfer(msg.sender, allSilver);
    if (allScale > 0) scaleToken.transfer(msg.sender, allScale);
    if (allSTG > 0) stgToken.transfer(msg.sender, allSTG);
    if (allDEX > 0) dexToken.transfer(msg.sender, allDEX);
    if (allMAG > 0) magToken.transfer(msg.sender, allMAG);
    if (allLUCK > 0) luckToken.transfer(msg.sender, allLUCK);
  }

   
  function kill() onlyOwner public {
    withdraw();
    selfdestruct(owner);
  }

}