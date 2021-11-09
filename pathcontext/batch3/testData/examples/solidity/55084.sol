pragma solidity ^0.4.24;  

 
contract Facito {
    string public constant name = "Facito";  
    string public constant symbol = "FAC";  
    uint8 public constant decimals = 18;  
    uint256 public totalSupply;  

    mapping(bytes32 => Article) public articles;  

    event Transfer (
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approve (
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    event NewArticle (
        bytes32 _ID,
        address _author,
        string _title
    );

    event ReadArticle (
        bytes32 _ID,
        address _author,
        address _reader,
        string _title
    );

    struct Article {
        string Title;
        bytes32 ID;
        string Content;
        string HeaderSource;
        address Author;
        mapping(address => uint) UnspentOutputs;
    }

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 _initialSupply) public {
        balanceOf[this] = _initialSupply;  
        totalSupply = _initialSupply;  
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");  

        balanceOf[msg.sender] -= _value;  
        balanceOf[_to] += _value;  

        emit Transfer(msg.sender, _to, _value);  

        return true;  
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;  

        emit Approve(msg.sender, _spender, _value);  

        return true;  
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");  
        require(_value <= allowance[_from][msg.sender], "Insufficient balance");  

        balanceOf[_from] -= _value;  
        balanceOf[_to] += _value;  

        allowance[_from][msg.sender] -= _value;  

        emit Transfer(_from, _to, _value);  

        return true;  
    }

    function newArticle(string _title, string _content, string _headerSource) public returns (bool success) {
        bytes32 _id = keccak256(abi.encodePacked(_title, _content, _headerSource, msg.sender));  

        emit NewArticle(_id, msg.sender, _title);  

        Article memory article = Article(_title, _id, _content, _headerSource, msg.sender);  

        articles[keccak256(abi.encodePacked(_title, _content, _headerSource, msg.sender))] = article;  

        return true;  
    }

    function readArticle(string _id) public returns (bool success) {
        bytes32 _byteID = stringToBytes32(_id);

        require(articles[_byteID].UnspentOutputs[msg.sender] == 0, "Article already read");  
        require(articles[_byteID].Author != msg.sender, "Author cannot read own article");  

        emit ReadArticle(_byteID, articles[_byteID].Author, msg.sender, articles[_byteID].Title);  

        articles[_byteID].UnspentOutputs[msg.sender] = 1;  

        transfer(msg.sender, (balanceOf[this]/totalSupply)*2);  
        transfer(articles[_byteID].Author, (balanceOf[this]/totalSupply)*10);  

        return true;  
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);

        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}