pragma solidity ^0.4.24;

 
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

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract TokenHandler is Ownable {

    address public targetToken;

    constructor ( address _targetToken) public Ownable() {
        setTargetToken(_targetToken);
    }

    function getTokenBalance(address _token) public view returns (uint256) {
        ERC20Basic token = ERC20Basic(_token);
        return token.balanceOf(address(this));
    }

    function setTargetToken (address _targetToken) public onlyOwner returns (bool) {
      require(targetToken == 0x0);
      targetToken = _targetToken;
      return true;
    }

    function _transfer (address _token, address _recipient, uint256 _value) internal {
        ERC20Basic token = ERC20Basic(_token);
        token.transfer(_recipient, _value);
    }
}

contract TokenDistributor is TokenHandler {
    using SafeMath for uint;

    address[] public stakeHolders;
    uint256 public maxStakeHolders;
    event InsufficientTokenBalance( address indexed _token, uint256 _time );
    event TokensDistributed( address indexed _token, uint256 _total, uint256 _time );

    constructor ( address _targetToken, uint256 _totalStakeHolders, address[] _stakeHolders) public
    TokenHandler(_targetToken) {
        maxStakeHolders = _totalStakeHolders;
        if (_stakeHolders.length > 0) {
            for (uint256 count = 0; count < _stakeHolders.length && count < _totalStakeHolders; count++) {
                if (_stakeHolders[count] != 0x0) {
                    _setStakeHolder(_stakeHolders[count]);
                }
            }
        }
    }

    function isDistributionDue (address _token) public view returns (bool) {
        return getTokenBalance(_token) > 1;
    }

    function isDistributionDue () public view returns (bool) {
        return getTokenBalance(targetToken) > 1;
    }

    function countStakeHolders () public view returns (uint256) {
        return stakeHolders.length;
    }

    function getPortion (uint256 _total) public view returns (uint256) {
        return _total.div(stakeHolders.length);
    }

    function _setStakeHolder (address _stakeHolder) internal onlyOwner returns (bool) {
        require(countStakeHolders() < maxStakeHolders, "Max StakeHolders set");
        stakeHolders.push(_stakeHolder);
        return true;
    }

    function _distribute (address _token) internal returns (bool) {
        uint256 balance = getTokenBalance(_token);
        uint256 perStakeHolder = getPortion(balance);

        if (balance < 1) {
            emit InsufficientTokenBalance(_token, block.timestamp);
            return false;
        } else {
            for (uint256 count = 0; count < stakeHolders.length; count++) {
                _transfer(_token, stakeHolders[count], perStakeHolder);
            }

            uint256 newBalance = getTokenBalance(_token);
            if (newBalance > 0 && getPortion(newBalance) == 0) {
                _transfer(_token, owner, newBalance);
            }

            emit TokensDistributed(_token, balance, block.timestamp);
            return true;
        }
    }

    function distribute () public returns (bool) {
        require(targetToken != 0x0);
        return _distribute(targetToken);
    }

    function () public {
        distribute();
    }
}

contract WeightedTokenDistributor is TokenDistributor {
    using SafeMath for uint;

    mapping( address => uint256) public stakeHoldersWeight;

    constructor ( address _targetToken, uint256 _totalStakeHolders, address[] _stakeHolders, uint256[] _weights) public
    TokenDistributor(_targetToken, _totalStakeHolders, stakeHolders)
    {
        if (_stakeHolders.length > 0) {
            for (uint256 count = 0; count < _stakeHolders.length && count < _totalStakeHolders; count++) {
                if (_stakeHolders[count] != 0x0) {
                  _setStakeHolder( _stakeHolders[count], _weights[count] );
                }
            }
        }
    }

    function getTotalWeight () public view returns (uint256 _total) {
        for (uint256 count = 0; count < stakeHolders.length; count++) {
            _total = _total.add(stakeHoldersWeight[stakeHolders[count]]);
        }
    }

    function getPortion (uint256 _total, uint256 _totalWeight, address _stakeHolder) public view returns (uint256) {
        uint256 weight = stakeHoldersWeight[_stakeHolder];
        return (_total.mul(weight)).div(_totalWeight);
    }

    function getPortion (uint256 _total) public view returns (uint256) {
        revert("Kindly indicate stakeHolder and totalWeight");
    }

    function _setStakeHolder (address _stakeHolder, uint256 _weight) internal onlyOwner returns (bool) {
        stakeHoldersWeight[_stakeHolder] = _weight;
        require(super._setStakeHolder(_stakeHolder));
        return true;
    }

    function _setStakeHolder (address _stakeHolder) internal onlyOwner returns (bool) {
        revert("Kindly set Weights for stakeHolder");
    }

    function _distribute (address _token) internal returns (bool) {
        uint256 balance = getTokenBalance(_token);
        uint256 totalWeight = getTotalWeight();

        if (balance < 1) {
            emit InsufficientTokenBalance(_token, block.timestamp);
            return false;
        } else {
            for (uint256 count = 0; count < stakeHolders.length; count++) {
                uint256 perStakeHolder = getPortion(balance, totalWeight, stakeHolders[count]);
                _transfer(_token, stakeHolders[count], perStakeHolder);
            }

            uint256 newBalance = getTokenBalance(_token);
            if (newBalance > 0) {
                _transfer(_token, owner, newBalance);
            }

            emit TokensDistributed(_token, balance, block.timestamp);
            return true;
        }
    }
}