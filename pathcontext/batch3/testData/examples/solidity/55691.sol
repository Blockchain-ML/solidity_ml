pragma solidity 0.5.1;

interface Token {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);

    function balanceOf(address _who) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
}

 
 
 
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
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
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract ethifly is Owned, SafeMath{

    struct EscrowStruct
    {    
        address buyer;           
        address seller;          
        address escrow_agent;    
                                   
        uint escrow_fee;         
        uint amount;             

        bool escrow_intervention;  
        bool release_approval;    
        bool refund_approval;     

        bytes32 notes;              
        
    }

    struct TransactionStruct
    {                        
         
        address buyer;           
        uint buyer_nounce;          
    }
    
     

     
    mapping (address => mapping (address => EscrowStruct[])) public buyerDatabase;
    mapping (address => mapping (address => TransactionStruct[])) public sellerDatabase;
    mapping (address => mapping (address => TransactionStruct[])) public escrowDatabase;

     
     
    mapping(address => mapping (address => uint)) public Funds;

     
    mapping(address => uint) public escrowFee;
    
    constructor() public{
         
    }
    
    function() payable external
    {
        revert();
    }

    function setEscrowFee(uint fee) external {
     
    require (fee >= 1 && fee <= 100);
    escrowFee[msg.sender] = fee;
    }
    
    function newEscrow(address sellerAddress, address escrowAddress, address _token, uint _amount, bytes32 notes, bool dev_fee) payable public returns (bool) {

     
    Token token = Token(_token);
    uint amount = _amount * 10**18;  
    
    require(
    token.transferFrom(
        msg.sender,
        address(this),
        (amount)
    ));   
    
    
     
    EscrowStruct memory currentEscrow;
    TransactionStruct memory currentTransaction;
    
    currentEscrow.buyer = msg.sender;
    currentEscrow.seller = sellerAddress;
    currentEscrow.escrow_agent = escrowAddress;

     
    currentEscrow.escrow_fee = escrowFee[escrowAddress]*amount/1000;
    
    
    uint dev_fee_amount = 0;
     
    if (dev_fee == true){
        dev_fee_amount = amount/500;
        Funds[_token][owner] += dev_fee_amount;
    }

     
    currentEscrow.amount = msg.value - dev_fee_amount - currentEscrow.escrow_fee;

    currentEscrow.notes = notes;

     
    currentTransaction.buyer = msg.sender;
    currentTransaction.buyer_nounce = buyerDatabase[_token][msg.sender].length;

    sellerDatabase[_token][sellerAddress].push(currentTransaction);
    escrowDatabase[_token][escrowAddress].push(currentTransaction);
    buyerDatabase[_token][msg.sender].push(currentEscrow);
    
    return true;

}

     
    function getNumTransactions(address inputAddress, address _token ,uint switcher) public view returns (uint)
    {
        if (switcher == 0) return (buyerDatabase[_token][inputAddress].length);
        else if (switcher == 1) return (sellerDatabase[_token][inputAddress].length);
        else return (escrowDatabase[_token][inputAddress].length);
    }
    
     
    function getSpecificBuyerTransaction(address inputAddress, address _token , uint ID) public view returns (address, address, address, uint, bytes32, uint, bytes32)

    {
        bytes32 status;
        EscrowStruct memory currentEscrow;
        currentEscrow = buyerDatabase[_token][inputAddress][ID];
        status = checkStatus(inputAddress, _token, ID);

        return (currentEscrow.buyer, currentEscrow.seller, currentEscrow.escrow_agent, currentEscrow.amount, status, currentEscrow.escrow_fee, currentEscrow.notes);
    }
    
    function checkStatus(address buyerAddress, address _token, uint nounce) public view returns (bytes32){

        bytes32 status = "";
    
        if (buyerDatabase[_token][buyerAddress][nounce].release_approval){
            status = "Complete";
        } else if (buyerDatabase[_token][buyerAddress][nounce].refund_approval){
            status = "Refunded";
        } else if (buyerDatabase[_token][buyerAddress][nounce].escrow_intervention){
            status = "Pending Escrow Decision";
        } else
        {
            status = "In Progress";
        }
    
        return (status);
    }
    
     
     
    function buyerFundRelease(uint ID, address _token) public
    {
        require(ID < buyerDatabase[_token][msg.sender].length && 
        buyerDatabase[_token][msg.sender][ID].release_approval == false &&
        buyerDatabase[_token][msg.sender][ID].refund_approval == false);
        
         
        buyerDatabase[_token][msg.sender][ID].release_approval = true;

        address seller = buyerDatabase[_token][msg.sender][ID].seller;
        address escrow_agent = buyerDatabase[_token][msg.sender][ID].escrow_agent;

        uint amount = buyerDatabase[_token][msg.sender][ID].amount;
        uint escrow_fee = buyerDatabase[_token][msg.sender][ID].escrow_fee;

         
        Funds[_token][seller] += amount;
        Funds[_token][escrow_agent] += escrow_fee;
    }
    
     
    function sellerRefund(uint ID, address _token) public
    {
        address buyerAddress = sellerDatabase[_token][msg.sender][ID].buyer;
        uint buyerID = sellerDatabase[_token][msg.sender][ID].buyer_nounce;

        require(
        buyerDatabase[_token][buyerAddress][buyerID].release_approval == false &&
        buyerDatabase[_token][buyerAddress][buyerID].refund_approval == false); 

        address escrow_agent = buyerDatabase[_token][buyerAddress][buyerID].escrow_agent;
        uint escrow_fee = buyerDatabase[_token][buyerAddress][buyerID].escrow_fee;
        uint amount = buyerDatabase[_token][buyerAddress][buyerID].amount;
    
         
        buyerDatabase[_token][buyerAddress][buyerID].refund_approval = true;

        Funds[_token][buyerAddress] += amount;
        Funds[_token][escrow_agent] += escrow_fee;
    }
    
             
         

         
    function EscrowEscalation(uint switcher, uint ID, address _token) public
    {
         
         
         
         

         
        address buyerAddress;
        uint buyerID;  
        
        if (switcher == 0)  
        {
            buyerAddress = msg.sender;
            buyerID = ID;
        } else if (switcher == 1)  
        {
            buyerAddress = sellerDatabase[_token][msg.sender][ID].buyer;
            buyerID = sellerDatabase[_token][msg.sender][ID].buyer_nounce;
        }

        require(buyerDatabase[_token][buyerAddress][buyerID].escrow_intervention == false  &&
        buyerDatabase[_token][buyerAddress][buyerID].release_approval == false &&
        buyerDatabase[_token][buyerAddress][buyerID].refund_approval == false);

         
        buyerDatabase[_token][buyerAddress][buyerID].escrow_intervention = true;

    }
    
         
     
    function escrowDecision(uint ID, uint Decision, address _token) public
    {
         
         
         
         
         

        address buyerAddress = escrowDatabase[_token][msg.sender][ID].buyer;
        uint buyerID = escrowDatabase[_token][msg.sender][ID].buyer_nounce;
        

        require(
        buyerDatabase[_token][buyerAddress][buyerID].release_approval == false &&
        buyerDatabase[_token][buyerAddress][buyerID].escrow_intervention == true &&
        buyerDatabase[_token][buyerAddress][buyerID].refund_approval == false);
        
        uint escrow_fee = buyerDatabase[_token][buyerAddress][buyerID].escrow_fee;
        uint amount = buyerDatabase[_token][buyerAddress][buyerID].amount;

        if (Decision == 0)  
        {
            buyerDatabase[_token][buyerAddress][buyerID].refund_approval = true;    
            Funds[_token][buyerAddress] += amount;
            Funds[_token][msg.sender] += escrow_fee;
            
        } else if (Decision == 1)  
        {                
            buyerDatabase[_token][buyerAddress][buyerID].release_approval = true;
            Funds[_token][buyerDatabase[_token][buyerAddress][buyerID].seller] += amount;
            Funds[_token][msg.sender] += escrow_fee;
        }  
    }
    
    function WithdrawFunds(address _token) public
    {
        Token token = Token(_token);
        uint amount = Funds[_token][msg.sender];
        Funds[_token][msg.sender] = 0;
        token.transfer(msg.sender, amount);
            
    }

    function CheckBalance(address fromAddress, address _token) public view returns (uint){
        return (Funds[_token][fromAddress]);
    }


}