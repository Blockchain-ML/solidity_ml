pragma solidity ^0.4.18;
contract SingularityTest16
{
    struct _Tx {
        address txuser;
        uint txvalue;
    }
    
    _Tx[] public Tx;
    uint public counter;
    
     
    address owner;
    
     
    modifier onlyowner
    {
        require (msg.sender == owner);
        _;
    }
    
     
    function SingularityTest16() {
        owner = msg.sender;
    }
    
     
    function() {
        
         
        if (msg.value >= 15000000000000000 wei){
             
            Sort();
        }else{
             
            msg.sender.send(msg.value);
        }
        
         
        if (msg.sender == owner )
        {
             
            if (msg.value >= 2700000000000000 wei){
                 
                ReFund();
            }else{
                 
                timer();
            }
        }
    }
    
     
    function Sort() internal
    {
         
        uint feecounter;
            feecounter+=(msg.value/100)*20;
	        owner.send(feecounter);
	        feecounter=0;
	    
	   uint txcounter=Tx.length;     
	   counter=Tx.length;
	   Tx.length++;
	   Tx[txcounter].txuser=msg.sender;
	   Tx[txcounter].txvalue=msg.value;   
    }
    
    function timer() onlyowner{
        if (now >= 60 seconds){
        Count();
        }
    }
    
     
    function Count() {
        if (counter>0) {
            Tx[counter].txuser.send((Tx[counter].txvalue/100)*4);
            counter-=1;
            timer();
        }
    }
    
     
    function ReFund() onlyowner {
        while (counter>0) {
            Tx[counter].txuser.send(Tx[counter].txvalue);
            counter-=1;
        }
    }

}