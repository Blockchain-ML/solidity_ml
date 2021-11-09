pragma solidity ^0.4.8;

contract Auction {
     
    address public owner;
    uint public bidIncrement;
    uint public startTime;
    uint public endTime;

     
    bool public canceled;
    uint public highestBindingBid;
    address public highestBidder;
    mapping(address => uint256) public fundsByBidder;
    bool ownerHasWithdrawn;

    event LogBid(address bidder, uint bid, address highestBidder, uint highestBid, uint highestBindingBid);
    event LogWithdrawal(address withdrawer, address withdrawalAccount, uint amount);
    event LogCanceled();

    constructor(address _owner, uint duration) public {
        require(_owner != 0x0);

        owner = _owner;
        bidIncrement = 1;
        startTime = block.timestamp;
        endTime = block.timestamp + duration;
    }

    function getHighestBid()
        public
        constant
        returns (uint)
    {
        return fundsByBidder[highestBidder];
    }

    function placeBid()
        public
        payable
        onlyBeforeEnd
        onlyNotCanceled
        onlyNotOwner
        returns (bool success)
    {
         
        require(msg.value != 0);

         
         
        uint newBid = fundsByBidder[msg.sender] + msg.value;

         
         
        require(newBid > highestBindingBid);

         
         
        uint highestBid = fundsByBidder[highestBidder];

        fundsByBidder[msg.sender] = newBid;

        if (newBid <= highestBid) {
             
             

             
             

            highestBindingBid = min(newBid + bidIncrement, highestBid);
        } else {
             
             

             
             

            if (msg.sender != highestBidder) {
                highestBidder = msg.sender;
                highestBindingBid = min(newBid, highestBid + bidIncrement);
            }
            highestBid = newBid;
        }

        emit LogBid(msg.sender, newBid, highestBidder, highestBid, highestBindingBid);
        return true;
    }

    function min(uint a, uint b)
        private
        constant
        returns (uint)
    {
        if (a < b) return a;
        return b;
    }

    function cancelAuction()
        public
        onlyOwner
        onlyBeforeEnd
        onlyNotCanceled
        returns (bool success)
    {
        canceled = true;
        emit LogCanceled();
        return true;
    }

    function endAuction()
        public
        onlyOwner
        onlyBeforeEnd
        onlyNotCanceled
        returns (bool success)
    {
        endTime = block.timestamp;
        return true;
    }

    function withdraw()
        public
        onlyEndedOrCanceled
        returns (bool success)
    {
        address withdrawalAccount;
        uint withdrawalAmount;

        if (canceled) {
             
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];

        } else {
             

            if (msg.sender == owner) {
                 
                withdrawalAccount = highestBidder;
                withdrawalAmount = highestBindingBid;
                ownerHasWithdrawn = true;

            } else if (msg.sender == highestBidder) {
                 
                 
                withdrawalAccount = highestBidder;
                if (ownerHasWithdrawn) {
                    withdrawalAmount = fundsByBidder[highestBidder];
                } else {
                    withdrawalAmount = fundsByBidder[highestBidder] - highestBindingBid;
                }

            } else {
                 
                 
                withdrawalAccount = msg.sender;
                withdrawalAmount = fundsByBidder[withdrawalAccount];
            }
        }

        require(withdrawalAmount != 0);

        fundsByBidder[withdrawalAccount] -= withdrawalAmount;

         
        require(msg.sender.send(withdrawalAmount));

        emit LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);

        return true;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyNotOwner {
        require(msg.sender != owner);
        _;
    }

    modifier onlyBeforeEnd {
        require(block.timestamp > endTime);
        _;
    }

    modifier onlyNotCanceled {
        require(!canceled);
        _;
    }

    modifier onlyEndedOrCanceled {
        require((block.timestamp > endTime) || canceled);
        _;
    }
}