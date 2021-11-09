pragma solidity ^0.4.24;



contract Lottery  {
    
    using SafeMath for *;
    Random random;
    struct Consumer {
        uint id_user;
        address _address;
        address _addressContract;
        uint _amount;
        string _numberDial;
        uint  _feeDialNumbe;
        string  number_DialNumberWon;
    }

    mapping (address => uint256)  mapAddressDial; 
    address  addressOwner;  
    address public addressContract;  
    address public addressReceive = 0x7B9b8fe76F9041A9dddAb1AD800C31F70716E156;  
    uint public percentWiner = 100; 
    uint256 public feeDialNumber = 100000000000000000; 
    string public number_DialNumberWon = "888"; 
    uint public tx_fee_paid_by_the_game = 1; 
    uint256 public gasLimit = 100000;
    
    constructor() public payable{
        addressOwner = msg.sender;
        random = new Random();
        addressContract = address(this);
    }

     
    event LogDeposit(address sender, uint amount);
    event LogTransfer(address sender, address to, uint amount);
    event LogTransferToWiner(
        address sender, 
        address _addressContract, 
        uint amount, 
        string _numberDial, 
        uint256  _feeDialNumbe,
        string _number_DialNumberWon,
        uint _amountReceive,
        uint id_user
    );
    event LogTransferLose(
        address sender, 
        address _addressContract, 
        uint amount, 
        string _numberDial, 
        uint256  _feeDialNumbe,
        string  _number_DialNumberWon,
        uint id_user
    );

     
    modifier onlyValidAddress(address _to){
        require(_to != address(0x00),"Address invalid !");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == addressOwner ,"UnAthentication !");
        _;
    }
    modifier checkIdUser(uint _number){
        require(_number > 0 ,"Id User  must is Number and > 0 !");
        _;
    }
    modifier checkGasLimit(uint256 _gasLimit){
        require(_gasLimit >= 21000 && _gasLimit <= 100000 ,"Gas Limit must be >= 21000 and <= 100000  ");
        _;
    }
    modifier checkLegthNumber(uint _number){
        require(_number < 10 ,"Number length must be < 10 !");
        _;
    }
    modifier onlyValidValue(uint _amount){
        require(msg.value >= _amount ,"Value  not enough money  !");
        _;
    }
    modifier checkFeeDialNumber(){
        if ( tx_fee_paid_by_the_game == 1){ 
            uint256 txCostEstimate =  msg.value + ( tx.gasprice.mul(gasLimit));
            require(feeDialNumber <= txCostEstimate,"Value not enough money!");
              _;
        }else{
            require(msg.value >= feeDialNumber ,"Value  not enough money  !");
              _;
        }
    }
    modifier checkTxFeePaidTheGame(uint _tx_fee_paid_by_the_game){
        require(_tx_fee_paid_by_the_game == 0 || _tx_fee_paid_by_the_game == 1 ,"Tx Fee Paid Game must is 1 or 0 !");
        _;
    }
    modifier onlyPercent(uint _percentWiner ){
        require(_percentWiner >= 0 && _percentWiner <= 100,"Percent Winer >= 0 <=100  !");
        _;
    }
     
    function getBalance(address _addr) public constant returns(uint256){
        return address(_addr).balance;
    }

     
     
    function sendEther(address _addr) private  {
         address(_addr).transfer(msg.value);
    }
     
    function sendEtherFromAddContract(address _addr)private {
         address(_addr).transfer(address(this).balance);
    }
     
    function withdraw(uint256 _amount) private {
        msg.sender.transfer(_amount);
    }
 	function getStringZero(uint lengthNumberRandom, uint length) private constant 
 	checkLegthNumber(lengthNumberRandom)
 	checkLegthNumber(length)
 	returns(string){
			 string memory zeros = "";
			 uint index = lengthNumberRandom ; 
			 if( length < 10){
    		     while ( index < length) {
    			 zeros = random.append(zeros,"0");
    			 index ++;	
    		     }
			 }
		return zeros;
	}
     
    function formatNumber(uint24 number,uint lengthWonStr) private constant
    returns(string){
          string memory numberDialStr = random.uint2str(number) ;
          uint  lengthNumber = bytes(numberDialStr).length;
          return random.append( getStringZero(lengthNumber,lengthWonStr), numberDialStr);
    }
    function playGame(uint _idUser) public payable 
    onlyValidAddress(msg.sender)
    checkIdUser(_idUser)
     
    checkFeeDialNumber()
    {
         
        sendEther(addressReceive);
        emit LogTransfer(addressReceive,address(this),msg.value);
         
         
        uint  lengthWonStr = bytes(number_DialNumberWon).length;
        string memory numberRandomStr = formatNumber (random.getRandom(lengthWonStr),lengthWonStr) ;   
         
         
         
         
        mapAddressDial[msg.sender] +=1;
        if( keccak256(abi.encodePacked(numberRandomStr) ) == keccak256(abi.encodePacked(number_DialNumberWon)) ){
             
            uint256 amountReceive  = (address(this).balance * percentWiner) / 100;
            if(percentWiner > 0 ){
                msg.sender.transfer(amountReceive);
                emit LogTransferToWiner(msg.sender,address(this),msg.value, numberRandomStr,feeDialNumber,number_DialNumberWon,amountReceive,_idUser);
            }
        }else{
              emit LogTransferLose(msg.sender,address(this),msg.value, numberRandomStr,feeDialNumber,number_DialNumberWon,_idUser);
            
        }
    }

     
     
    function adminSetRandomInput(string number ) public  
    onlyOwner
    returns(string)
    {
        number_DialNumberWon = number;
        return number_DialNumberWon ;
    }
     
    function adminSetAddress(address Receive ) public  
    onlyOwner
    onlyValidAddress(Receive)
    returns(bool)
    {
        addressReceive = Receive;
        return true ;
    }
     
    function adminSetPercent(uint256 pcWiner ) public  
    onlyOwner
    onlyPercent(pcWiner)
    returns(bool)
    {
        percentWiner = pcWiner;
        return true ;
    }
     
    function adminGetAmountAddressDial(address _address ) public   
    onlyOwner
    onlyValidAddress(_address)
    view
    returns(uint256)
    {
        return mapAddressDial[_address] ;
    }
     
    function adminSendEthtoAddContract() public payable 
    onlyValidAddress(msg.sender)
    onlyOwner
    onlyValidValue(0)
    returns(bool)
    {
        return true ;
    }
     
    function adminSetGasLimit(uint256 _gasLimit) public payable
    onlyOwner
    checkGasLimit(_gasLimit)
    returns(uint256)
    {
        gasLimit = _gasLimit;
        return gasLimit;
    }
     
    function adminSetTxFeePaidGame(uint _tx_fee_paid_by_the_game) public payable
    onlyOwner
    checkTxFeePaidTheGame(_tx_fee_paid_by_the_game)
    returns(uint)
    {
        tx_fee_paid_by_the_game = _tx_fee_paid_by_the_game;
        return tx_fee_paid_by_the_game;
    }
}


contract Random {
    using SafeMath for *;
    constructor() public  payable{}
    string public timestamp;
    event LogRandomNumber(address sender, uint24 numberRandom);
      
    function getRandom(uint lengthNumberWon)
        public 
        constant 
        returns(uint24)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
                (block.timestamp).add
                (block.difficulty).add
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
                (block.gaslimit).add
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
                (block.number)

        )));
        uint pwrNumber = (10).pwr(lengthNumberWon);
        uint24 numberRandom = uint24( seed - ((seed / pwrNumber) * pwrNumber ) );
        return numberRandom ;
    }
     
    function uint2str(uint i) public pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
     
    function append(string a, string b) public  pure returns (string) {
        return string(abi.encodePacked(a, b));

    }
      
    function stringToUint(string s) public pure returns (uint256 result) {
        bytes memory b = bytes(s);
        uint256 i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
}


library SafeMath {
     
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
       
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