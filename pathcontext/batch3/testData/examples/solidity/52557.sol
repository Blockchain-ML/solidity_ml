pragma solidity >=0.4.22 <0.6.0;

contract MoreSpendTest{
   uint public lastMint;
   address[] public listUsers;
   address public contractOwner;
   address public lastWinner;  

   mapping(address => uint) spendQty;
   
   constructor() public {
        lastMint = now;
        contractOwner = msg.sender;
    }

     
    function addUser(address user) public returns (bool success) {
        require(msg.sender == contractOwner);
        uint arrayLength = listUsers.length;

         
        for (uint i=0; i<arrayLength; i++) {
            if (listUsers[i] == user) {
                return false;  
            }
        }

        listUsers.push(user);
        return true;
    }

     
    function removeUser(address user) public returns (bool success) {
        require(msg.sender == contractOwner);
        uint arrayLength = listUsers.length;

        spendQty[user] = 0;  
        
         
        for (uint i=0; i<arrayLength; i++) {
            if (listUsers[i] == user) {  
                 
                listUsers[i] = listUsers[arrayLength-1];
                delete listUsers[arrayLength-1];
                listUsers.length--;  
                return true;
            }
        }

        return false;
    }

     
   function setSpend(address user, uint qty) public returns (bool success) {
        spendQty[user] = qty;
        return true;
   }

    
   function bestUser() private view returns (address winner) {
        uint max = spendQty[listUsers[0]];
        address userTop = listUsers[0];
        uint arrayLength = listUsers.length;

         
        for (uint i = 1; i<arrayLength; i++) {
            if(spendQty[listUsers[i]] > max) {
                max = spendQty[listUsers[i]];
                userTop = listUsers[i];
            }
        }
        return userTop;
   }

    
   function mint() public returns (bool success) {
    if (now >= lastMint + 5 minutes) {
        uint arrayLength = listUsers.length;
        address winnerUser = bestUser();
        
         
        lastWinner = winnerUser;

        for (uint i = 0; i<arrayLength; i++) {
            spendQty[listUsers[i]] = 0;
        }

        lastMint = now;

        return true;
      }

      return false;
    
   }
   
}