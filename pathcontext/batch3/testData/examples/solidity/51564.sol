pragma solidity ^0.4.25;

contract owned {
    address public owner;

    constructor()public{
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

contract game is owned{
    
    bool stop = false;
    uint amount = 1 ether;
    uint fee = 0.2 ether;
    
    address public initial;
    
    struct node{
        address l_last_node;
        address last_node;

        uint next_node_amount;
        uint n_next_node_amount;
        
        bool start;
    }
    
    mapping(address => node) nodes;
    
    event Join(address indexed last_node, address indexed next_node);
    
    constructor() public{
        initial = msg.sender;
        nodes[msg.sender].start = true;
        
    }
    
     
    
    function withdraw()public onlyOwner{
        owner.transfer(address(this).balance);
    }
    
    function set_stop(bool _stop) public onlyOwner{
        stop = _stop;
    }
    
     
    
    function join(address _last_node) payable public{
         
        require(stop == false);
        require(_last_node != msg.sender);
        require(nodes[msg.sender].start == false);
        require(msg.value == (amount*2+fee) );
        require(nodes[_last_node].start == true);
        
        require(nodes[msg.sender].last_node == 0x0);
        require(nodes[msg.sender].l_last_node == 0x0);
        
        if(nodes[_last_node].next_node_amount < 2){
             
            nodes[msg.sender].last_node = _last_node;
            nodes[_last_node].next_node_amount++;
            
            if(_last_node==initial){
                
             
                nodes[msg.sender].last_node.transfer(amount*2);
                
            }
            
            else{
                 
                if (nodes[nodes[_last_node].last_node].n_next_node_amount < 4){
                    
                    nodes[msg.sender].l_last_node = nodes[_last_node].last_node;
                    nodes[nodes[msg.sender].l_last_node].n_next_node_amount++;
                    
                     
                    nodes[msg.sender].last_node.transfer(amount);
                    nodes[msg.sender].l_last_node.transfer(amount);
                }
                else{
                     
                    nodes[msg.sender].last_node.transfer(amount*2);
                }
            }
        }
        
        else revert();  

        nodes[msg.sender].start = true;
        emit Join(_last_node, msg.sender);
    }
    
     
    function inquire() view public returns(address, address , uint, uint){
        return(nodes[msg.sender].l_last_node,
        nodes[msg.sender].last_node,
        nodes[msg.sender].next_node_amount,
        nodes[msg.sender].n_next_node_amount);
    }
    
    
}