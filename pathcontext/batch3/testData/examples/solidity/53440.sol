pragma solidity ^0.4.24;

contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

interface BankInterfaceForForwarder {
    function deposit(address _addr) external payable returns (bool);
    function migrationReceiver_setup() external returns (bool);
}

contract BankForwarder is Ownable {
    string public name = "BankForwarder";
    BankInterfaceForForwarder private currentCorpBank_;
    address private newCorpBank_;
    bool needsBank_ = true;

    constructor()
    public
    {
         
    }

    function()
    public
    payable
    {
         
         
        currentCorpBank_.deposit.value(address(this).balance)(address(currentCorpBank_));
    }

    function deposit()
    public
    payable
    returns(bool)
    {
        require(msg.value > 0, "Forwarder Deposit failed - zero deposits not allowed");
        require(needsBank_ == false, "Forwarder Deposit failed - no registered bank");
        if (currentCorpBank_.deposit.value(msg.value)(msg.sender) == true)
            return(true);
        else
            return(false);
    }

    function status()
    public
    view
    returns(address, address, bool)
    {
        return(address(currentCorpBank_), address(newCorpBank_), needsBank_);
    }

    function startMigration(address _newCorpBank)
    external
    returns(bool)
    {
         
        require(msg.sender == address(currentCorpBank_), "Forwarder startMigration failed - msg.sender must be current corp bank");

         
         
        if(BankInterfaceForForwarder(_newCorpBank).migrationReceiver_setup() == true)
        {
             
            newCorpBank_ = _newCorpBank;
            return (true);
        } else
            return (false);
    }

    function cancelMigration()
    external
    returns(bool)
    {
         
         
        require(msg.sender == address(currentCorpBank_), "Forwarder cancelMigration failed - msg.sender must be current corp bank");

         
        newCorpBank_ = address(0x0);

        return (true);
    }

    function finishMigration()
    external
    returns(bool)
    {
         
        require(msg.sender == newCorpBank_, "Forwarder finishMigration failed - msg.sender must be new corp bank");

         
        currentCorpBank_ = (BankInterfaceForForwarder(newCorpBank_));

         
        newCorpBank_ = address(0x0);

        return (true);
    }
     
     
     
     
    function setup(address _firstCorpBank) onlyOwner
    external
    {
        require(needsBank_ == true, "Forwarder setup failed - corp bank already registered");
        currentCorpBank_ = BankInterfaceForForwarder(_firstCorpBank);
        needsBank_ = false;
    }
}