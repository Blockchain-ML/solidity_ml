pragma solidity ^0.4.25;

 

 

contract owned {
    address public owner;

    constructor() public{
        owner = msg.sender;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns(bool);
}

 

contract game is owned{

 
    address public tokenAddress_GIC = 0x6bA0BE81aEbD9a5239818e98C7352924d63eD515;
    address public tokenAddress_Arina = 0x3b117A9Dc5f236F8493a37f57dF5E6CFb4b995DD;

    mapping (address => uint) readyTime;
    uint public airdrop_GIC = 5*10**18 ;   
    uint public airdrop_Arina = 100*10**18 ;   
    
    uint public total_airdrop_GIC = 21000000*10**18;  
    uint public total_airdrop_Arina = 84000000*10**18;  
    
    uint public sent_times = 0;  
    uint public sent_limit = total_airdrop_GIC/airdrop_GIC;  

    uint public cooldown = 30;   
    mapping (address => uint8) record;  
    mapping (address => uint24[2])record_random;
    mapping (address => bool) initialization;
    
    event Play_game(address indexed from, uint8 record);
     
    event Random(address indexed from, uint24 player, uint24 com);
     
    

 

    function set_address_GIC(address new_address)onlyOwner public{
        tokenAddress_GIC = new_address;
    }
    
    function set_address__Arina(address new_address)onlyOwner public{
        tokenAddress_Arina = new_address;
    }

    function set_cooldown(uint new_cooldown)onlyOwner public{
        cooldown = new_cooldown;
    }

    function withdraw_GIC(uint _amount)onlyOwner public{
        require(ERC20Basic(tokenAddress_GIC).transfer(owner, _amount*10**18));
    }
    
    function withdraw_Arina(uint _amount)onlyOwner public{
        require(ERC20Basic(tokenAddress_Arina).transfer(owner, _amount*10**18));
    }
    
    
    function withdraw_eth()onlyOwner public{
        owner.transfer(address(this).balance);
    }

 
    function ()public{
        play_game(0);
    }

    function play_paper()public{
        play_game(0);
    }

    function play_scissors()public{
        play_game(1);
    }

    function play_stone()public{
        play_game(2);
    }

    function play_game(uint8 player) internal{
        if (initialization[msg.sender] == false){
            initialization[msg.sender] = true;
        }
        
        require(readyTime[msg.sender] < block.timestamp);
        require(player <= 2);
        
        require(sent_times <= sent_limit);
         

        uint8 comp=uint8(uint(keccak256(block.difficulty, block.timestamp))%3);
        uint8 result = compare(player, comp);
        
        uint8 _record = result * 9 + player * 3 + comp ;
        record[msg.sender] = _record;

        if (result == 2){  
            sent_times +=1 ;
            require(ERC20Basic(tokenAddress_GIC).transfer(msg.sender, airdrop_GIC));
            require(ERC20Basic(tokenAddress_Arina).transfer(msg.sender, airdrop_Arina));
        }
        else if(result == 1){  
        
        }
        
        else if(result == 0){  
            readyTime[msg.sender] = block.timestamp + cooldown;
        }
        
        uint24 random_player = uint24(keccak256(msg.sender, block.difficulty, block.timestamp))%1000000;
        uint24 random_lottery = uint24(keccak256(block.timestamp, block.difficulty))%1000000;
        record_random[msg.sender][0] = random_player;
        record_random[msg.sender][1] = random_lottery;
        
        emit Play_game(msg.sender, _record);
        emit Random(msg.sender, random_player, random_lottery);
        
         
        
        if (random_player == random_lottery){
            uint8 _level = level_judgment(msg.sender);
            uint _eth = eth_amount_judgment(_level);
            if (address(this).balance >= _eth){
                msg.sender.transfer(_eth);
            }
            else{
                msg.sender.transfer(address(this).balance);
            }
            
             
        }
        
    }

 

    function compare(uint8 _player,uint _comp) pure internal returns(uint8 result){
         
         
        uint8 _result;

        if (_player==0 && _comp==2){   
            _result = 2;
        }

        else if(_player==2 && _comp==0){  
            _result = 0;
        }

        else if(_player == _comp){  
            _result = 1;
        }

        else{
            if (_player > _comp){  
                _result = 2;
            }
            else{  
                _result = 0;
            }
        }
        return _result;
    }

    function judge(uint8 orig) internal pure returns(uint8 result, uint8 play, uint8 comp){
        uint8 _result = orig/9;
        uint8 _play = (orig%9)/3;
        uint8 _comp = orig%3;
        return(_result, _play, _comp);
    }

    function mora(uint8 orig) internal pure returns(string _mora){
         
            if (orig == 0){
                return "paper";
            }
            else if (orig == 1){
                return "scissors";
            }
            else if (orig == 2){
                return "stone";
            }
            else {
                return "error";
            }
        }

    function win(uint8 _result) internal pure returns(string result){
         
        if (_result == 0){
                return "lose!!";
            }
            else if (_result == 1){
                return "draw~~";
            }
            else if (_result == 2){
                return "win!!!";
            }
            else {
                return "error";
            }
    }

    function resolve(uint8 orig) internal pure returns(string result, string play, string comp){
        (uint8 _result, uint8 _play, uint8 _comp) = judge(orig);
        return(win(_result), mora(_play), mora(_comp));
    }

    function level_judgment(address _address) view public returns(uint8 _level){
        uint GIC_balance = ERC20Basic(tokenAddress_GIC).balanceOf(_address);
        if (GIC_balance <= 1000){
            return 1;
        }
        else if(1000 < GIC_balance && GIC_balance <=10000){
            return 2;
        }
        else if(10000 < GIC_balance && GIC_balance <=50000){
            return 3;
        }
        else if(50000 < GIC_balance && GIC_balance <=100000){
            return 4;
        }
        else if(100000 < GIC_balance){
            return 5;
        }
    }
    
    function eth_amount_judgment(uint8 _level) pure public returns(uint _eth){
        if (_level == 1){
            return 1 ether;
        }
        else if (_level == 2){
            return 3 ether;
        }
        else if (_level == 3){
            return 5 ether;
        }
        else if (_level == 4){
            return 10 ether;
        }
        else if (_level == 5){
            return 20 ether;
        }
    }


 

    function view_last_result(address _address) view public returns(string result, string player, string computer){
        if(initialization[_address] == false){
            return ("Not playing game yet"," "," ");
        }
        else{
            return resolve(record[_address]);
        }
    }
    function self_last_result() view public returns(string result, string player, string computer){
        return view_last_result(msg.sender);
    }
    

    function view_readyTime(address _address) view public returns(uint _readyTime){
        if (block.timestamp >= readyTime[_address]){
        return 0 ;
        }
        else{
        return readyTime[_address] - block.timestamp ;
        }
    }
    function self_readyTime() view public returns(uint _readyTime){
        return view_readyTime(msg.sender);
    }
    
    
    function view_random(address _address) view public returns(uint24 random1, uint24 random2){
        return (record_random[_address][0],record_random[_address][1]);
    }
    function last_random() view public returns(uint24 random1, uint24 random2){
        return view_random(msg.sender);
    }

}