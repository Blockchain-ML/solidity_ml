 

pragma solidity ^0.5.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity 0.5.16;

contract Storage {

  address public governance;
  address public controller;

  constructor() public {
    governance = msg.sender;
  }

  modifier onlyGovernance() {
    require(isGovernance(msg.sender), "Not governance");
    _;
  }

  function setGovernance(address _governance) public onlyGovernance {
    require(_governance != address(0), "new governance shouldn't be empty");
    governance = _governance;
  }

  function setController(address _controller) public onlyGovernance {
    require(_controller != address(0), "new controller shouldn't be empty");
    controller = _controller;
  }

  function isGovernance(address account) public view returns (bool) {
    return account == governance;
  }

  function isController(address account) public view returns (bool) {
    return account == controller;
  }
}

 

pragma solidity 0.5.16;


contract Governable {

  Storage public store;

  constructor(address _store) public {
    require(_store != address(0), "new storage shouldn't be empty");
    store = Storage(_store);
  }

  modifier onlyGovernance() {
    require(store.isGovernance(msg.sender), "Not governance");
    _;
  }

  function setStorage(address _store) public onlyGovernance {
    require(_store != address(0), "new storage shouldn't be empty");
    store = Storage(_store);
  }

  function governance() public view returns (address) {
    return store.governance();
  }
}

 

pragma solidity 0.5.16;


contract Controllable is Governable {

  constructor(address _storage) Governable(_storage) public {
  }

  modifier onlyController() {
    require(store.isController(msg.sender), "Not a controller");
    _;
  }

  modifier onlyControllerOrGovernance(){
    require((store.isController(msg.sender) || store.isGovernance(msg.sender)),
      "The caller must be controller or governance");
    _;
  }

  function controller() public view returns (address) {
    return store.controller();
  }
}

 

pragma solidity 0.5.16;

interface IController {
     
     
     
     
     
     
     
     
     
     
    function greyList(address _target) external view returns(bool);

    function addVaultAndStrategy(address _vault, address _strategy) external;
    function doHardWork(address _vault) external;
    function hasVault(address _vault) external returns(bool);

    function salvage(address _token, uint256 amount) external;
    function salvageStrategy(address _strategy, address _token, uint256 amount) external;

    function notifyFee(address _underlying, uint256 fee) external;
    function profitSharingNumerator() external view returns (uint256);
    function profitSharingDenominator() external view returns (uint256);
}

 

pragma solidity 0.5.16;




contract HardWorkHelper is Controllable {

  address[] public vaults;
  IERC20 public farmToken;

  constructor(address _storage, address _farmToken)
  Controllable(_storage) public {
    farmToken = IERC20(_farmToken);
  }

   
  function setVaults(address[] memory newVaults) public onlyGovernance {
    if (getNumberOfVaults() > 0) {
      for (uint256 i = vaults.length - 1; i > 0 ; i--) {
        delete vaults[i];
      }
       
      delete vaults[0];
    }
    vaults.length = 0;
    for (uint256 i = 0; i < newVaults.length; i++) {
      vaults.push(newVaults[i]);
    }
  }

  function getNumberOfVaults() public view returns(uint256) {
    return vaults.length;
  }

   
  function doHardWork() public {
    require(msg.sender == tx.origin, "Smart contracts cannot work hard");
    for (uint256 i = 0; i < vaults.length; i++) {
      IController(controller()).doHardWork(vaults[i]);
    }
     
    uint256 balance = farmToken.balanceOf(address(this));
    farmToken.transfer(msg.sender, balance);
  }
}