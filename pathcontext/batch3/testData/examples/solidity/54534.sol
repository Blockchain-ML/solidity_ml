pragma solidity ^0.4.23;

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 

 
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

 

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

 

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

 

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 

contract CloseCrossToken is StandardToken, DetailedERC20("CloseCross Token", "CLOX", 18) {
    constructor() public {
        totalSupply_ = 1e6 * (uint(10) ** decimals);
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

     
    function mint(address _to, uint256 _amount) public {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(address(0), _to, _amount);
    }
}

 

library SafeMathInt {
    using SafeMath for uint256;

    function addInt(uint256 a, int256 b) public pure returns(uint256) {
        if (b < 0) {
            return a.sub(uint(b * -1));
        } else {
            return a.add(uint(b));
        }
    }
}

 

library BytesParserLib {
    function toUint(bytes self, uint8 start, uint8 len) public pure returns(uint res) {
        uint base = 256;
        uint mask = base**len-1;
        assembly{
            res := and(mload(add(self,add(start,len))),mask)
        }
    }

    function toInt(bytes self, uint8 start, uint8 len) public pure returns(int res) {
        return int(toUint(self, start, len));
    }

    function toBool(bytes self, uint position) public pure returns(bool) {
        if (self[position] == 0) {
            return false;
        } else {
            return true;
        }
    }

    function toBytes32(bytes self, uint8 start) public pure returns (bytes32) {
        uint res = toUint(self,start,32);
        return bytes32(res);
    }

    function slice(bytes self, uint8 start, uint8 length) public pure returns (bytes) {
        bytes memory res = new bytes(length);
        for (uint8 i = 0; i < length; i++) {
            res[i] = self[start+i];
        }

        return res;
    }

    function toAddress(bytes self, uint8 start) public pure returns (address) {
        uint res = toUint(self, start, 20);
        return address(res);
    }
}

 

library ReceiptParserLib {
    using BytesParserLib for bytes;

    uint public constant CHANNEL_RECEIPT_LENGTH = 95;
    uint public constant TRADE_RECEIPT_LENGTH = 166;
    uint public constant RESULT_RECEIPT_LENGTH = 191;

    struct ChannelReceipt {
        address account;
        uint channelNumber;
        uint nonce;
        int tokensRelative;
        uint fee;
        bool close;
    }

    struct TradeReceipt {
        bytes32 gameHash;
        uint beta;
        uint tokensCommited;
        uint rangeSelected;
    }

    struct ResultReceipt {
        bytes32 tradeReceiptHash;
        uint tokensWon;
        uint feePaid;
    }

    function parseChannel(bytes receipt) internal pure returns(ChannelReceipt) {
        require(receipt.length == CHANNEL_RECEIPT_LENGTH || receipt.length == TRADE_RECEIPT_LENGTH || receipt.length == RESULT_RECEIPT_LENGTH);

        address account = receipt.toAddress(0);
        uint channelNumber = receipt.toUint(20, 5);
        uint nonce = receipt.toUint(25, 5);
        int tokensRelative = receipt.toInt(30, 32);
        uint fee = receipt.toUint(62, 32);
        bool close = receipt.toBool(94);

        return ChannelReceipt(
            account,
            channelNumber,
            nonce,
            tokensRelative,
            fee,
            close
        );
    }

    function parseTrade(bytes receipt) internal pure returns(TradeReceipt) {
        require(receipt.length == TRADE_RECEIPT_LENGTH);

        bytes32 gameHash = receipt.toBytes32(95);
        uint beta = receipt.toUint(127, 5);
        uint tokensCommited = receipt.toUint(132, 32);
        uint rangeSelected = receipt.toUint(164, 2);

        return TradeReceipt(
            gameHash,
            beta,
            tokensCommited,
            rangeSelected
        );
    }

    function parseResult(bytes receipt) internal pure returns(ResultReceipt) {
        require(receipt.length == RESULT_RECEIPT_LENGTH);

        bytes32 tradeReceiptHash = receipt.toBytes32(95);
        uint tokensWon = receipt.toUint(127, 32);
        uint feePaid = receipt.toUint(159, 32);

        return ResultReceipt(tradeReceiptHash, tokensWon, feePaid);
    }

    function parseChannelCompatible(bytes receipt) public pure returns(
        address account,
        uint channelNumber,
        uint nonce,
        int tokensRelative,
        uint fee,
        bool close)
    {
        ChannelReceipt memory result = parseChannel(receipt);

        return (result.account, result.channelNumber, result.nonce, result.tokensRelative, result.fee, result.close);
    }

    function parseTradeCompatible(bytes receipt) public pure returns(
        bytes32 gameHash,
        uint beta,
        uint tokensCommited,
        uint rangeSelected)
    {
        TradeReceipt memory result = parseTrade(receipt);

        return(result.gameHash, result.beta, result.tokensCommited, result.rangeSelected);
    }

    function parseResultCompatible(bytes receipt) public pure returns(
        bytes32 tradeReceiptHash,
        uint tokensWon,
        uint feePaid)
    {
        ResultReceipt memory result = parseResult(receipt);

        return (result.tradeReceiptHash, result.tokensWon, result.feePaid);
    }
}

 

 

library ECRecovery {

   
  function recover(bytes32 hash, bytes sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

     
    if (sig.length != 65) {
      return (address(0));
    }

     
     
     
     
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

     
    if (v < 27) {
      v += 27;
    }

     
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
       
      return ecrecover(hash, v, r, s);
    }
  }

   
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
     
     
    return keccak256(
      "\x19Ethereum Signed Message:\n32",
      hash
    );
  }
}

 

contract PaymentChannelManager {
    using SafeMathInt for uint256;
    using SafeMath for uint256;

    enum ChannelState { NOT_EXIST, OPEN, CLOSING, CLOSED }

    struct Channel {
        uint tokensAtStart;
        uint startDate;
        uint closingDate;
        uint tokensAtClosing;
        uint fee;
        uint nonce;
        ChannelState state;
    }

    uint public closingTimeout;
    address public serverAddress;
    address public feeBeneficiary;
    mapping(address => Channel[]) public channels;
    CloseCrossToken token;

    event ChannelOpen(address client, uint channelNumber);
    event ChannelCharge(address client, uint channelNumber, uint tokens);
    event ChannelClosing(address client, uint channelNumber, uint nonce);
    event ChannelClose(address client, uint channelNumber);
    event ChannelChallenge(address client, uint channelNumber, uint nonce);

    constructor(
        CloseCrossToken _token,
        address _serverAddress,
        address _feeBeneficiary,
        uint _closingTimeout
    ) public
    {
        token = _token;
        serverAddress = _serverAddress;
        feeBeneficiary = _feeBeneficiary;
        closingTimeout = _closingTimeout;
    }

    function addFunds(uint _tokens) public {
        require(_tokens > 0);
        token.transferFrom(msg.sender, address(this), _tokens);
        uint channelCount = channels[msg.sender].length;

        if (channelCount == 0) {
            openChannel();
        }

        chargeChannel(_tokens);
    }

    function closeChannel(bytes _receipt, bytes _clientSignature, bytes _serverSignature) public {
        ReceiptParserLib.ChannelReceipt memory receiptStruct = getVerifiedReceipt(_receipt, _clientSignature, _serverSignature);
        Channel storage channel = channels[receiptStruct.account][receiptStruct.channelNumber];
        require(channel.state == ChannelState.OPEN);

        channel.closingDate = now;
        channel.tokensAtClosing = channel.tokensAtStart.addInt(receiptStruct.tokensRelative);
        channel.fee = receiptStruct.fee;
        channel.nonce = receiptStruct.nonce;

        openChannel();

        if (receiptStruct.close) {
            closeAndTransfer(channel, receiptStruct.account, receiptStruct.channelNumber);
        } else {
            channel.state = ChannelState.CLOSING;
            emit ChannelClosing(receiptStruct.account, receiptStruct.channelNumber, receiptStruct.nonce);
        }
    }

    function closeChannelWithoutReceipt() public {
        uint channelNumber = channels[msg.sender].length-1;
        Channel storage channel = channels[msg.sender][channelNumber];
        require(channel.state == ChannelState.OPEN);
        require(channel.tokensAtStart > 0);

        channel.closingDate = now;
        channel.tokensAtClosing = channel.tokensAtStart;

        openChannel();

        channel.state = ChannelState.CLOSING;
        emit ChannelClosing(msg.sender, channelNumber, 0);
    }

    function challengeChannel(bytes _receipt, bytes _clientSignature, bytes _serverSignature) public {
        ReceiptParserLib.ChannelReceipt memory receiptStruct = getVerifiedReceipt(_receipt, _clientSignature, _serverSignature);
        Channel storage channel = channels[receiptStruct.account][receiptStruct.channelNumber];
        require(channel.state == ChannelState.CLOSING);
        require(receiptStruct.nonce > channel.nonce);

        channel.tokensAtClosing = channel.tokensAtStart.addInt(receiptStruct.tokensRelative);
        channel.fee = receiptStruct.fee;
        channel.nonce = receiptStruct.nonce;

        emit ChannelChallenge(receiptStruct.account, receiptStruct.channelNumber, receiptStruct.nonce);

        if (receiptStruct.close) {
            closeAndTransfer(channel, receiptStruct.account, receiptStruct.channelNumber);
        }
    }

    function withdrawChannel(address _clientAddress, uint _channelCounter) public onlyClientOrServer(_clientAddress) {
        Channel storage channel = channels[_clientAddress][_channelCounter];
        require(channel.state == ChannelState.CLOSING);
        require(channel.closingDate + closingTimeout < now);

        closeAndTransfer(channel, _clientAddress, _channelCounter);
    }

    function withdrawAllChannels(address _clientAddress) public onlyClientOrServer(_clientAddress) {
        uint count = userChannelsCount(_clientAddress);
        for (uint i = 0; i < count; i++) {
            if (channels[_clientAddress][i].state == ChannelState.CLOSING && (channels[_clientAddress][i].closingDate + closingTimeout < now)) {
                closeAndTransfer(channels[_clientAddress][i], _clientAddress, i);
            }

            if (gasleft() < 100000) {
                return;
            }
        }
    }

    function userChannelsCount(address _owner) public view returns(uint) {
        return channels[_owner].length;
    }

    function getVerifiedReceipt(bytes _receipt, bytes _clientSignature, bytes _serverSignature)
        private view returns (ReceiptParserLib.ChannelReceipt)
    {
        ReceiptParserLib.ChannelReceipt memory receiptStruct = ReceiptParserLib.parseChannel(_receipt);
        checkSignatures(
            _receipt,
            _clientSignature,
            _serverSignature,
            receiptStruct.account
        );
        require(msg.sender == receiptStruct.account || msg.sender == serverAddress);

        return receiptStruct;
    }

    function checkSignatures(
        bytes _receipt,
        bytes _clientSignature,
        bytes _serverSignature,
        address _clientAddress
    ) private view
    {
        bytes32 receiptHash = keccak256("\x19Ethereum Signed Message:\n32", keccak256(_receipt));
        require(ECRecovery.recover(receiptHash, _clientSignature) == _clientAddress);
        require(ECRecovery.recover(receiptHash, _serverSignature) == serverAddress);
    }

    function closeAndTransfer(Channel storage _channel, address _clientAddress, uint _channelCounter) private {
        _channel.state = ChannelState.CLOSED;
        token.transfer(_clientAddress, _channel.tokensAtClosing);
        token.transfer(feeBeneficiary, _channel.fee);

        emit ChannelClose(_clientAddress,_channelCounter);
    }

    function chargeChannel(uint _tokens) private {
        uint lastChannelNumber = channels[msg.sender].length - 1;
        require(lastChannelNumber >= 0);
        require(channels[msg.sender][lastChannelNumber].state == ChannelState.OPEN);

        channels[msg.sender][lastChannelNumber].tokensAtStart = channels[msg.sender][lastChannelNumber].tokensAtStart.add(_tokens);

        emit ChannelCharge(msg.sender, lastChannelNumber, _tokens);
    }

    function openChannel() private {
        Channel memory channel = Channel(
            0,
            now,
            0,
            0,
            0,
            0,
            ChannelState.OPEN
        );
        channels[msg.sender].push(channel);

        emit ChannelOpen(msg.sender, channels[msg.sender].length-1);
    }

    modifier onlyClientOrServer(address _client) {
        require(msg.sender == _client || msg.sender == serverAddress);
        _;
    }
}