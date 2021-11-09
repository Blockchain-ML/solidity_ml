pragma solidity ^0.4.25;

contract Proposal {
    
    mapping(address => uint) public balanceOf;
    mapping(address => uint) public partyOf;
    mapping(address => string) public usernames;
    proposal[] public proposals;
    statusLog[] public statusLogs;
    address[] public members;
    mapping(uint => address[]) public proposalOwners;  

    struct proposal {
        string title;
        string content;
        uint status;
    }

    struct statusLog {
        uint id;
        uint action;  
        uint date;
        address user;
    }

     

    function register(uint _party, string _username) public {
        require(_party == 1 || _party == 2 || _party == 3);
        partyOf[msg.sender] = _party;
        usernames[msg.sender] = _username;
        members.push(msg.sender);
    }
    
    function getMembersCount() public view returns(uint) {
        return members.length;
    }

    function getProposalsCount() public view returns(uint) {
        return proposals.length;
    }

    function getStatusLogCount() public view returns(uint) {
        return statusLogs.length;
    }

    function create(string _title, string _content) public {
        require(partyOf[msg.sender] == 1);
        uint id = proposals.length; 
        proposals.push(proposal(_title, _content, 1));
        balanceOf[msg.sender] += 1;
        statusLogs.push(statusLog(id, 0, now, msg.sender));
        proposalOwners[id].push(msg.sender);
        proposalOwners[id].push(address(0));
        proposalOwners[id].push(address(0));

    }

    function approve(uint _id, string _content) public {

         
        if (proposals[_id].status == 0) {
            require(partyOf[msg.sender] == 1 && proposalOwners[_id][0] == msg.sender);
            proposals[_id].status = 1;
        }
         
        else if (proposals[_id].status == 1) {
            if (proposalOwners[_id][1] == address(0)) {
                proposalOwners[_id][1] = msg.sender;
            }
            require(partyOf[msg.sender] == 2 && proposalOwners[_id][1] == msg.sender);
            proposals[_id].status = 2;
        }
         
        else if (proposals[_id].status == 2) {
            if (proposalOwners[_id][2] == address(0)) {
                proposalOwners[_id][2] = msg.sender;
            }
            require(partyOf[msg.sender] == 3 && proposalOwners[_id][2] == msg.sender);
            proposals[_id].status = 3;
        }

        statusLogs.push(statusLog(_id, 2, now, msg.sender));
        proposals[_id].content = _content;
        balanceOf[msg.sender] += 1;
    }

    function disapprove(uint _id, string _content) public {
         
        if (proposals[_id].status == 0 && proposalOwners[_id][0] == msg.sender) {
            require(partyOf[msg.sender] == 1);
            proposals[_id].status = 4;
        }
         
        if (proposals[_id].status == 1) {
            if (proposalOwners[_id][1] == address(0)) {
                proposalOwners[_id][1] = msg.sender;
            }
            require(partyOf[msg.sender] == 2 && proposalOwners[_id][1] == msg.sender);
            proposals[_id].status = 0;
        }
         
        if (proposals[_id].status == 2) {
            if (proposalOwners[_id][2] == address(0)) {
                proposalOwners[_id][2] = msg.sender;
            }
            require(partyOf[msg.sender] == 3 && proposalOwners[_id][2] == msg.sender);
            proposals[_id].status = 1;
        }

        statusLogs.push(statusLog(_id, 1, now, msg.sender));
        proposals[_id].content = _content;
        if (balanceOf[msg.sender] > 0) {
            balanceOf[msg.sender] -= 1;
        }
    }
}