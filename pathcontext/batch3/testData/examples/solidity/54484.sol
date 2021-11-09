pragma solidity ^0.4.25;



contract car_insurance{
        
    struct car
    {
        uint license;
        uint total_fee;
        bool is_applied;
        uint voted_yes;
        uint voted_no;
    }
    uint public IndexSize;  
    
   
    uint fee;
    uint compensation;
    uint collected_coins=0;
 
    mapping (address=>car) public cars;
    
    constructor() public  
    {
        fee = 100;  
        compensation = 1000;
        IndexSize=1;
    }

    function addCar(uint _license) public payable
    { 

      
         if(msg.value>=1 ether){
            if(cars[msg.sender].license ==0){  
                cars[msg.sender].license = _license;
                cars[msg.sender].total_fee = fee;
                cars[msg.sender].is_applied = false;
                cars[msg.sender].voted_yes=0;
                cars[msg.sender].voted_no=0;

                 
                 collected_coins +=1;
                 IndexSize++;  
            }
            else{
                cars[msg.sender].total_fee +=1;  
            }
         }
    }
    
    
     
    function apply_compensation() public payable
    {
        if(cars[msg.sender].license!=0)  
        {
             
            cars[msg.sender].is_applied = true;  
             
            while(cars[msg.sender].voted_yes+cars[msg.sender].voted_no < IndexSize)
            {
                 
            }
            
            if(cars[msg.sender].voted_yes>cars[msg.sender].voted_no) 
            {
                compensate(msg.sender);
                reset_application(msg.sender);
            }
            else{ 
                reset_application(msg.sender);
            }
            
        }
        
    }
    
    function vote(address _car, bool _vote) public  
    {
        if(cars[msg.sender].license!=0) 
        {
            if(cars[_car].is_applied == true) 
            {
                if(_vote == true){ 
                    cars[_car].voted_yes++;
                }
                else{ 
                    cars[_car].voted_no++;
                }
            }
            
        }
    }
    
    function pay(uint _amount) public payable 
    {
        if( cars[msg.sender].license!=0) 
        {
            cars[msg.sender].total_fee -= msg.value;
        }
    }
        
    
    function compensate(address _payee) private 
    {
         
        if( msg.sender == address(this) && cars[_payee].license!=0) 
        {
               _payee.send(compensation);
        }
        
    }
    
    function reset_application (address _payee) private  
    {
        cars[_payee].voted_yes=0;
        cars[_payee].voted_no=0;
        cars[_payee].is_applied = false;
    }
    
   
    
    
    function set_fee(uint _fee) private
    {
        fee = _fee;
    }
    function set_compenstation (uint _compensation) private
    {
       compensation = _compensation;
    }
    
}