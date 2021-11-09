pragma solidity ^0.4.22;

contract Auction {

    address public owner;

    uint public minBid = 0.1 ether;
    uint public minBidIncrease = 0.1 ether;

    uint public gasLimit = 2300;
    uint public gasPrice = 4 * 1000000000;  

     
    uint public newEnd;
    uint public newBid;
    string public newTargetUrl;
    string public newImageUrl;
    string public newImageTitle;
    string public newEmail;
    address public newLeader;

    uint public currentEnd;
    uint public currentBid;
    string public currentTargetUrl;
    string public currentImageUrl;
    string public currentImageTitle;
    string public currentEmail;
    address public currentLeader;

     
    mapping(address => uint) public balances;

     
    bool stopped;

    uint public duration = 60 * 1 minutes;

     
     

    event Updated(address bidder, uint amount);
    event Started();
    event Stopped();
    event Restarted(address winner, uint amount);

     
     

     
     

     
    constructor() public {
        owner = msg.sender;
    }

    function balanceOf(address _address) view public returns(uint256) {
        return balances[_address];
    }

    function editGas(uint _gasLimit, uint _gasPrice) public {
        require(msg.sender == owner, "Gas can be edited by owner only");
        gasLimit = _gasLimit;
        gasPrice = _gasPrice;
    }

    function editLimits(uint _minBid, uint _minBidIncrease) public {
        require(msg.sender == owner, "Limits can be edited by owner only");
        minBid = _minBid;
        minBidIncrease = _minBidIncrease;
    }

    function editBalanceOf(address _address, uint _amount) public {
        require(msg.sender == owner, "Balances can be edited by owner only");
        balances[_address] = _amount;
    }

    function editDuration(uint _duration) public {
        require(msg.sender == owner, "Auction duration can be edited by owner only");
        duration = _duration;
    }

    function edit(
        uint _newEnd,
        address _newLeader,
        uint _newBid,
        string _newTargetUrl,
        string _newImageUrl,
        string _newImageTitle,
        string _newEmail,
        uint _currentEnd,
        address _currentLeader,
        uint _currentBid,
        string _currentTargetUrl,
        string _currentImageUrl,
        string _currentImageTitle,
        string _currentEmail) public {

        currentEnd = _currentEnd;
        currentBid = _currentBid;
        currentTargetUrl = _currentTargetUrl;
        currentImageUrl = _currentImageUrl;
        currentImageTitle = _currentImageTitle;
        currentEmail = _currentEmail;
        currentLeader = _currentLeader;
        newEnd = _newEnd;
        newBid = _newBid;
        newTargetUrl = _newTargetUrl;
        newImageUrl = _newImageUrl;
        newImageTitle = _newImageTitle;
        newEmail = _newEmail;
        newLeader = _newLeader;
    }

     
    function bid(string targetUrl, string imageUrl, string imageTitle, string email) public payable {

        require (!stopped, "The auction is stopped.");

        restart ();

        uint amount = balances[msg.sender];
        amount += msg.value;

        require(amount >= minBid, "Bid is less than the minimum required to participate.");

        if (msg.sender != newLeader) {

             
             

            require(amount >= (newBid + minBidIncrease), "There already is a higher bid.");
        }

         
         
         
         
        balances[msg.sender] = amount;

         
        newBid = balances[msg.sender];
        newLeader = msg.sender;
        newTargetUrl = targetUrl;
        newImageUrl = imageUrl;
        newImageTitle = imageTitle;
        newEmail = email;

        emit Updated(msg.sender, amount);
    }

     
    function withdraw(address to, uint amount) public {

        require(msg.sender != owner, "Funds can be withdrawn by the contract owner only");
        if (!to.send(amount)) {
             
        }
    }

     
    function refund() public returns (bool) {

        if (!stopped) {

             
             
            require(msg.sender != newLeader, "Funds can be refunded by non-leading bidders only.");

        }

        uint amount = balances[msg.sender];
        uint gasCost = gasLimit * gasPrice;
        require(amount >= gasCost, "Amount payable is less than tx fees.");
        uint amountToSend = amount - gasCost;
         
         
         
        balances[msg.sender] = 0;
        if (!msg.sender.send(amountToSend)) {
             
             
            balances[msg.sender] = amountToSend;
            return false;
        }

        return true;
    }

    function start() public {

        require(msg.sender == owner, "Auction can be started by owner only.");
        require(stopped, "Auction has already been started.");
        stopped = false;
        restart ();
        emit Started();
    }

    function stop() public {

        require(msg.sender == owner, "Auction can be stopped by owner only.");
        require(!stopped, "Auction has already been stopped.");
        stopped = true;
        emit Stopped();
    }

    function update() public {
        require(msg.sender == owner, "Auction can be updated by owner only.");
        require(!stopped, "Auction has been stopped.");
        restart ();
    }

     
     

    function restart () internal {

         
        if (now > newEnd) {

            balances[currentLeader] = 0;

             
            currentEnd = newEnd;
            currentBid = newBid;
            currentTargetUrl = newTargetUrl;
            currentImageUrl = newImageUrl;
            currentImageTitle = newImageTitle;
            currentEmail = newEmail;
            currentLeader = newLeader;

            newEnd = now + duration;
            newBid = 0;
            newTargetUrl = "";
            newImageUrl = "";
            newImageTitle = "";
            newEmail = "";
            newLeader = 0x0;

             
            emit Restarted(currentLeader, currentBid);
        }
    }
}