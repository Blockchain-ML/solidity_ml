pragma solidity ^0.4.24;


 
contract GreedyGameEvent {

    event Log(string content);

	 
    event onWithdraw
    (
        uint256 indexed playerId,
        address playerAddress,
        uint256 ethOut,
        uint256 timeStamp
    );

    event onBuy
    (
      address playerAddress,
      uint256 ethIn,
      uint256 keys
    );

    event onRoundGameOver
    (
        uint256 ronudId,
        address winer,
        uint256 prize,
        uint256 eths,
        uint256 keys,
        uint256 rest
    );

     
     
    event onReLoad
    (
        address playerAddress,
        uint256 eths
    );
}

contract modularLong is GreedyGameEvent {}


contract Se7enGreedyGame is modularLong {
    using SafeMath for *;
    using NameFilter for string;
    using GreedyKeysCalcLong for uint256;

    bool public isActive = false;

    string constant public name = "Greedy of Se3en";
    string constant public symbol = "Greedy";

     
    address public communityAddress = 0xbAbfCD5BFF3bd2ED6592d89856Aa2bA3a08fE86c;

     
    uint256 constant public teamfee = 10;
    uint256 constant public winerPrizeRate = 42;
    uint256 constant public playersRate = 50;

    uint256 constant public nextRate = 10;
    uint256 constant public playerIncomeRate = 90;

     
    uint256 public currendRoundId = 0;

     
    uint256 public pidNo = 1;
    mapping (address => uint256) public pIDxAddr;           
    mapping (uint256 => Greedydatasets.Player) public players;    
    mapping (uint256 => mapping (uint256 => Greedydatasets.PlayerRounds)) public playerRounds;     

     
    mapping (uint256 => Greedydatasets.Round) public rounds;    

    uint256 constant public timeLimit = 1 hours;                 

     
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;
    }

    function ()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
   {
       uint256 _playerId = determinePID(msg.sender);
       buyCore(_playerId);
    }


    function buyXaddr()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        uint256 _playerId = determinePID(msg.sender);
        buyCore(_playerId);
    }

     
    function determinePID(address addr)
        private
        returns (uint256)
    {
        uint256 _playerId = pIDxAddr[addr];
         
        if (_playerId == 0)
        {
             
            _playerId = pidNo;
            pidNo = pidNo + 1;
            pIDxAddr[addr] = _playerId;
            players[_playerId].addr = addr;
        }
        return (_playerId);
    }


    function buyCore(uint256 _playerId)
    private
    {
      uint256 _currendRoundId = currendRoundId;
      uint256 _now = now;
        emit GreedyGameEvent.Log("start to buy keys");

       
      if (_now > rounds[_currendRoundId].start
        && (_now <= rounds[_currendRoundId].end   || (_now > rounds[_currendRoundId].end   && rounds[_currendRoundId].playerId == 0) ) )
      {
          emit GreedyGameEvent.Log("before in core....");
           
          core(_currendRoundId, _playerId, msg.value);
       
      } else {
           
          if (_now > rounds[_currendRoundId].end && rounds[_currendRoundId].gameover == false)
          {
               
              rounds[_currendRoundId].gameover = true;
              endRound();
          }
          emit GreedyGameEvent.Log("buyCore exit as _now < start or _now > end but playerId  != 0");
           
          players[_playerId].gen = players[_playerId].gen.add(msg.value);
      }
        emit GreedyGameEvent.Log("end buy keys.");
    }


    function core(uint256 _currentRoundId, uint256 _playerId, uint256 _eth)
        private
    {

       
      if (playerRounds[_playerId][_currentRoundId].keys == 0){
           
           
          if (players[_playerId].lastRoundId != 0)
              updateGenVault(_playerId, players[_playerId].lastRoundId);

           
          players[_playerId].lastRoundId = currendRoundId;
      }

       
      if (_eth > 1000000000)
      {
           
          uint256 _keys = (rounds[_currentRoundId].eths).keysRec(_eth);

           
          if (_keys >= 1000000000000000000)
          {
              uint256 _now = now;
              rounds[_currentRoundId].end = timeLimit.add(_now);

               
              if (rounds[_currentRoundId].playerId != _playerId)
                  rounds[_currentRoundId].playerId = _playerId;
          }

           
          playerRounds[_playerId][_currentRoundId].keys = _keys.add(playerRounds[_playerId][_currentRoundId].keys);
          playerRounds[_playerId][_currentRoundId].eths = _eth.add(playerRounds[_playerId][_currentRoundId].eths);

           
          rounds[_currentRoundId].keys = _keys.add(rounds[_currentRoundId].keys);
          rounds[_currentRoundId].eths = _eth.add(rounds[_currentRoundId].eths);

           
           
          uint256 _gen = _eth.mul(playersRate).mul(playerIncomeRate)/10000;

           
           
          updateMasks(_currentRoundId, _playerId, _gen, _keys);

          rounds[_currentRoundId].pot = _gen.add(rounds[_currentRoundId].pot);

          emit GreedyGameEvent.onBuy(msg.sender, _eth, _keys);
      }
    }


     
    function withdraw()
        isHuman()
        public
    {
         
        uint256 _currendRoundId = currendRoundId;

         
        uint256 _now = now;

         
        uint256 _playerId = pIDxAddr[msg.sender];

         
        uint256 _eth;

        if (_now > rounds[_currendRoundId].end && rounds[_currendRoundId].gameover == false && rounds[_currendRoundId].playerId != 0)
        {
             
			       rounds[_currendRoundId].gameover = true;
             endRound();
        }

         
        _eth = withdrawEarnings(_playerId);

         
        if (_eth > 0) {
            players[_playerId].addr.transfer(_eth);
            emit GreedyGameEvent.onWithdraw(_playerId, msg.sender, _eth, _now);
        }
    }


    function reLoadXaddr(uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
         
        uint256 _playerId = pIDxAddr[msg.sender];
        reLoadCore(_playerId, _eth);
    }

     
    function reLoadCore(uint256 _playerId, uint256 _eth)
        private
    {
         
        uint256 _currendRoundId = currendRoundId;
         
        uint256 _now = now;

         
        if (_now > rounds[_currendRoundId].start
          && (_now <= rounds[_currendRoundId].end
            || (_now > rounds[_currendRoundId].end
              && rounds[_currendRoundId].playerId == 0)))
        {
             
             
             
            players[_playerId].gen = withdrawEarnings(_playerId).sub(_eth);

             
            core(_currendRoundId, _playerId, _eth);

            emit onReLoad(
              msg.sender,
              _eth
            );
         
        } else if (_now > rounds[_currendRoundId].end && rounds[_currendRoundId].gameover == false) {
             
            rounds[_currendRoundId].gameover = true;
            endRound();
        }
    }


     
    function withdrawEarnings(uint256 _playerId)
        private
        returns(uint256)
    {
         
        updateGenVault(_playerId, players[_playerId].lastRoundId);

         
        uint256 _earnings = (players[_playerId].win).add(players[_playerId].gen);
        if (_earnings > 0)
        {
            players[_playerId].win = 0;
            players[_playerId].gen = 0;
        }

        return(_earnings);
    }



     
    function updateGenVault(uint256 _playerId, uint256 lastRoundId)
        private
    {
        uint256 _earnings = calcUnMaskedEarnings(_playerId, lastRoundId);
        if (_earnings > 0)
        {
             
            players[_playerId].gen = _earnings.add(players[_playerId].gen);
             
            playerRounds[_playerId][lastRoundId].mask = _earnings.add(playerRounds[_playerId][lastRoundId].mask);
        }
    }


     
    function updateMasks(uint256 _currentRoundId, uint256 _playerId, uint256 _gen, uint256 _keys)
        private
        returns(uint256)
    {
         

         
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (rounds[_currentRoundId].keys);
        rounds[_currentRoundId].mask = _ppt.add(rounds[_currentRoundId].mask);

         
         
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        playerRounds[_playerId][_currentRoundId].mask = (((rounds[_currentRoundId].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(playerRounds[_playerId][_currentRoundId].mask);

         
        return(_gen.sub((_ppt.mul(rounds[_currentRoundId].keys)) / (1000000000000000000)));
         
    }


     
    function endRound()
        private
    {
         
        uint256 _currendRoundId = currendRoundId;

         
        uint256 _winPID = rounds[_currendRoundId].playerId;

         
        uint256 _eth = rounds[_currendRoundId].eths;        

         
        uint256 _win = _eth.mul(winerPrizeRate) / 100;   
        uint256 _com = _eth.mul(teamfee) / 100;          
        uint256 _rest = _eth.mul(playersRate).mul(nextRate) / 100;
        uint256 _gen = rounds[_currendRoundId].pot;

         
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (rounds[_currendRoundId].keys);

         
        players[_winPID].win = _win.add(players[_winPID].win);

         
        communityAddress.transfer(_com);

         
        rounds[_currendRoundId].mask = _ppt.add(rounds[_currendRoundId].mask);


        emit GreedyGameEvent.onRoundGameOver(
            _currendRoundId,
            players[_winPID].addr,
            _win,
            _eth,
            rounds[_currendRoundId].keys,
            _rest
        );

         
        currendRoundId++;
        _currendRoundId = currendRoundId;

        rounds[_currendRoundId].start = now;
        rounds[_currendRoundId].end = now.add(timeLimit);
        rounds[_currendRoundId].eths = _rest;
        rounds[_currendRoundId].pot = _rest.mul(playersRate).mul(playerIncomeRate) / 10000;
    }


    function activate()
        public
    {
         
        require(isActive == false, "Greedy Game already activated");

         
        isActive = true;

         
		    currendRoundId = 1;
        rounds[1].start = now;
        rounds[1].end = now.add(timeLimit);
    }


    modifier isActivated() {
        require(isActive == true, "its not ready yet.  check ?eta in discord");
        _;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }



     
    function calcUnMaskedEarnings(uint256 _playerId, uint256 lastRoundId)
        private
        view
        returns(uint256)
    {
        return(  (((rounds[lastRoundId].mask).mul(playerRounds[_playerId][lastRoundId].keys)) / (1000000000000000000)).sub(playerRounds[_playerId][lastRoundId].mask)  );
    }

     
    function calcKeysReceived(uint256 _currentRoundId, uint256 _eth)
        public
        view
        returns(uint256)
    {
         
        uint256 _now = now;

         
        if (_now > rounds[_currentRoundId].start
          && (_now <= rounds[_currentRoundId].end
            || (_now > rounds[_currentRoundId].end
              && rounds[_currentRoundId].playerId == 0)))
            return ( (rounds[_currentRoundId].eths).keysRec(_eth) );
        else  
            return ( (_eth).keys() );
    }

     
    function iWantXKeys(uint256 _keys)
        public
        view
        returns(uint256)
    {
         
        uint256 _currentRoundId = currendRoundId;
         
        uint256 _now = now;

         
        if (_now > rounds[_currentRoundId].start
          && (_now <= rounds[_currentRoundId].end
            || (_now > rounds[_currentRoundId].end
              && rounds[_currentRoundId].playerId == 0)))
            return ( (rounds[_currentRoundId].keys.add(_keys)).ethRec(_keys) );
        else  
            return ( (_keys).eth() );
    }


     
    function getBuyPrice()
        public
        view
        returns(uint256)
    {
         
        uint256 _currentRoundId = currendRoundId;
         
        uint256 _now = now;

         
        if (_now > rounds[_currentRoundId].start
          && (_now <= rounds[_currentRoundId].end
            || (_now > rounds[_currentRoundId].end
              && rounds[_currentRoundId].playerId == 0)))
            return ( (rounds[_currentRoundId].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
        else  
            return ( 75000000000000 );  
    }

     
    function getTimeLeft()
        public
        view
        returns(uint256)
    {
         
        uint256 _currendRoundId = currendRoundId;

         
        uint256 _now = now;

        if (_now < rounds[_currendRoundId].end)
            return( (rounds[_currendRoundId].end).sub(_now) );
        else
            return(0);
    }

     
    function getPlayerVaults(uint256 _playerId)
        public
        view
        returns(uint256 ,uint256)
    {
         
        uint256 _currendRoundId = currendRoundId;

         
        if (now > rounds[_currendRoundId].end && rounds[_currendRoundId].gameover == false && rounds[_currendRoundId].playerId != 0)
        {
             
            if (rounds[_currendRoundId].playerId == _playerId)
            {
                return
                (
                    (players[_playerId].win).add( ((rounds[_currendRoundId].eths).mul(winerPrizeRate)) / 100 ),
                    (players[_playerId].gen).add(  getPlayerVaultsHelper(_playerId, _currendRoundId).sub(playerRounds[_playerId][_currendRoundId].mask)   )
                );
             
            } else {
                return
                (
                    players[_playerId].win,
                    (players[_playerId].gen).add( getPlayerVaultsHelper(_playerId, _currendRoundId).sub(playerRounds[_playerId][_currendRoundId].mask) )
                );
            }

         
        } else {
            return
            (
                players[_playerId].win,
                (players[_playerId].gen).add(calcUnMaskedEarnings(_playerId, players[_playerId].lastRoundId))
            );
        }
    }

     
    function getPlayerVaultsHelper(uint256 _playerId, uint256 _currendRoundId)
        private
        view
        returns(uint256)
    {
        return(  ((((rounds[_currendRoundId].mask).add(((((rounds[_currendRoundId].pot))).mul(1000000000000000000)) / (rounds[_currendRoundId].keys))).mul(playerRounds[_playerId][_currendRoundId].keys)) / 1000000000000000000) );
    }

     
    function getCurrentRoundInfo()
        public
        view
        returns(bool, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, uint256)
    {
         
        uint256 _currendRoundId = currendRoundId;

        return
        (
            rounds[_currendRoundId].gameover,
            _currendRoundId,                            
            rounds[_currendRoundId].keys,               
            rounds[_currendRoundId].end,                
            rounds[_currendRoundId].start,               
            rounds[_currendRoundId].eths,                
            rounds[_currendRoundId].eths.mul(winerPrizeRate)/100, 
            rounds[_currendRoundId].pot,                
            rounds[_currendRoundId].playerId,           
            players[rounds[_currendRoundId].playerId].addr,   
            pidNo - 1
        );
    }

     
    function getPlayerInfoByAddress(address _addr)
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256)
    {
         
        uint256 _currendRoundId = currendRoundId;

        if (_addr == address(0)){
            _addr == msg.sender;
        }
        uint256 _playerId = pIDxAddr[_addr];

        return
        (
            _playerId,                                
            playerRounds[_playerId][_currendRoundId].keys,          
            players[_playerId].win,                     
            (players[_playerId].gen).add(calcUnMaskedEarnings(_playerId, players[_playerId].lastRoundId)),        
            playerRounds[_playerId][_currendRoundId].eths           
        );
    }

}


library Greedydatasets {

  struct Player {
      address addr;    

      uint256 win;     
      uint256 gen;     
      uint256 lastRoundId;    
  }

  struct PlayerRounds {
      uint256 eths;     
      uint256 keys;    
      uint256 mask;    
  }

  struct Round {
      bool gameover;      
      uint256 playerId;   
      uint256 end;        
      uint256 start;      
      uint256 keys;       
      uint256 eths;       

      uint256 pot;        
      uint256 mask;       
  }
}


 
 
 
 
library GreedyKeysCalcLong {
    using SafeMath for *;
     
    function keysRec(uint256 _curEth, uint256 _newEth)
        internal
        pure
        returns (uint256)
    {
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }

     
    function ethRec(uint256 _curKeys, uint256 _sellKeys)
        internal
        pure
        returns (uint256)
    {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

     
    function keys(uint256 _eth)
        internal
        pure
        returns(uint256)
    {
        return (((  (   ((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)) .add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }

     
    function eth(uint256 _keys)
        internal
        pure
        returns(uint256)
    {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}




library NameFilter {
     
    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

         
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
         
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
         
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

         
        bool _hasNonNumber;

         
        for (uint256 i = 0; i < _length; i++)
        {
             
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                 
                _temp[i] = byte(uint(_temp[i]) + 32);

                 
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                     
                    _temp[i] == 0x20 ||
                     
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                     
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                 
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                 
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}




 
library SafeMath {

     
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

     
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

     
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

     
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

     
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

     
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}