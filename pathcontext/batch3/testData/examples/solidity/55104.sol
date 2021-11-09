pragma solidity ^0.4.20;

library SafeMath  
{
    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        assert(b <= a);

        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }
}

contract OwnerHelper  
{
    address public owner;  

    event OwnerTransferPropose(address indexed _from, address indexed _to);  

    modifier onlyOwner  

    {
        require(msg.sender == owner);  
        _;  
    }

    function OwnerHelper () public  
    {
        owner = msg.sender; 
    }

    function transferOwnership(address _to) onlyOwner public
    {
        require(_to != owner);   
        require(_to != address(0x0)); 
        owner = _to;
        OwnerTransferPropose(owner, _to);
    }
}

contract ERC20Interface  
		            	 
            			 
{
    event Transfer( address indexed _from, address indexed _to, uint _value);  
    event Approval( address indexed _owner, address indexed _spender, uint _value);  
    event Burn ( address indexed _from, uint _value);    

    function totalSupply() constant public returns (uint _supply);  
    function balanceOf( address _who ) constant public returns (uint _value);  
    function transfer( address _to, uint _value) public returns (bool _success);  
    function approve( address _spender, uint _value ) public returns (bool _success);  
    function allowance( address _owner, address _spender ) constant public returns (uint _allowance);  
    function transferFrom( address _from, address _to, uint _value) public returns (bool _success);  
}

contract HyunJaeToken is ERC20Interface, OwnerHelper  
{
    using SafeMath for uint256;  
    
    string public name;  
    uint public decimals;  
    string public symbol;  
    uint public totalSupply;  
    address public wallet;  
    
    uint public maxSupply;
    uint public mktSupply;
    uint public devSupply;
    uint public saleSupply;

    uint public tokenIssuedSale;  
    uint public tokenIssuedMkt;  
    uint public tokenIssuedDevelop;  

    uint public saleEtherReceived;

    uint public saleTokenLeft;
    
    uint private E18 = 1000000000000000000;  
    uint public ethPerToken = 4000;  
    uint public privateSaleBonus = 50;
    uint public preSalePrimaryBonus = 30;
    uint public presaleSecondBonus = 20;
    uint public crowdSalePrimaryBonus = 10;
    uint public crowdSaleSecondBonus = 0;

    uint public privateSaleStartDate;  
    uint public privateSaleEndDate;  
    
    uint public preSalePrimaryStartDate;  
    uint public preSalePrimaryEndDate;  
    
    uint public preSaleSecondStartDate;  
    uint public preSaleSecondEndDate;  
    
    uint public crowdSalePrimaryStartDate;  
    uint public crowdSalePrimaryEndDate;  
    
    uint public crowdSaleSecondStartDate;  
    uint public crowdSaleSecondEndDate;  
    
    bool public tokenLock;  
    
    mapping (address => uint) internal balances;  
    mapping (address => mapping ( address => uint )) internal approvals;  

    mapping (address => bool) internal personalLock;
    mapping (address => uint) internal icoEtherContributeds;  
    
    event RemoveLock(address indexed _who);  
    event WithdrawMkt(address indexed _to, uint _value);  

    function HyunJaeToken () public
    {
        name = "HyunJaeToken";  
        decimals = 18;  
        symbol = "HJ";  
        totalSupply = 0;  
	
    	owner = msg.sender;  
    	wallet = msg.sender;  
	
	    maxSupply = 100000000 * E18;
        mktSupply =  20000000 * E18;
        devSupply = 20000000 * E18;
        saleSupply = 60000000 * E18;

        tokenIssuedSale = 0;
        tokenIssuedMkt = 0;
        tokenIssuedDevelop = 0;
        
	    saleEtherReceived = 0;  
    
        tokenLock = true;
         
        privateSaleStartDate = 1528070400;  
        privateSaleEndDate = 1528588800;  
    
        preSalePrimaryStartDate = 1528675200;  
        preSalePrimaryEndDate = 1528934400;  
    
        preSaleSecondStartDate = 1529020800;  
        preSaleSecondEndDate = 1529280000;  
    
        crowdSalePrimaryStartDate = 1529366400;  
        crowdSalePrimaryEndDate = 1529625600;  
    
        crowdSaleSecondStartDate = 1529712000;  
        crowdSaleSecondEndDate = 1529971200;  
    }
    
    function atNow() public constant returns(uint) 
    {
        return now;  
    }
    
    function () payable public  
    {
        buyToken();
    }
    
    function buyToken() private
    {
        require(saleSupply > tokenIssuedSale);  
        
        uint saleType = 0;    
        uint saleBonus = 0;   

    	uint minEth = 1 ether;  
    	uint maxEth = 300 ether;  
        
        uint nowTime = atNow();  

        if(nowTime >= privateSaleStartDate && nowTime < privateSaleEndDate)
        {
            saleType = 1;
            saleBonus = privateSaleBonus;
        }
        else if(nowTime >= preSalePrimaryStartDate && nowTime < preSalePrimaryEndDate)
        {
            saleType = 2;
            saleBonus = preSalePrimaryBonus;
        }
        else if(nowTime >= preSaleSecondStartDate && nowTime < preSaleSecondEndDate)
        {
            saleType = 3;
            saleBonus = presaleSecondBonus;
        }
         else if(nowTime >= crowdSalePrimaryStartDate && nowTime < crowdSalePrimaryEndDate)
        {
            saleType = 4;
            saleBonus = crowdSalePrimaryBonus;
        }
        else if(nowTime >= crowdSaleSecondStartDate && nowTime < crowdSaleSecondEndDate)
        {
            saleType = 5;
            saleBonus = crowdSaleSecondBonus;
        }
        
        require (saleType >= 1 && saleType <= 5);	 

        require (msg.value >= minEth && icoEtherContributeds[msg.sender].add(msg.value) <= maxEth); 	 
	
        uint tokens = ethPerToken.mul(msg.value);  
        tokens = tokens.mul(100 + saleBonus) / 100;  
        
        require (saleSupply >= tokenIssuedSale.add(tokens));  

        tokenIssuedSale = tokenIssuedSale.add(tokens);  
    	totalSupply = totalSupply.add(tokens);  
    	saleEtherReceived = saleEtherReceived.add(msg.value);  
       
	    balances[msg.sender] = balances[msg.sender].add(tokens);  
	    icoEtherContributeds[msg.sender] = icoEtherContributeds[msg.sender].add(msg.value);  
	    personalLock[msg.sender] = true;  

        Transfer(0x0, msg.sender, tokens);  
        
        wallet.transfer(address(this).balance);  

    }

    function isTokenLock(address _from, address _to) constant public returns (bool _success) 
    {
    	_success = false;
	
    	if (tokenLock == true)
    	{
    	   _success = true;
    	}
	
    	if (personalLock[_from] == true || personalLock[_to] == true )
    	{
	       _success = true;
    	}
	
	    return _success;
    }

    function isPeronalLock(address _who) constant public returns (bool)
    {
        return personalLock[_who];
    }
    
    function removeTokenLock() onlyOwner public
    {
        require(tokenLock == true);
        
        tokenLock = false;

    	RemoveLock(0x0);
    }

    function removePersonalTokenLock(address _person) onlyOwner public 
    {
    	require(personalLock[_person] == true);
	
        personalLock[_person] = false;
	
	    RemoveLock(_person);
    }

    function totalSupply() constant public returns (uint)
    { 
        return totalSupply;  
    }
    
    function balanceOf(address _who) constant public returns (uint) 
    {
        return balances[_who];  
    }
    
    function transfer(address _to, uint _value) public returns (bool) 
    {
        require(balances[msg.sender] >= _value);  
        require(isTokenLock(msg.sender,_to) == true);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);  
        balances[_to] = balances[_to].add(_value);  
        
        Transfer(msg.sender, _to, _value);  
        
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool)
    {
        require(balances[msg.sender] >= _value);  
        
        approvals[msg.sender][_spender] = _value;  
        
        Approval(msg.sender, _spender, _value);  
        
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint) 
    {
        return approvals[_owner][_spender];  
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool)  
    {
        require(balances[_from] >= _value);  
        require(approvals[_from][msg.sender] >= _value);  
        require(isTokenLock(_from,_to) == true); 
        
        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);  
        balances[_from] = balances[_from].sub(_value);  
        balances[_to]  = balances[_to].add(_value);  
        
        Transfer(_from, _to, _value);  
        
        return true;
    }
    
    function minMktTokens(address _to, uint _value) public onlyOwner 
    {
        require(mktSupply > tokenIssuedMkt);
        require(mktSupply > tokenIssuedMkt.add(_value));
        
        balances[_to] = balances[_to].add(_value);
        tokenIssuedMkt = tokenIssuedMkt.add(_value);
        totalSupply = totalSupply.add(_value);
        personalLock[_to] = true;
        
        Transfer(0x0, _to, _value);
    }
    
    function withdrawDevTokens(address _to, uint _value) public onlyOwner  
    {
        require(devSupply > tokenIssuedDevelop);  
        require(devSupply > tokenIssuedDevelop.add(_value));
        
        balances[_to] = balances[_to].add(_value);  
        tokenIssuedMkt = tokenIssuedMkt.add(_value);  
        totalSupply = totalSupply.add(_value); 
        personalLock[_to] = true;
        
        Transfer(0x0, _to, _value);
    }
    
    function isIcoFinshed() public constant returns (bool)
    {
        uint nowTime = atNow();
        
        if(crowdSaleSecondEndDate < nowTime)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    function checkLeftToken() public returns (uint)
    {
        require(isIcoFinshed() == true);
        saleTokenLeft = saleSupply.sub(tokenIssuedSale);
        return saleTokenLeft;
        
    }
    function airdrop(address[] _to, uint[] value) public onlyOwner 
    {
        uint valueSum=0;

        for(uint i=0; i<= value.length; i++){
            valueSum +=  value[i];
        }

        require(saleSupply >= valueSum);

        for(uint j=0; j<= _to.length; j++) {
            transfer(_to[j], value[j]);
            Transfer(owner,_to[j], value[j]);
        }
    }

    function burn(uint256 _value) public returns (bool _success)
    {
        require(isIcoFinshed() == true);
        
       	require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);

        Burn(msg.sender, _value);

        return true;
    }

}