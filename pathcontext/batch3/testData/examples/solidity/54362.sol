pragma solidity ^0.4.25;
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
contract Card{
    using SafeMath for uint256;
     
    Room[] public roomcount;
    struct Player{
        uint[5] card;
        uint money;
        uint totalmoney;
    }
     
   
 
    struct  Room{
        uint  roomid;
        mapping(address=>Player) mapself;
        mapping(address=>Player) mapother;
    }
     
    struct RoomPrice{
        uint roomid;
        address[2] playeraddr;
        mapping(address=>uint) playerA;
        mapping(address=>uint) playerB;
    }
     
    address[] public playerpool;
    Room public rm;
    Player public  pr;
    RoomPrice[] public roommoney;
    uint index=0;
    uint firstplayer;
    event submitRoomdata(uint roomid,address _self,address _other,uint[5] _selfcard,uint[5] _othercard,uint _selfmoney,uint _totalmoney);
     
   function getselfaddress()public payable{
       require(msg.value>=1*10**16);
       playerpool.push(msg.sender);
       if( playerpool.length<=1||playerpool.length%2!=0){
            firstplayer=msg.value;
           return ; 
       }
       rm.roomid=playerpool.length;
       
      RoomPrice rp;
      rp.roomid=rm.roomid;
      rp.playeraddr[0]=playerpool[index];
      rp.playeraddr[1]=playerpool[index+1];
      rp.playerA[playerpool[index]]=firstplayer;
      rp.playerB[playerpool[index+1]]=msg.value;
     roommoney[index/2]=rp;
         
     
     
     
     
     
     
      
   }
    
   function statisticaldata(uint roomid,address _self,address _other,uint[5] _selfcard,uint[5]  _othercard)public {
        
            if(_self==roommoney[roomid].playeraddr[0]){
               uint totalprice=roommoney[roomid].playerA[_self].add(roommoney[roomid].playerB[_other]);
                uint price=roommoney[roomid].playerA[_self];
                  
            pr=Player(_selfcard,price,totalprice);
            roomcount[roomid].mapself[_self]=pr;
            uint  _othermoney=roommoney[roomid].playerB[_other];
            pr =Player(_othercard,_othermoney,totalprice);
            roomcount[roomid].mapother[_other]=pr;
            
            }else{
                  uint totalprice1=roommoney[roomid].playerB[_self].add(roommoney[roomid].playerA[_other]);
                uint price1=roommoney[roomid].playerB[_self];
                  
            pr=Player(_selfcard,price1,totalprice1);
            roomcount[roomid].mapself[_self]=pr;
            uint  _othermoney1=roommoney[roomid].playerA[_other];
            pr =Player(_othercard,_othermoney1,totalprice);
            roomcount[roomid].mapother[_other]=pr;
            }
            emit submitRoomdata(roomid,_self,_other,_selfcard,_othercard, price,totalprice);
   }
    
   function setroommoney(uint _roomid) public  payable {
       
       
       
       
        require(msg.value>1*10*15,"投注金额大于10**15");
     if(msg.sender==roommoney[_roomid].playeraddr[0]){
         roommoney[_roomid].playerA[msg.sender]= roommoney[_roomid].playerA[msg.sender].add(msg.value);
     }else{
          roommoney[_roomid].playerB[msg.sender]= roommoney[_roomid].playerB[msg.sender].add(msg.value);
     }
    
   }
   
   function getplaypool()public view returns(uint){
       return playerpool.length;
   }


   
     
     
     
     
     
     
     
     
     
   

   function getplayerpool() public view returns(address[]){
     return playerpool;
   }

   function getrm() public view returns(uint){
     return (rm.roomid);
   }
  
   function getroommoney() public view returns(uint){
     return roommoney[roommoney.length-1].roomid;
   }
   function getindex() public view returns(uint){
     return index;
   }
}