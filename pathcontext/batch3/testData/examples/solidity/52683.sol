pragma solidity ^0.4.24;

 

 
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

 

library NameFilter {
   
  function nameFilter(string _input) internal pure returns (bytes32) {
    bytes memory _name = bytes(_input);
    require(_name.length <= 32 && _name.length > 0, "Name must be between 1 and 32 characters!");
    require(_name[0] != 0x20 && _name[_name.length-1] != 0x20, "Name cannot start neither end with spaces!");
    if (_name[0] == 0x30) {
      require(_name[1] != 0x78, "Name cannot start with 0x");
      require(_name[1] != 0x58, "Name cannot start with 0X");
    }
    bool _hasAlphaChar = false;
    byte c;
    for (uint8 i = 0; i < _name.length; ++i) {
      c = _name[i];
       
       
      if ((c > 0x40 && c < 0x5b) || (c > 0x60 && c < 0x7b)) {
        if (_hasAlphaChar == false) _hasAlphaChar = true;
      } else {
         
        require (c == 0x20 || (c > 0x2f && c < 0x3a),
          "Name contains invalid characters. Other than A-Z, a-z, 0-9, and space."
        );
         
        if (c == 0x20 && i < (_name.length-2)) require( _name[i+1] != 0x20, "Name cannot contain consecutive spaces");
      }
    }
    require(_hasAlphaChar == true, "Name cannot be only numbers");
    bytes32 _ret;
    assembly {  
        _ret := mload(add(_name, 32))
    }
    return (_ret);
  }
}

 

library DataSets {

  struct Rocket {
    uint8 accuracy;  
    uint8 merit;  
    uint8 knockback;  
    uint256 cost;  
    uint256 launches;  
    uint8 discount;  
  }

  struct Discount {
    bool valid;  
    uint256 duration;  
    uint256 qty;  
    uint256 cost;  
    uint8 next;  
  }

  struct Launchpad {
     
    uint256 size;  
  }

  struct PrizeDist {
    uint8 hero;  
    uint8 bounty;  
    uint8 next;  
    uint8 partners;  
    uint8 moraspace;  
  }

  struct Round {
    bool over;  
    uint256 started;  
    uint256 duration;  
    uint256 mayImpactAt;  
    uint256 merit;  
    uint256 jackpot;  
    uint256 bounty;  
    address hero;  
    uint8 launchpad;  
  }

  struct Player {
    uint16 round;  
    address addr;  
    uint32[] merit;  
    uint256 earnings;  
    uint256 updated;  
  }

  struct Hero {
    address addr;
    bytes32 name;
  }
}

 

 
contract Owned {
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner, "Only owner can do that!");
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    require(msg.sender == newOwner, "Only new owner can do that!");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}

 
contract MoraspaceDefense is Owned {
  using SafeMath for *;  
  using NameFilter for string;
  uint256 public pot = 0;
  DataSets.PrizeDist public prizeDist;
  mapping (uint8 => DataSets.Rocket) public rocketClass;
  mapping (uint8 => DataSets.Rocket) public rocketSupply;
  uint8 public rocketClasses;
  mapping (uint8 => DataSets.Discount) public discount;
  uint8 public discounts;
  mapping (uint8 => DataSets.Launchpad) public launchpad;
  uint8 public launchpads;
  mapping (uint16 => DataSets.Hero) public hero;
  mapping (uint16 => DataSets.Round) public round;
  uint16 public rounds;
  uint32[] public merit;
  mapping (uint256 => DataSets.Player) public player;
  address[] public playerDict;

  event potWithdraw(uint256 indexed _eth, address indexed _to);
  event roundStart(uint16 indexed _round, uint256 indexed _started, uint256 indexed _mayImpactAt);
  event roundFinish(uint16 indexed _round, uint256 indexed _jackpot, address indexed _hero);
  event rocketLaunch(uint8 indexed _hits, uint256 indexed _mayImpactAt);
  event roundHero(uint16 indexed _round, bytes32 indexed _name);

   
  modifier onlyBeforeARound {
    require(round[rounds].over == true, "Sorry the round has begun!");
    _;
  }

   
  modifier beforeNotTooLate {
    require(round[rounds].mayImpactAt > now, "Sorry it is too late!");
    _;
  }

   
  modifier onlyLiveRound {
    require(round[rounds].over == false, "Sorry the new round has not started yet!");
    _;
  }

   
  modifier isHuman(address _addr) {
    uint256 _codeSize;
    assembly {_codeSize := extcodesize(_addr)}
    require(_codeSize == 0, "Sorry humans only!");
    _;
  }

   
  constructor() public {
    round[0].over       = true;
    rounds              = 0;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
    playerDict.push(address(0));
  }

   
  function prepareLaunchpad (
    uint8 _i,
    uint256 _size  
  ) external onlyOwner() onlyBeforeARound() {
    require(_i > 0  && _i <= launchpads + 1, "Index must be grater than 0 and lesser than number of items +1 !");
    require(!(_size == 0 && _i != launchpads), "You can remove only the last item.");
    launchpad[_i].size = _size;
    if (_size == 0) --launchpads;
    else if (_i == launchpads + 1) ++launchpads;
  }

   
  function adjustRocket(
    uint8 _i,
    uint8 _accuracy,  
    uint8 _merit,
    uint8 _knockback,
    uint256 _cost,
    uint8 _discount  
  ) external onlyOwner() onlyBeforeARound() {
    require(_i > 0  && _i <= rocketClasses + 1, "Index must be grater than 0 and lesser than number of items +1 !");
    require(!(_accuracy == 0 && _i != rocketClasses), "You can remove only the last item!");
    require(_accuracy <= 100, "Maxumum accuracy is 100!");
    require(!(_discount > 0 && (_discount > discounts || !discount[_discount].valid)),
      "The linked discount must exists and need to be valid");
    rocketClass[_i].accuracy  = _accuracy;
    rocketClass[_i].merit     = _merit;
    rocketClass[_i].knockback = _knockback;
    rocketClass[_i].cost      = _cost;
    rocketClass[_i].discount  = _discount;
    if (_accuracy == 0) --rocketClasses;
    else if (_i == rocketClasses + 1) ++rocketClasses;
  }

   
  function prepareDiscount (
    uint8 _i,
    bool _valid,  
    uint256 _duration,
    uint256 _qty,
    uint256 _cost,
    uint8 _nextDiscount  
  ) external onlyOwner() onlyBeforeARound() {
    require(_i > 0  && _i <= discounts + 1, "Index must be grater than 0 and lesser than number of items +1 !");
    require(!(_valid == false && _i != discounts), "You can remove only the last item!");
    require(!(_nextDiscount > 0 && !discount[_nextDiscount].valid), "Invalid next discount!");
    discount[_i].valid    = _valid;
    discount[_i].duration = _duration;
    discount[_i].qty      = _qty;
    discount[_i].cost     = _cost;
    discount[_i].next     = _nextDiscount;
    if (_valid == false) --discounts;
    else if (_i == discounts + 1) ++discounts;
  }

   
  function updatePrizeDist(
    uint8 _hero,
    uint8 _bounty,
    uint8 _next,
    uint8 _partners,
    uint8 _moraspace
  ) external onlyOwner() onlyBeforeARound() {
    require(_hero + _bounty + _next + _partners + _moraspace == 100,
      "O.o The sum of pie char should be around 100!");
    prizeDist.hero      = _hero;
    prizeDist.bounty    = _bounty;
    prizeDist.next      = _next;
    prizeDist.partners  = _partners;
    prizeDist.moraspace = _moraspace;
  }

   
  function () external payable {
    require(msg.value > 0, "The payment must be more than 0!");
    pot = pot.add(msg.value);
  }

   
  function potWithdrawTo(uint256 _eth, address _to) external onlyOwner() onlyBeforeARound() {
    require(_eth > 0, "The requested amount need to be explicit!");
    require(_eth <= pot, "Insufficient found!");
    require(_to != address(0), "Address can not be zero!");
    emit potWithdraw(_eth, _to);
    pot = pot.sub(_eth);
    _to.transfer(_eth);
  }

   
  function start(uint256 _duration) external onlyOwner() onlyBeforeARound() {
    require(prizeDist.hero + prizeDist.bounty + prizeDist.next + prizeDist.partners + prizeDist.moraspace == 100,
      "O.o The sum of pie char should be around 100!");
    require(rocketClasses > 0, "No rockets in the game!");
    require(launchpads > 0, "No launchpads in the game!");
     
    for (uint8 i = 0; i <= rocketClasses; ++i) {
      rocketSupply[i] = rocketClass[i];
    }
    ++rounds;
    round[rounds].over      = false;
    round[rounds].duration  = _duration;
    round[rounds].started   = now;
    round[rounds].mayImpactAt = now.add(_duration);
    for (i = 0; i < launchpads; ++i) {
      if (i >= merit.length) merit.push(0);
      else merit[i]=0;
    }
    emit roundStart(rounds, round[rounds].started, round[rounds].mayImpactAt);
  }

  function getPlayerMerits(address _addr, uint256 _index) public view returns (uint32[]) {
    require(address(0) != _addr && _index < playerDict.length, "Player not found!");
    _index = findPlayerIndex(_addr, _index);
    require(_index > 0, "Player not found!");
    return player[_index].merit;
  }

  function findPlayerIndex(address _addr, uint256 _index) public view returns (uint256) {
    require(address(0) != _addr && _index < playerDict.length, "Player not found!");
    require(!(_index > 0 && _addr != playerDict[_index]), "Forbidden!");
    if (_index == 0) {
      for (uint i = 0; i < playerDict.length; i++) {
        if (playerDict[i]==_addr) {
          _index = i;
          break;
        }
      }
    }
    return _index;
  }

  function maintainPlayer(address _addr, uint256 _index) internal returns (uint256) {
    require(address(0) != _addr && _index < playerDict.length, "Player not found!");
    require(!(_index > 0 && _addr != playerDict[_index]), "Forbidden!");
    if (_index == 0) {
      _index = findPlayerIndex(_addr, _index);
      if (_index == 0) {
        player[_index] = DataSets.Player(0, address(0), new uint32[](0), 0, 0);
        _index = playerDict.push(_addr) - 1;
      }
    }
    DataSets.Player storage _p = player[_index];
    if (_p.updated == 0) {  
      _p.addr = _addr;
      _p.round = rounds;
      _p.updated = now;
      for (uint256 i = 0; i < launchpads; ++i) {
        _p.merit.push(0);
      }
    } else if (_p.round != rounds || round[rounds].over) {
       
      DataSets.Round storage _r = round[_p.round];
      if (_p.merit[_r.launchpad-1] > 0) {
        _p.earnings = _p.merit[_r.launchpad-1].mul(_r.bounty);
      }
      for (i = 0; i < _p.merit.length; i++) {
        _p.merit[i] = 0;
      }
      for (i = _p.merit.length; i < launchpads; i++) {
        _p.merit.push(0);
      }
      _p.round   = rounds;
      _p.updated = now;
    }
    return _index;
  }

  function consumeDiscount(uint8 _rocket, uint8 _amount) internal returns (uint256) {
    require(_rocket <= rocketClasses, "Undefined rocket!");
    DataSets.Rocket storage _r = rocketSupply[_rocket];
    uint256 _cost = _r.cost;
    if (_r.discount > 0) {  
      DataSets.Discount storage _exp = discount[_r.discount];
      if (_exp.duration > 0 && now > round[rounds].started.add(_exp.duration)) {
        _exp.valid = false;
        _r.discount = _exp.next;
      }
    }
    if (_r.discount > 0) {
      DataSets.Discount storage _d = discount[_r.discount];
      _cost = _d.cost;
      if (_d.qty > 0) {
        if (_d.qty <= _amount) {
          _d.valid = false;
          _r.discount = _d.next;
        } else {
          _d.qty = _d.qty.sub(_amount);
        }
      }
    }
    return _cost.mul(_amount);
  }

   
  function getRandom(uint8 _maxRan, uint256 _salt) public view returns(uint8) {
      uint256 _genNum = uint256(keccak256(abi.encodePacked(blockhash(block.number-1), _salt)));
      return uint8(_genNum % _maxRan);
  }

   
  function launchRocket (
    uint8 _rocket,
    uint8 _amount,
    uint8 _launchpad,
    uint256 _player  
  ) external payable onlyLiveRound() isHuman(msg.sender) returns(uint8 _hits) {
    require(round[rounds].mayImpactAt > now, "Sorry it is too late!");
    require(_launchpad > 0 && _launchpad <= launchpads, "Undefined launchpad!");
    require(_amount > 0 && _amount <= launchpad[_launchpad].size,
      "Rockets need to be more than one and maximum as much as the launchpad can handle");
    uint256 _totalCost = consumeDiscount(_rocket, _amount);
    require(_totalCost <= msg.value, "Insufficient found!");
    DataSets.Rocket storage _rt    = rocketSupply[_rocket];
    require(_rt.cost.mul(_amount) >= msg.value, "We do not accept tips!");
    uint256 _pIndex = maintainPlayer(msg.sender, _player);
    DataSets.Player storage _pr    = player[_pIndex];
    DataSets.Round storage _rd     = round[rounds];
    pot = pot.add(_totalCost);
    for (uint8 i = 0; i < _amount; ++i)
      if (getRandom(100, now + i) < _rt.accuracy)
        ++_hits;
    if (_hits > 0) {
      uint256 _m               = _rt.merit.mul(_hits);
      _pr.merit[_launchpad-1]  = uint32(_pr.merit[_launchpad-1].add(_m));
      merit[_launchpad-1]      = uint32(merit[_launchpad-1].add(_m));
      _rd.mayImpactAt          = _rd.mayImpactAt.add(_rt.knockback.mul(_hits));
      _rd.hero                 = msg.sender;
      _rd.launchpad            = _launchpad;
    }
    if (_totalCost < msg.value) {
      msg.sender.transfer(msg.value.sub(_totalCost));
    }
    emit rocketLaunch(_hits, _rd.mayImpactAt);
    return _hits;
  }

  function timeTillImpact() public view returns (uint256) {
    if (round[rounds].mayImpactAt > now){
      return round[rounds].mayImpactAt.sub(now);
    } else {
      return 0;
    }
  }

  function finish(uint256 _player) public onlyOwner() onlyLiveRound() {
    require(timeTillImpact() == 0, "Not yet!");
    DataSets.Round storage _rd   = round[rounds];
    if (_rd.hero != address(0)) {
      _player                      = maintainPlayer(_rd.hero, _player);
      DataSets.Player storage _pr  = player[_player];
      hero[rounds].addr            = _rd.hero;
      _rd.merit                    = merit[_rd.launchpad-1].sub(_pr.merit[_rd.launchpad-1]);
      _rd.jackpot                  = pot.div(100).mul(prizeDist.hero);
      if (_rd.merit > 0) {
        _rd.bounty                 = pot.div(100).mul(prizeDist.bounty).div(_rd.merit);
        pot                        = pot.sub(_rd.jackpot).sub(_rd.merit.mul(_rd.bounty));
      } else {
        pot                        = pot.sub(_rd.jackpot);
      }
      _pr.merit[_rd.launchpad-1]   = 0;
      _pr.earnings                 = _rd.jackpot;
    }
    _rd.over                       = true;
    emit roundFinish(rounds, _rd.jackpot, _pr.addr);
  }

  function prizeWithdrawTo(uint256 _eth, address _to, uint256 _player) public {
    require(_to != address(0), "Address can not be zero!");
    _player                      = findPlayerIndex(msg.sender, _player);
    require(_player != 0, "Unknow player!");
    _player                      = maintainPlayer(msg.sender, _player);
    DataSets.Player storage _pr  = player[_player];
    require(_eth <= _pr.earnings, "Insufficient found!");
    if (_eth == 0) _eth = _pr.earnings;  
    _pr.earnings = _pr.earnings.sub(_eth);
    _to.transfer(_eth);
  }

  function setHeroName(uint16 _round, string _name) external payable {
    require(msg.sender == hero[_round].addr, "The address does not match with the hero!");
    require(10000000000000000 == msg.value, "The payment must be 0.01ETH!");
    pot              += 10000000000000000;  
    hero[_round].name = _name.nameFilter();
    emit roundHero(_round, hero[_round].name);
  }
}