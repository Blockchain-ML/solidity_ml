pragma solidity ^0.4.25;

 
contract EasySmartolution {

    event ParticipantAdded(address _sender);
    event ParticipantRemoved(address _sender);
    event ReferrerAdded(address _contract, address _sender);

    mapping (address => address) public participants; 
    mapping (address => bool) public referrers;
    
    address private processing;
 
    constructor(address _processing) public {
        processing = _processing;
    }
    
    function () external payable {
        if (participants[msg.sender] == address(0)) {
            addParticipant(msg.sender, address(0));
        } else {
            require(msg.value == 0, "0 ether to manually make a daily payment");

            processPayment(msg.sender);
        }
    }
    
    function addParticipant(address _address, address _referrer) payable public {
        require(participants[_address] == address(0), "This participant is already registered");
        require(msg.value >= 0.45 ether && msg.value <= 225 ether, "Deposit should be between 0.45 ether and 225 ether (45 days)");
        
        participants[_address] = address(new Participant(_address, msg.value / 45));
        processPayment(_address);
        
        processing.send(msg.value / 20);
        if (_referrer != address(0) && referrers[_referrer]) {
            _referrer.send(msg.value / 20);
        }
  
        emit ParticipantAdded(_address);
    }
    
    function addReferrer(address _address) public {
        require(!referrers[_address], "This address is already a referrer");
        
        referrers[_address] = true;
        EasySmartolutionRef refContract = new EasySmartolutionRef(address(this));
        refContract.setReferrer(_address);
        emit ReferrerAdded(address(refContract), _address);
    }

    function processPayment(address _address) public {
        Participant participant = Participant(participants[_address]);

        bool done = participant.processPayment.value(participant.daily())();
        
        if (done) {
            participants[_address] = address(0);
            emit ParticipantRemoved(_address);
        }
    }
}

contract EasySmartolutionRef {
    address public referrer;
    address public smartolution;
    
    constructor (address _smartolution) public {
        smartolution = _smartolution;
    }

    function setReferrer(address _referrer) external {
        require(referrer == address(0), "referrer can only be set once");
        referrer = _referrer;
    }

    function () external payable {
        if (msg.value > 0) {
            EasySmartolution(smartolution).addParticipant.value(msg.value)(msg.sender, referrer);
        } else {
            EasySmartolution(smartolution).processPayment(msg.sender);
        }
    }
}

contract Participant {
    address constant smartolution = 0x1d6a75f80ea651755381b5038d1158970ddcd139;

    address public owner;
    uint public daily;
    
    constructor(address _owner, uint _daily) public {
        owner = _owner;
        daily = _daily;
    }
    
    function () external payable {}
    
    function processPayment() external payable returns (bool) {
        require(msg.value == daily, "Invalid value");
        
        uint indexBefore;
        uint index;
        (,indexBefore,) = SmartolutionInterface(smartolution).users(address(this));
        smartolution.call.value(msg.value)();
        (,index,) = SmartolutionInterface(smartolution).users(address(this));

        require(index != indexBefore, "Smartolution rejected that payment, too soon or not enough ether");
    
        owner.send(address(this).balance);

        return index == 45;
    }
}

contract SmartolutionInterface {
    struct User {
        uint value;
        uint index;
        uint atBlock;
    }

    mapping (address => User) public users; 
}

contract Smartolution {
    struct User {
        uint value;
        uint index;
        uint atBlock;
    }

    mapping (address => User) public users;
    
    uint public total;
    uint public advertisement;
    uint public team;
   
    address public teamAddress;
    address public advertisementAddress;

    constructor(address _advertisementAddress, address _teamAddress) public {
        advertisementAddress = _advertisementAddress;
        teamAddress = _teamAddress;
    }

    function () public payable {
        require(msg.value == 0.00001111 ether || (msg.value >= 0.01 ether && msg.value <= 5 ether), "Min: 0.01 ether, Max: 5 ether, Exit: 0.00001111 eth");

        User storage user = users[msg.sender];  

        if (msg.value != 0.00001111 ether) {
            total += msg.value;                  
            advertisement += msg.value / 30;     
            team += msg.value / 200;             
            
            if (user.value == 0) { 
                user.value = msg.value;
                user.atBlock = block.number;
                user.index = 1;     
            } else {
                require(msg.value == user.value, "Amount should be the same");
                 

                uint idx = ++user.index;
                
                if (idx == 45) {
                    user.value = 0;  
                } else {
                     
                     
                     
                        user.atBlock += 5900;
                     
                        user.atBlock = block.number - 984;
                     
                }

                 
                msg.sender.transfer(msg.value * idx * idx * (24400 - 500 * msg.value / 1 ether) / 10000000);
            }
        } else {
            require(user.index <= 10, "It&#39;s too late to request a refund at this point");

            msg.sender.transfer(user.index * user.value * 70 / 100);
            user.value = 0;
        }
        
    }

      
    function claim(uint amount) public {
        if (msg.sender == advertisementAddress) {
            require(amount > 0 && amount <= advertisement, "Can&#39;t claim more than was reserved");

            advertisement -= amount;
            msg.sender.transfer(amount);
        } else 
        if (msg.sender == teamAddress) {
            require(amount > 0 && amount <= team, "Can&#39;t claim more than was reserved");

            team -= amount;
            msg.sender.transfer(amount);
        }
    }
}