 

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

contract ChargingPoint {
	address public owner;
	uint256 public priceForTime;
	string public pointIdentifier;

	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    event enablePoint (
		string pointIdentifier,
		uint256 time
	);

	event updateBalance (string pointIdentifier);
	event updatePrice  (string pointIdentifier);

    constructor(string _pointIdentifier,uint256 _priceForTime)
    public
    {
		owner= msg.sender;
		priceForTime=_priceForTime;
		pointIdentifier=_pointIdentifier;
	}

	function ()
	public payable
	{
	    	uint256 payment=msg.value;
			if (priceForTime!=0)
			{
    			uint chargeTime=SafeMath.div(payment, priceForTime);
    			emit enablePoint(pointIdentifier,chargeTime);
			}
	}

	function takeMoney()
	public payable onlyOwner
	{
			uint balance = address(this).balance;
			owner.transfer(balance);
			emit updateBalance(pointIdentifier);
	}

	function setPrice(uint256 _priceForTime)
	public onlyOwner
	{
			priceForTime=_priceForTime;
			emit updatePrice(pointIdentifier);
	}

    function setPointIdentifier(string _pointIdentifier)
	public onlyOwner
	{
			pointIdentifier=_pointIdentifier;
	}

}