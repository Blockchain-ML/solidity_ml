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

 
contract erc20Interface {
  function totalSupply() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract byt_str {
    function stringToBytes32(string memory source) pure public returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function bytes32ToString(bytes32 x) pure public returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}

 
contract bitape is owned, byt_str{

  address token_address = 0x0 ;  
  uint pay = 5*10**18 ;  
  uint number_index = 0 ;

  struct process {
      address buyer;
      address seller;
      address sensor;
      data_base[] data;
      bool start;
  }

  struct data_base {
    uint8 _stage;  
    uint8 _report;  
    uint16 _temperature;  
    uint8 _humidity;  
    uint8 _vendor;  
    uint32 _deliveryman;  
    uint32[2] _location;  
    bytes32 _remarks;  
    uint32 _time;   
    
     
     
  }

  mapping (address => uint) info;
   
 
  
  mapping (uint => process) all_data;
   


  event get_number(address indexed buyer, address indexed seller, uint _number);

 

  function start_service(address _seller, uint32 _time) public{  
      
    uint _number = number_index;
    all_data[_number].start = true;
    
    all_data[_number].buyer = msg.sender ;
    all_data[_number].seller = _seller ;
    emit get_number(all_data[_number].buyer, all_data[_number].seller, _number);
    
    data_base memory _data = data_base(
        0,  
        0,  
        0,  
        0,  
        0,  
        0,  
        [uint32(0),uint32(0)],  
        0x0,  
        _time   
        );
        all_data[_number].data.push(_data);
    
    _number += 1;
  }
  
  function start_service2(uint _number, address _sensor, uint32 _time) public{
      require(all_data[_number].start == true);
      require(msg.sender == all_data[_number].seller);
      all_data[_number].sensor = _sensor;
       
      
        data_base memory _data = data_base(
        1,  
        0,  
        0,  
        0,  
        0,  
        0,  
        [uint32(0),uint32(0)],  
        0x0,  
        _time   
        );
        all_data[_number].data.push(_data);
      
  }
  
  function stop_service(uint _number, uint32 _time) public{  
      require(all_data[_number].start == true);
        data_base memory _data = data_base(
        255,  
        0,  
        0,  
        0,  
        0,  
        0,  
        [uint32(0),uint32(0)],  
        0x0,  
        _time   
        );
        all_data[_number].data.push(_data);
        all_data[_number].start = false;
  }

  function update_event(
    uint _number,  
    uint8 _stage,  
    uint8 _report,  
    uint16 _temperature,  
    uint8 _humidity,  
    uint8 _vendor,  
    uint32 _deliveryman,  
    uint32[2] _location,  
    string _remarks_str,  
    uint32 _time   
  ) public{
    require(msg.sender == all_data[_number].sensor);
    
    
    bytes32 _remarks_byt = stringToBytes32(_remarks_str);
    
    data_base memory _data = data_base(
        _stage,  
        _report,  
        _temperature,  
        _humidity,  
        _vendor,  
        _deliveryman,  
        _location,  
        _remarks_byt,  
        _time   
        );
    all_data[_number].data.push(_data);
  }
  
  function inquire_length(uint _number) public view returns(uint){
      require(msg.sender == all_data[_number].buyer
      || msg.sender == all_data[_number].seller);
    
    uint _length = all_data[_number].data.length;
    return _length;
     
  }
  
  function inquire(uint _number, uint _sort) public view returns(
    uint8 _stage,  
    uint8 _report,  
    uint16 _temperature,  
    uint8 _humidity,  
    uint8 _vendor,  
    uint32 _deliveryman,  
    uint32[2] _location,  
    string _remarks,  
    uint _time   
        ){
      require(msg.sender == all_data[_number].buyer
      || msg.sender == all_data[_number].seller);
      
      bytes32  _remarks_byt = all_data[_number].data[_sort]._remarks;
      string memory  _remarks_str = bytes32ToString(_remarks_byt);
      
      _stage = all_data[_number].data[_sort]._stage;
      _report = all_data[_number].data[_sort]._report;
      _temperature = all_data[_number].data[_sort]._temperature;
      _humidity = all_data[_number].data[_sort]._humidity;
      _vendor = all_data[_number].data[_sort]._vendor;
      _deliveryman = all_data[_number].data[_sort]._deliveryman;
      _location = all_data[_number].data[_sort]._location;
      _remarks = _remarks_str;
      _time = all_data[_number].data[_sort]._time;
  }
  
 

  function pay_coin() payable public{
    require(erc20Interface(token_address).approve(msg.sender, pay));
  }

  function receiveApproval(address _sender, uint256 _value, address _tokenContract,
    bytes _extraData) public{
      require(_tokenContract == token_address);
      require(_value == pay);
      require(erc20Interface(token_address).transferFrom(_sender, address(this), _value));
      uint256 payloadSize;
      uint256 payload;
      assembly {
        payloadSize := mload(_extraData)
        payload := mload(add(_extraData, 0x20))
      }
      payload = payload >> 8*(32 - payloadSize);
      info[msg.sender] = payload;
    }

  }