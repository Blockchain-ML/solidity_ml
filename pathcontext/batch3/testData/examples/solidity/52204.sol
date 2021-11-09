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

    function addCar(address _customer, uint _license) public returns (bool)
    { 

      
        if(cars[_customer].license ==0){  
            cars[_customer].license = _license;
            cars[_customer].total_fee = fee;
            cars[_customer].is_applied = false;
            cars[_customer].voted_yes=0;
            cars[_customer].voted_no=0;

            
             if (!address(this).send(1)) revert();  
             
             collected_coins +=1;
             IndexSize++;  
        }
        else{
            cars[_customer].total_fee +=1;  
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
        
    
    
    function compensate(address _payee) public payable
    {
         
        if( msg.sender == address(this) && cars[_payee].license!=0) 
        {
               if(!_payee.send(compensation)) revert();
        }
        
    }
    
    function reset_application (address _payee) private  
    {
        cars[_payee].voted_yes=0;
        cars[_payee].voted_no=0;
        cars[_payee].is_applied = false;
    }
    
    function pay(uint _amount) public payable 
    {
        if( cars[msg.sender].license!=0) 
        {
            if (!address(this).send(_amount)) revert();  
            cars[msg.sender].total_fee -= _amount;
            
        }
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