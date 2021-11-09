 

pragma solidity^0.4.20;  

interface tokenTransfer {
    function transfer(address receiver, uint amount);
    function transferFrom(address _from, address _to, uint256 _value)returns (bool success);
    function balanceOf(address receiver) returns(uint256);
}

contract Ownable {
  address public owner;
 
 
     
    function Ownable () public {
        owner = msg.sender;
    }
 
     
    modifier onlyOwner {
        require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }
 
     
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
        owner = newOwner;
      }
    }
  
}


contract BebBetsGame is Ownable{
      bool lock = true;
            
     bool isLottery = true;
     
     modifier isLock {
        require(!lock);
        _;
    }
   modifier isBet {
        require(isLottery);
        _;
    }

     
   struct Player {
        address addr;  
        uint256 amount;  
        uint position;
    }
    Player[] public games;
    struct miner{
       uint position; 
       uint point; 
   }
    
   struct Mahjong{
       uint _Mahjong; 
       uint NumberOfcards;
   }
   struct numberGame{
       uint256 NumberOfcards; 
       bool northOpenPairs; 
       uint northOpenPoint; 
       bool WEATOpenPairs; 
       uint WEATOpenPoint; 
       bool southOpenPairs; 
       uint southOpenPoint; 
       bool EastOpenPairs; 
       uint EastOpenPoint; 
   }
    
   mapping(address=>uint)public toTime;
   mapping(uint=>numberGame)public numberGamer;
    
    
   miner[] public minersArray;
   Mahjong[] public MahjongsArray; 
   uint256 gamesmul=now; 
   uint[] game=[0,1,2,3,4,5,6,7];
    uint[] game_a=[2,4,7,3,8,1,5,6,9];
    uint[] game_b=[1,7,9,4,6,5,2,8,3];
    uint[] game_c=[7,3,4,1,8,2,6,9,5];
    uint[] game_d=[5,1,7,9,3,2,8,4,6];
    uint[] game_e=[6,2,8,4,9,1,7,3,5];
    uint[] game_f=[9,4,2,7,5,8,3,6,1];
     
   uint256 totalAmount=0; 
    
    uint256 openRandom1; 
    uint256 openRandom2; 
    uint openPoint; 
    bool openPairs; 
    
    uint256 gameRandomB1; 
    uint256 gameRandomB2; 
    uint gamePointB; 
    bool gamePairsB; 
    
    uint256 gameRandomC1; 
    uint256 gameRandomC2; 
    uint gamePointC; 
    bool gamePairsC; 
    
    uint256 gameRandomD1; 
    uint256 gameRandomD2; 
    uint gamePointD; 
    bool gamePairsD; 
    
    uint256 numberOfPeriods=201900001; 
    uint256 ethExchuangeRate;
    uint8 decimals = 18;
    uint MIN_BET=100*(10**uint256(decimals)); 
    uint MAX_BET=10000000*(10**uint256(decimals)); 
    tokenTransfer public bebTokenTransfer; 
    event messageOpenGame(address sender,bool isScuccess,string message);
         
    function BebBetsGame(address _tokenAddress){
         bebTokenTransfer = tokenTransfer(_tokenAddress);
         setgames();
     }
     function setgames()internal{
        for(uint i=0;i<game.length;i++){
          miner memory set = miner(game[i],0);
           minersArray.push(set);
        }
    }
       
    function sellBeb()public {
        if(toTime[msg.sender]==0){
           toTime[msg.sender]==now;
       }
       uint256 _time = toTime[msg.sender]=+86400;
       require(now>_time);
        uint amount = 1000*(10**uint256(decimals))/ethExchuangeRate;
         msg.sender.transfer(amount);
    }
     
    function buyBeb() payable public {
        uint amount = msg.value;
         
        require(getTokenBalance()>amount*ethExchuangeRate);
         
        bebTokenTransfer.transfer(msg.sender,amount*ethExchuangeRate); 
    }
         
    function setBetMinOrMax(uint256 minAmuont,uint256 maxAmuont)onlyOwner{
     MIN_BET=minAmuont;
     MAX_BET=maxAmuont;   
    }
     
    function setMAJIAN()internal{
        
        for(uint nn=0;nn<4;nn++){
            uint256 randomgame = _random(block.difficulty+gamesmul);
            gamesmul+=gamesmul*993/1000;
            if(randomgame==1){
                for(uint h=0;h<game_a.length;h++){
                    Mahjong memory setgame=Mahjong(game_a[h],0);
                    MahjongsArray.push(setgame);
                }
            }
            if(randomgame==2){
                for(uint j=0;j<game_b.length;j++){
                    Mahjong memory setgame1 = Mahjong(game_b[j],0);
                    MahjongsArray.push(setgame1);
                }
            }
            if(randomgame==3){
                for(uint k=0;k<game_c.length;k++){
                    Mahjong memory setgame2=Mahjong(game_c[k],0);
                    MahjongsArray.push(setgame2);
                }
            }
            if(randomgame==4){
                for(uint l=0;l<game_d.length;l++){
                    Mahjong memory setgame3=Mahjong(game_d[l],0);
                    MahjongsArray.push(setgame3);
                }
            }
            if(randomgame==5){
                for(uint m=0;m<game_e.length;m++){
                    Mahjong memory setgame4=Mahjong(game_e[m],0);
                    MahjongsArray.push(setgame4);
                }
            }
            if(randomgame==6){
                for(uint n=0;n<game_f.length;n++){
                    Mahjong memory setgame5=Mahjong(game_f[n],0);
                    MahjongsArray.push(setgame5);
                }
            }
        }
    }
     
    function stopBets()public onlyOwner {
        lock = false;
        isLottery=false;
        setMAJIAN(); 
    } 
     
    function startBets()public onlyOwner {
        isLottery=true;
        delete MahjongsArray; 
        numberOfPeriods+=1;
         
       delete games;
      
         
        
    }
    
   function hairPoker( uint256 _gamesmul) public isLock onlyOwner{
       uint256 random2 = _random(block.difficulty+_gamesmul*991/100);
        
        for(uint i=0;i<minersArray.length;i++){
            
              uint256 random1 = random(block.difficulty+_gamesmul*random2/100);
              _gamesmul+=gamesmul+_gamesmul*97/1000;
              
             if(MahjongsArray[random1].NumberOfcards == 4){
              i-=1; 
             }
             else
             {
                  
                 minersArray[i].point=MahjongsArray[random1]._Mahjong;
                 MahjongsArray[random1].NumberOfcards+=1; 
             }
        }
        setPosition(); 
   }
    
   function setPosition()internal{
      openRandom1=minersArray[0].point; 
      openRandom2=minersArray[1].point;  
       if(openRandom1 == openRandom2){
         openPairs=true; 
         openPoint = openRandom1;
       }
       else{
        if(openRandom1 + openRandom2 >=10){
         openPairs= false;
         openPoint= openRandom1+ openRandom2-10; 
         }
         else{
         openPairs= false;
         openPoint= openRandom1+ openRandom2; 
        }   
      }
       
      
      gameRandomB1=minersArray[2].point;
      gameRandomB2=minersArray[3].point; 
      if(gameRandomB1 == gameRandomB2){
            gamePairsB = true;
            gamePointB = gameRandomB1;
        }
        else{
            if(gameRandomB1 + gameRandomB2 >=10){
            gamePairsB = false;
            gamePointB = gameRandomB1 + gameRandomB2 - 10;
        }else{
            gamePairsB = false;
            gamePointB = gameRandomB1 + gameRandomB2;
          }   
        }
      gameRandomC1=minersArray[4].point; 
      gameRandomC2=minersArray[5].point;
      if(gameRandomC1 == gameRandomC2){
            gamePairsC = true;
            gamePointC =gameRandomC1;
        }
        else{
         if(gameRandomC1 + gameRandomC2 >=10){
            gamePairsC = false;
            gamePointC = gameRandomC1 + gameRandomC2 - 10;
        }else{
            gamePairsC = false;
            gamePointC = gameRandomC1 + gameRandomC2;
        }   
        }
        
      gameRandomD1=minersArray[6].point; 
      gameRandomD2=minersArray[7].point;
      if(gameRandomD1 == gameRandomD2){
            gamePairsD = true;
            gamePointD = gameRandomD1;
        }
        else{
           if(gameRandomD1 + gameRandomD2 >=10){
            gamePairsD = false;
            gamePointD = gameRandomD1 + gameRandomD2 - 10;
        }else{
            gamePairsD = false;
            gamePointD = gameRandomD1 + gameRandomD2;
        } 
        }
        
         
        numberGame storage betdate=numberGamer[numberOfPeriods];
        betdate.northOpenPairs=openPairs;
        betdate.northOpenPoint=openPoint;
        betdate.WEATOpenPairs=gamePairsB;
        betdate.WEATOpenPoint=gamePointB;
        betdate.southOpenPairs=gamePairsC;
        betdate.southOpenPoint=gamePointC;
        betdate.EastOpenPairs=gamePairsD;
        betdate.EastOpenPoint=gamePointD;
   }
    
   function getIssue(uint _Issue) public view returns(bool,uint,bool,uint,bool,uint,bool,uint){
       numberGame storage betdate=numberGamer[_Issue];
        return (betdate.northOpenPairs,betdate.northOpenPoint,betdate.WEATOpenPairs,betdate.WEATOpenPoint,betdate.southOpenPairs,betdate.southOpenPoint,betdate.EastOpenPairs,betdate.EastOpenPoint);
    }
     
    function getPositionRandom() public view  returns(uint256,uint256,uint256,uint256,
            uint256,uint256,uint256,uint256){
        return(openRandom1,openRandom2,gameRandomB1,gameRandomB2,gameRandomC1,gameRandomC2,gameRandomD1,gameRandomD2);
        
    } 
    
   event messageBetsGame(address sender,bool isScuccess,string message);
   function betsGame(uint position,uint256 amount)public isBet  {
        
         require (amount >= MIN_BET, "Insufficient bet amount");
         require (amount <= MAX_BET, "The amount is too large");
         
        uint256 sumAmount = (amount + totalAmount);
        uint256 bankerAmount= getTokenBalance();
        assert(sumAmount < bankerAmount);
         address _address = msg.sender;
          
          bebTokenTransfer.transferFrom(_address,address(this),amount);
          
            if(position == 1){ 
                Player memory players = Player(_address,amount,position);
                games.push(players);
                 
                totalAmount += amount;
                messageBetsGame(_address, true,"下注成功 ");
               return;
            }
             if(position == 2){ 
                Player memory playert = Player(_address,amount,position);
                games.push(playert);
                 
                totalAmount += amount;
                messageBetsGame(_address, true,"下注成功 ");
               return;
            }
            if(position == 3){ 
                Player memory playeru = Player(_address,amount,position);
                games.push(playeru);
                 
                totalAmount += amount;
                messageBetsGame(_address, true,"下注成功 ");
               return;
            }
    }
    function openGames()  public onlyOwner{
          Player players;
           for(uint i = 0 ; i < games.length ; i ++) {
              players = games[i];
              if(players.position==1){
                transferGame(gamePairsB,gamePointB,players.addr,players.amount);
              }else if(players.position==2){
                transferGame(gamePairsC,gamePointC,players.addr,players.amount);
              }else if(players.position==3){
                transferGame(gamePairsD,gamePointD,players.addr,players.amount);
              }
            }
            messageOpenGame(msg.sender, true,"开奖成功 !");
            return;
      }
     
     
     
    function transferGame(bool gamePairs,uint gamePoint,address addr,uint256 amount)  internal {
         
        if(gamePairs){
             
            if(openPairs){
                 
                if(gamePoint == openPoint){
                      
                     bebTokenTransfer.transfer(addr,amount);
                }else if(gamePoint > openPoint){
                     
                    bebTokenTransfer.transfer(addr,amount * 2);
                }else{
                     
                }
            }else{ 
                 bebTokenTransfer.transfer(addr,amount * 2);
            }
        }else{
            if(openPairs){
                
            }
            else {
               if(gamePoint==openPoint){
                      
                    bebTokenTransfer.transfer(addr,amount);    
                }
                else{
                    if(gamePoint > openPoint){
                     bebTokenTransfer.transfer(addr,amount * 2);
                }
                else{
                     
                }  
               }
            }
        }
    }
     
    function withdrawAmount(address toAddress) payable onlyOwner public {
       bebTokenTransfer.transfer(toAddress,address(this).balance);
    } 
   
      
    function getTokenBalance() public view returns(uint256){
         return bebTokenTransfer.balanceOf(address(this));
    }
  
     
    function getTotalAmount() public view returns(uint256){
        return totalAmount;
    }
    
     
     function getPlayersCount() public view returns(uint){
        return games.length;
    }
     
    function getPeriods() public view returns(uint256){
        return numberOfPeriods;
    }
    
     
     function random(uint256 randomyType)  internal returns(uint256 num){
        uint256 random = uint256(keccak256(randomyType,now));
         uint256 randomNum = random%37;
         if(randomNum<1){
             randomNum=1;
         }
         if(randomNum>36){
            randomNum=36; 
         }
         
         return randomNum;
    }
         
     function _random(uint256 randomyType)  internal returns(uint256 num){
        uint256 _random1 = uint256(keccak256(randomyType,now));
         uint256 randomNum = _random1%7;
         if(randomNum<1){
             randomNum=1;
         }
         if(randomNum>6){
            randomNum=6; 
         }
         
         return randomNum;
    }
}