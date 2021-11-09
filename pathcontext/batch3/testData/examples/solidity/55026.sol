pragma solidity ^0.4.24;

contract owned {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() public {
        owner = msg.sender;
    }


     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

 
contract game is owned{

    using SafeMath for uint256;
    using Math for uint256;

     
    Spaceship[] spaceships;
     
    Player[] players;
     
    mapping(address => uint256) addressMPid;
    mapping(uint256 => address) pidXAddress;
    mapping(string => uint256) nameXPid;
     
    uint256 playerCount;
     
    uint256 totalTicketCount;
     
    uint256 airdropPrizePool;
     
    uint256 moonPrizePool;
     
    uint256 lotteryTime;
     
    uint256 editPlayerNamePrice = 0.01 ether;
     
    uint256 spaceshipPrice = 0.01 ether;
     
    uint256 addSpaceshipPrice = 0.00000001 ether;
     
    address maxAirDropAddress;
     
    uint256 maxTotalTicket;
     
    uint256 round;
     
    uint256 totalDividendEarnings;
     
    uint256 totalEarnings;






     
    struct Spaceship {
         
        uint256 id;
         
        string name;
         
        uint256 speed;
         
        address captain;
         
        uint256 ticketCount;
         
        uint256 dividendRatio;
         
        uint256 spaceshipPrice;
         
        uint256 addSpeed;
    }
     
    struct Player {
         
        address addr;
         
        string name;
         
        uint256 earnings;
         
        uint256 ticketCount;
         
        uint256 dividendRatio;
         
        uint256 distributionEarnings;
         
        uint256 dividendEarnings;
         
        uint256 withdrawalAmount;
         
        uint256 parentId;
         
        uint256 dlTicketCount;
        uint256 xzTicketCount;
        uint256 jcTicketCount;
    }

    constructor() public {
         
         
        lotteryTime = now + 12 hours;
        round = 1;

         
        spaceships.push(Spaceship(0,"dalao",100000,msg.sender,0,20,10 ether,2));
         
        spaceships.push(Spaceship(1,"xiaozhuang",100000,msg.sender,0,50,10 ether,5));
         
        spaceships.push(Spaceship(2,"jiucai",100000,msg.sender,0,80,10 ether,8));

         
        uint256 playerArrayIndex = players.push(Player(msg.sender,"system",0,0,3,0,0,0,0,0,0,0));
        addressMPid[msg.sender] = playerArrayIndex;
        pidXAddress[playerArrayIndex] = msg.sender;
        playerCount = players.length;
        nameXPid["system"] = playerArrayIndex;
    }

     
    function getSpaceship(uint256 _spaceshipId) public view returns(
        uint256 _id,
        string _name,
        uint256 _speed,
        address _captain,
        uint256 _ticketCount,
        uint256 _dividendRatio,
        uint256 _spaceshipPrice
    ){
        _id = spaceships[_spaceshipId].id;
        _name = spaceships[_spaceshipId].name;
        _speed = spaceships[_spaceshipId].speed;
        _captain = spaceships[_spaceshipId].captain;
        _ticketCount = spaceships[_spaceshipId].ticketCount;
        _dividendRatio = spaceships[_spaceshipId].dividendRatio;
        _spaceshipPrice = spaceships[_spaceshipId].spaceshipPrice;
    }
     
    function getNowTime() public view returns(uint256){
        return now;
    }

     
    function checkName(string _name) public view returns(bool){
        if(nameXPid[_name] == 0 ){
            return false;
        }
        return true;
    }

     
    function setName(string _name) external payable {
        require(msg.value >= editPlayerNamePrice);
         
        if(addressMPid[msg.sender] == 0){
             
            uint256 playerArrayIndex = players.push(Player(msg.sender,_name,0,0,0,0,0,0,0,0,0,0));
            addressMPid[msg.sender] = playerArrayIndex;
            pidXAddress[playerArrayIndex] = msg.sender;
            playerCount = players.length;
            nameXPid[_name] = playerArrayIndex;
        }else{
            uint256 _pid = addressMPid[msg.sender];
            Player storage _p = players[_pid.sub(1)];
            _p.name = _name;
            nameXPid[_name] = _pid;

        }
    }
     
    function checkTicket(uint256 _ticketCount,uint256 _money) private view returns(bool){
        uint256 _tmpMoney = spaceshipPrice.mul(_ticketCount);
        uint256 _tmpMoney2 = addSpaceshipPrice.mul(_ticketCount.sub(1));
        if(_money >= _tmpMoney.add(_tmpMoney2)){
            return true;
        }
        return false;

    }

     
    function checkNewPlayer(address _player) private {
         
        if(addressMPid[_player] == 0){ 
             
            uint256 playerArrayIndex = players.push(Player(_player,"",0,0,0,0,0,0,0,0,0,0));
            addressMPid[_player] = playerArrayIndex;
            pidXAddress[playerArrayIndex] = _player;
            playerCount = players.length;
        }
    }

     
    function addTicket(uint256 _ticketCount,uint256 _spaceshipNo,uint256 _pid) private {
         
        spaceshipPrice = spaceshipPrice.add(addSpaceshipPrice.mul(_ticketCount));

         
        totalTicketCount = totalTicketCount.add(_ticketCount);
        Player storage _p = players[_pid.sub(1)];
        _p.ticketCount = _p.ticketCount.add(_ticketCount);
        if(_spaceshipNo == 0){ 
            _p.dlTicketCount = _p.dlTicketCount.add(_ticketCount);
            Spaceship storage _s =  spaceships[0];
            _s.ticketCount = _s.ticketCount.add(_ticketCount);
            _s.speed = _s.speed.add(_ticketCount.mul(_s.addSpeed));

        }
        if(_spaceshipNo == 1){ 
            _p.xzTicketCount = _p.xzTicketCount.add(_ticketCount);
            Spaceship storage _s1 =  spaceships[1];
            _s1.ticketCount = _s1.ticketCount.add(_ticketCount);
            _s1.speed = _s1.speed.add(_ticketCount.mul(_s1.addSpeed));
        }
        if(_spaceshipNo == 2){ 
            _p.jcTicketCount = _p.jcTicketCount.add(_ticketCount);
            Spaceship storage _s2 =  spaceships[2];
            _s2.ticketCount = _s2.ticketCount.add(_ticketCount);
            _s2.speed = _s2.speed.add(_ticketCount.mul(_s2.addSpeed));
        }
    }

     
    function buyTicket(uint256 _ticketCount,uint256 _spaceshipNo,string _name) external payable{
        require(_spaceshipNo ==0 || _spaceshipNo ==1 || _spaceshipNo == 2);
         
        require(checkTicket(_ticketCount,msg.value)); 
        checkNewPlayer(msg.sender);
         
        totalEarnings = totalEarnings.add(msg.value);

        Player storage _p = players[addressMPid[msg.sender].sub(1)];
         
        if(_p.parentId == 0 && nameXPid[_name] != 0 ){
             
            _p.parentId = nameXPid[_name];
        }

         
        addTicket(_ticketCount,_spaceshipNo,addressMPid[msg.sender]);


         
        addSpaceshipMoney(msg.value.div(100).mul(1));

         
        Player storage _player = players[0];
        uint256 _SysMoney = msg.value.div(100).mul(5);
        _player.earnings = _player.earnings.add(_SysMoney); 
        _player.dividendEarnings = _player.dividendEarnings.add(_SysMoney); 


         
         
        uint256 _distributionMoney = msg.value.div(100).mul(10);
        if(_p.parentId == 0 ){
             
            _player.earnings = _player.earnings.add(_distributionMoney); 
            _player.distributionEarnings = _player.distributionEarnings.add(_distributionMoney);
        }else{
             
            Player storage _player_ = players[_p.parentId.sub(1)];
            _player_.earnings = _player_.earnings.add(_distributionMoney); 
            _player_.distributionEarnings = _player_.distributionEarnings.add(_distributionMoney);
        }
         
        if(_ticketCount > maxTotalTicket){
            maxTotalTicket = _ticketCount;
            maxAirDropAddress = msg.sender;
        }

         
        uint256 _airDropMoney = msg.value.div(100).mul(2);
        airdropPrizePool = airdropPrizePool.add(_airDropMoney);
        if(airdropPrizePool >= 1 ether){
             
             
            Player storage _playerAirdrop = players[addressMPid[maxAirDropAddress].sub(1)];
            _playerAirdrop.earnings = _playerAirdrop.earnings.add(airdropPrizePool); 
            _playerAirdrop.dividendEarnings = _playerAirdrop.dividendEarnings.add(airdropPrizePool); 
        }

        uint256 _remainderMoney = msg.value.sub((msg.value.div(100).mul(1)).mul(3)).sub(_SysMoney).
            sub(_distributionMoney).sub(_airDropMoney);

         
        updateGameMoney(_remainderMoney,_spaceshipNo,_ticketCount,addressMPid[msg.sender].sub(1));




    }

     
    function getFhMoney(uint256 _spaceshipNo,uint256 _money,uint256 _ticketCount,uint256 _targetNo) private view returns(uint256){
        Spaceship memory _fc =  spaceships[_spaceshipNo];
         
        if(_spaceshipNo == _targetNo){
            uint256 _Ticket = _fc.ticketCount.sub(_ticketCount);
            if(_Ticket == 0){
                return 0;
            }
            return _money.div(_Ticket);
        }else{
            if(_fc.ticketCount == 0){
                return 0;
            }
            return _money.div(_fc.ticketCount);
        }
    }

     
    function updateGameMoney(uint256 _money,uint256 _spaceshipNo,uint256 _ticketCount,uint256 arrayPid) private {
        uint256 _lastMoney = addMoonPrizePool(_money,_spaceshipNo);
        uint256 _dlMoney = _lastMoney.div(100).mul(53);
        uint256 _xzMoney = _lastMoney.div(100).mul(33);
        uint256 _jcMoney = _lastMoney.sub(_dlMoney).sub(_xzMoney);
         
        uint256 _dlFMoney = getFhMoney(0,_dlMoney,_ticketCount,_spaceshipNo);
         
        uint256 _xzFMoney = getFhMoney(1,_xzMoney,_ticketCount,_spaceshipNo);
         
        uint256 _jcFMoney = getFhMoney(2,_jcMoney,_ticketCount,_spaceshipNo);
        for(uint i = 0; i<players.length; i++){
            if(arrayPid != i){
                 
                Player storage _tmpP = players[i];
                 
                _tmpP.earnings =  _tmpP.earnings.add(_tmpP.dlTicketCount.mul(_dlFMoney));
                _tmpP.dividendEarnings = _tmpP.dividendEarnings.add(_tmpP.dlTicketCount.mul(_dlFMoney));
                 
                _tmpP.earnings =  _tmpP.earnings.add(_tmpP.xzTicketCount.mul(_xzFMoney));
                _tmpP.dividendEarnings = _tmpP.dividendEarnings.add(_tmpP.dlTicketCount.mul(_dlFMoney));
                 
                _tmpP.earnings =  _tmpP.earnings.add(_tmpP.jcTicketCount.mul(_jcFMoney));
                _tmpP.dividendEarnings = _tmpP.dividendEarnings.add(_tmpP.dlTicketCount.mul(_dlFMoney));
            }
        }

    }
     
    function addMoonPrizePool(uint256 _money,uint256 _spaceshipNo) private returns(uint){
        uint256 _tmpMoney;
        if(_spaceshipNo == 0 ){  
             
            _tmpMoney = _money.div(100).mul(80);
            totalDividendEarnings = totalDividendEarnings.add((_money.sub(_tmpMoney)));
        }
        if(_spaceshipNo == 1 ){  
             
            _tmpMoney = _money.div(100).mul(50);
            totalDividendEarnings = totalDividendEarnings.add((_money.sub(_tmpMoney)));
        }
        if(_spaceshipNo == 2 ){  
             
            _tmpMoney = _money.div(100).mul(20);
            totalDividendEarnings = totalDividendEarnings.add((_money.sub(_tmpMoney)));
        }
        moonPrizePool = moonPrizePool.add(_tmpMoney);
        return _money.sub(_tmpMoney);
    }



      
     function addSpaceshipMoney(uint256 _money) internal {
         
        Spaceship storage _spaceship0 = spaceships[0];
        uint256 _pid0 = addressMPid[_spaceship0.captain];
        Player storage _player0 = players[_pid0.sub(1)];
        _player0.earnings = _player0.earnings.add(_money); 
        _player0.dividendEarnings = _player0.dividendEarnings.add(_money); 


          
         Spaceship storage _spaceship1 = spaceships[1];
         uint256 _pid1 = addressMPid[_spaceship1.captain];
         Player storage _player1 = players[_pid1.sub(1)];
         _player1.earnings = _player1.earnings.add(_money); 
         _player1.dividendEarnings = _player1.dividendEarnings.add(_money); 



          
         Spaceship storage _spaceship2 = spaceships[2];
         uint256 _pid2 = addressMPid[_spaceship2.captain];
         Player storage _player2 = players[_pid2.sub(1)];
         _player2.earnings = _player2.earnings.add(_money); 
         _player2.dividendEarnings = _player2.dividendEarnings.add(_money); 


    }

     
    function getPlayerInfo(address _playerAddress) public view returns(
        address _addr,
        string _name,
        uint256 _earnings,
        uint256 _ticketCount,
        uint256 _dividendEarnings,
        uint256 _distributionEarnings,
        uint256 _dlTicketCount,
        uint256 _xzTicketCount,
        uint256 _jcTicketCount
    ){
        uint256 _pid = addressMPid[_playerAddress];
        Player storage _player = players[_pid.sub(1)];
        _addr = _player.addr;
        _name = _player.name;
        _earnings = _player.earnings;
        _ticketCount = _player.ticketCount;
        _dividendEarnings = _player.dividendEarnings;
        _distributionEarnings = _player.distributionEarnings;
        _dlTicketCount = _player.dlTicketCount;
        _xzTicketCount = _player.xzTicketCount;
        _jcTicketCount = _player.jcTicketCount;
    }

     
    function addSystemUserEarnings(uint256 _money) private {
        Player storage _player =  players[0];
        _player.earnings = _player.earnings.add(_money);
    }

     
    function withdraw(uint256 _money) public {
        require(addressMPid[msg.sender] != 0);
        Player storage _player = players[addressMPid[msg.sender].sub(1)];
        require(_player.earnings >= _money);
        _player.addr.transfer(_money);
        _player.earnings = _player.earnings.sub(_money);
    }

     
    function getGameInfo()public view returns(
        uint256 _totalTicketCount,
        uint256 _airdropPrizePool,
        uint256 _moonPrizePool,
        uint256 _lotteryTime,
        uint256 _nowTime,
        uint256 _spaceshipPrice,
        uint256 _round,
        uint256 _totalEarnings,
        uint256 _totalDividendEarnings
    ){
        _totalTicketCount = totalTicketCount;
        _airdropPrizePool = airdropPrizePool;
        _moonPrizePool = moonPrizePool;
        _lotteryTime = lotteryTime;
        _nowTime = now;
        _spaceshipPrice = spaceshipPrice;
        _round = round;
        _totalEarnings = totalEarnings;
        _totalDividendEarnings = totalDividendEarnings;
    }

     
    function _updateSpaceshipPrice(uint256 _spaceshipId) internal {
        spaceships[_spaceshipId].spaceshipPrice = spaceships[_spaceshipId].spaceshipPrice.add(
        spaceships[_spaceshipId].spaceshipPrice.mul(3).div(10));
    }

     
    function campaignCaptain(uint _spaceshipId) external payable {
        require(msg.value == spaceships[_spaceshipId].spaceshipPrice);
         
        if(addressMPid[msg.sender] == 0){ 
             
            uint256 playerArrayIndex = players.push(Player(msg.sender,"",0,0,0,0,0,0,0,0,0,0));
            addressMPid[msg.sender] = playerArrayIndex;
            pidXAddress[playerArrayIndex] = msg.sender;
            playerCount = players.length;
        }
         
        spaceships[_spaceshipId].captain.transfer(msg.value);
        spaceships[_spaceshipId].captain = msg.sender;
         
        _updateSpaceshipPrice(_spaceshipId);
    }
}





 
library SafeMath {

     
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
         
         
         
        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

     
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
         
         
         
        return _a / _b;
    }

     
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

     
    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}


 
library Math {
    function max(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a >= _b ? _a : _b;
    }

    function min(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a < _b ? _a : _b;
    }
}