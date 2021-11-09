pragma solidity ^0.4.21;

contract ERC223ReceivingContract { 
 
    function tokenFallback(address _from, uint _value, bytes _data) public;
    function tokenFallback(address _from, uint _value, bytes _data, string _stringdata, uint256 _numdata ) public;  
}


contract tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}

 
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
         
        uint256 c = a / b;
         
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Crownable {

	using SafeMath for uint8;

    event NewCrown(address crown);
	event NewManager(address manager);
	event NewMinter(address minter);
	event ManagerRemoved(address manager);
    event NewTreasurer(address treasurer);
    
    struct Vote {
        address[3] voted;
        uint8 voteCount;
    }
	
	mapping(address => bool) manager;
	mapping(address => Vote) proposal;
	
	address public minter;
	address public crown;
	address public treasurer;
	
	address public firstLord;
	address public secondLord;
	address public thirdLord;

	uint256 managerCount;

	constructor(address fLord, address sLord, address tLord) public {
	    crown = msg.sender;
	    firstLord = fLord;
	    secondLord = sLord;
	    thirdLord = tLord;
	}

	modifier onlyManager() {
		require(manager[msg.sender] == true);
		_;
	}

	modifier onlyMinter() {
		require( minter == msg.sender);
		_;
	}
	
	modifier onlyCrown() {
		require( crown == msg.sender );
		_;
	}
	
	modifier onlyTreasurer() {
		require( treasurer == msg.sender );
		_;
	}
	
	modifier onlyLord() {
	    require((msg.sender == firstLord) || (msg.sender == secondLord) || (msg.sender == thirdLord));
	    _;
	}
	
	function setMinter(address newMinter) public onlyCrown {
		require(newMinter != address(0));
		minter = newMinter;
		emit NewMinter(newMinter);
	}

    function setTreasurer(address newTreasurer) public onlyCrown {
		require(newTreasurer != address(0));
		treasurer = newTreasurer;
		emit NewMinter(newTreasurer);
	}

	function addManager(address newManager) public onlyCrown {
		require(newManager != address(0));
		managerCount++;
		manager[newManager] = true;
		emit NewManager(newManager);
	}

    function removeManager(address managerAddress) public onlyCrown {
		require(managerCount > 1);
		managerCount--;
		manager[managerAddress] = false;
		emit ManagerRemoved(managerAddress);
	}
	
	function changeCrown(address newCrown) public onlyLord {
	    require(newCrown != 0x0);
	    
	     
	    for (uint256 i=0; i<proposal[newCrown].voted.length-1; i++) {
	        if (msg.sender == proposal[newCrown].voted[i]) {
	            revert();
	        }    
	    }
	    
	     
	    for (uint256 a=0; a<proposal[newCrown].voted.length-1; a++) {
	        if (proposal[newCrown].voted[a] == 0x0) {
	            proposal[newCrown].voted[a] = msg.sender;
	            proposal[newCrown].voteCount++;
	            if (proposal[newCrown].voteCount == 2) {
	                crown = newCrown;
	                emit NewCrown(newCrown);
	                break;
	            } else {
	                break;
	            }
	        }
	    }
	}
}


contract Mintable {
    
    mapping ( uint256 => address ) public mintRequestBeneficiary;
    mapping ( uint256 => uint256 ) public mintRequestAmount;
    mapping ( uint256 => bool )    public mintRequestApproval;
    mapping ( uint256 => bool )    public mintRequestCompleted;
    mapping ( uint256 => uint256 ) public mintRequestSequence;
    
    uint256 public mintSequence;
    
    
    
}


contract KTC is Crownable, Mintable  {

    using SafeMath for uint256;
     
    string public constant name = "Kryptonite Trade Coin";
    string public constant symbol = "KTC";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public initialSupply;

    mapping( address => uint256) public balanceOf;
    mapping( address => mapping(address => uint256)) public allowance;
    
    


     
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
    event Transfer(address indexed from, address indexed to, uint value, bytes data, string _stringdata, uint256 _numdata );
    event Approval(address indexed owner, address indexed spender, uint value);

     
    event Burn(address indexed from, uint256 value);
    event Minted(address indexed to, uint256 value);

     
    constructor(uint256 supply, address fLord, address sLord, address tLord) public Crownable(fLord, sLord, tLord) {
        initialSupply = 10**uint256(decimals)*supply; 
        balanceOf[msg.sender] = initialSupply;  
        totalSupply = initialSupply;  
        manager [ msg.sender ] = true;
        managerCount = 1;
    }

    function balanceOf(address tokenHolder) public constant returns(uint256) {
        return balanceOf[tokenHolder];
    }

    function totalSupply() public constant returns(uint256) {
        return totalSupply;
    }


    function transfer(address _to, uint256 _value) public returns(bool ok) {
        require(_to != 0x0);  
        require(balanceOf[msg.sender] >= _value);  
        bytes memory empty;
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(  _value );  
        balanceOf[_to] = balanceOf[_to].add( _value );  
        
         if(isContract( _to )) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        
        emit Transfer(msg.sender, _to, _value);  
        return true;
    }
    
    function transfer(address _to, uint256 _value, bytes _data ) public returns(bool ok) {
        require(_to != 0x0);  
        require(balanceOf[msg.sender] >= _value);  
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(  _value );  
        balanceOf[_to] = balanceOf[_to].add( _value );  
        
         if(isContract( _to )) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        
        emit Transfer(msg.sender, _to, _value, _data);  
        return true;
    }
    
    function transfer(address _to, uint256 _value, bytes _data, string _stringdata, uint256 _numdata ) public returns(bool ok) {
        require(_to != 0x0);  
        require(balanceOf[msg.sender] >= _value);  
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(  _value );  
        balanceOf[_to] = balanceOf[_to].add( _value );  
        
         if(isContract( _to )) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data, _stringdata, _numdata);
        }
        
        emit Transfer(msg.sender, _to, _value, _data , _stringdata, _numdata );  
        return true;
    }
    
    function isContract( address _to ) internal view returns ( bool ){
        uint codeLength = 0;
        
        assembly {
             
            codeLength := extcodesize(_to)
        }
        
        if(codeLength>0) {
            return true;
        }
        
        return false;
        
    }
    
     
    function approve(address _spender, uint256 _value) public returns(bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval( msg.sender ,_spender, _value);
        return true;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
        return allowance[_owner][_spender];
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
        require(_from != 0x0);  
        require(balanceOf[_from] >= _value);  
        require(_value <= allowance[_from][msg.sender]);  
        balanceOf[_from] = balanceOf[_from].sub( _value );  
        balanceOf[_to] = balanceOf[_to].add( _value );  
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub( _value ); 
        emit Transfer(_from, _to, _value);
        return true;
    }
  
    function burn(uint256 _value) public returns(bool success) {
        require(balanceOf[msg.sender] >= _value);  
        require( (totalSupply - _value) >=  ( initialSupply / 2 ) );
        balanceOf[msg.sender] = balanceOf[msg.sender].sub( _value );  
        totalSupply = totalSupply.sub( _value );  
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns(bool success) {
        require(_from != 0x0);  
        require(balanceOf[_from] >= _value); 
        require(_value <= allowance[_from][msg.sender]); 
        balanceOf[_from] = balanceOf[_from].sub( _value ); 
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub( _value ); 
        totalSupply = totalSupply.sub( _value );  
        emit Burn(_from, _value);
        return true;
    }

    function mint(address _to, uint256 _amount) internal onlyTreasurer {
    	require(_to != 0x0);
    	balanceOf[_to].add(_amount);
    	emit Minted(_to, _amount);
    }
    
    function mintRequest ( address _to, uint256 _amount, uint256 _mintrequest ) public onlyTreasurer {
        mintSequence ++;
        mintRequestBeneficiary[ mintSequence ] = _to;
        mintRequestAmount[ mintSequence ] = _amount;
        mintRequestAmount[ mintSequence ] = _amount;
        mintRequestSequence[ _mintrequest ] = mintSequence;
    }
    
    function mintApprove ( uint256 _mintRequest ) public onlyMinter {
        require ( mintRequestSequence[ _mintRequest ] != 0 );
        mintRequestApproval[mintRequestSequence[ _mintRequest ]] = true;
    }
    
    function mintComplete ( uint256 _mintRequest ) public onlyTreasurer {
        require ( mintRequestSequence[ _mintRequest ] != 0 );
        mintRequestCompleted[mintRequestSequence[ _mintRequest ]] = true;
        mint (  mintRequestBeneficiary[mintRequestSequence[ _mintRequest ]] , mintRequestAmount[mintRequestSequence[ _mintRequest ]] );
    }
}

contract Fabric is Crownable {
    
    constructor(address fLord, address sLord, address tLord) public Crownable(fLord, sLord, tLord) {}
    
    function createNewContract(uint256 supply, address fLord, address sLord, address tLord) public returns (address) {
        return new KTC(supply, fLord, sLord, tLord);
    }
    
}