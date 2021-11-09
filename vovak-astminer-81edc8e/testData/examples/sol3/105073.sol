 

pragma solidity ^0.6.0;

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 

pragma solidity ^0.6.0;

 
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

 

pragma solidity >=0.4.21 <0.7.0;

 
 
 
interface EIP20NonStandardInterface {
     
     
    function totalSupply() external view returns (uint256);

     
     
     
    function balanceOf(address owner) external view returns (uint256 balance);

     
     
     
     
     

     
     
     
    function transfer(address dst, uint256 amount) external;

     
     
     
     
     

     
     
     
     
    function transferFrom(address src, address dst, uint256 amount) external;

     
     
     
     
     
     
    function approve(address spender, uint256 amount) external returns (bool success);

     
     
     
     
    function allowance(address owner, address spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

 

pragma solidity >=0.4.21 <0.7.0;

 
 
 
interface IDerivativeSpecification {

     
     
     
    function isDerivativeSpecification() external pure returns(bool);

     
     
     
     
    function oracleSymbols() external view returns (bytes32[] memory);

     
     
     
     
    function oracleIteratorSymbols() external view returns (bytes32[] memory);

     
     
     
    function collateralTokenSymbol() external view returns (bytes32);

     
     
     
     
    function collateralSplitSymbol() external view returns (bytes32);

     
     
     
    function mintingPeriod() external view returns (uint);

     
     
     
    function livePeriod() external view returns (uint);

     
     
     
    function primaryNominalValue() external view returns (uint);

     
     
     
    function complementNominalValue() external view returns (uint);

     
     
     
    function authorFee() external view returns (uint);

     
     
     
    function symbol() external view returns (string memory);

     
     
     
    function name() external view returns (string memory);

     
     
     
    function baseURI() external view returns (string memory);

     
     
     
    function author() external view returns (address);
}

 

pragma solidity >=0.4.21 <0.7.0;

 
 
 
 
interface ICollateralSplit {

     
     
     
    function isCollateralSplit() external pure returns(bool);

     
     
     
    function symbol() external view returns (string memory);

     
     
     
     
     
     
     
    function split(
        address[] memory _oracles,
        address[] memory _oracleIterators,
        uint _liveTime,
        uint _settleTime,
        uint[] memory _underlyingStartRoundHints,
        uint[] memory _underlyingEndRoundHints)
    external view returns(uint _split, int _underlyingStart, int _underlyingEnd);
}

 

pragma solidity >=0.4.21 <0.7.0;


interface IERC20MintedBurnable is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
}

 

pragma solidity >=0.4.21 <0.7.0;



interface ITokenBuilder {
    function isTokenBuilder() external pure returns(bool);
    function buildTokens(IDerivativeSpecification derivative, uint settlement, address _collateralToken) external returns(IERC20MintedBurnable, IERC20MintedBurnable);
}

 

pragma solidity >=0.4.21 <0.7.0;

interface IFeeLogger {
    function log(address _liquidityProvider, address _collateral, uint _protocolFee, address _author) external;
}

 

pragma solidity >=0.4.21 <0.7.0;

 
 
contract Vault {
    using SafeMath for uint;
    using SafeMath for uint8;

    uint public constant FRACTION_MULTIPLIER = 10**12;
    int public constant NEGATIVE_INFINITY = type(int256).min;

    enum State { Created, Minting, Live, Settled }

    event StateChanged(State oldState, State newState);
    event MintingStateSet(address primaryToken, address complementToken);
    event LiveStateSet();
    event SettledStateSet(int underlyingStart, int underlyingEnd, uint primaryConversion, uint complementConversion);
    event Minted(uint minted, uint collateral, uint fee);
    event Refunded(uint tokenAmount, uint collateral);
    event Redeemed(uint tokenAmount, uint conversion, uint collateral, bool isPrimary);

     
    uint public initializationTime;
     
    uint public liveTime;
     
    uint public settleTime;

     
    int public underlyingStart;
     
    int public underlyingEnd;

     
    uint public primaryConversion;
     
    uint public complementConversion;

     
    uint public protocolFee;
     
    uint public authorFeeLimit;

     
    State public state;

     
    IDerivativeSpecification public derivativeSpecification;
     
    IERC20 public collateralToken;
     
    address[] public oracles;
    address[] public oracleIterators;
     
    ICollateralSplit public collateralSplit;
     
    ITokenBuilder public tokenBuilder;
    IFeeLogger public feeLogger;

     
    address public feeWallet;

     
    IERC20MintedBurnable public primaryToken;
     
    IERC20MintedBurnable public complementToken;

    constructor(
        uint _initializationTime,
        uint _protocolFee,
        address _feeWallet,
        address _derivativeSpecification,
        address _collateralToken,
        address[] memory _oracles,
        address[] memory _oracleIterators,
        address _collateralSplit,
        address _tokenBuilder,
        address _feeLogger,
        uint _authorFeeLimit
    ) public {
        require(_initializationTime > 0, "Initialization time");
        initializationTime = _initializationTime;

        protocolFee = _protocolFee;

        require(_feeWallet != address(0), "Fee wallet");
        feeWallet = _feeWallet;

        require(_derivativeSpecification != address(0), "Derivative");
        derivativeSpecification = IDerivativeSpecification(_derivativeSpecification);

        require(_collateralToken != address(0), "Collateral token");
        collateralToken = IERC20(_collateralToken);

        require(_oracles.length > 0, "Oracles");
        require(_oracles[0] != address(0), "First oracle is absent");
        oracles = _oracles;

        require(_oracleIterators.length > 0, "OracleIterators");
        require(_oracleIterators[0] != address(0), "First oracle iterator is absent");
        oracleIterators = _oracleIterators;

        require(_collateralSplit != address(0), "Collateral split");
        collateralSplit = ICollateralSplit(_collateralSplit);

        require(_tokenBuilder != address(0), "Token builder");
        tokenBuilder = ITokenBuilder(_tokenBuilder);

        require(_feeLogger != address(0), "Fee logger");
        feeLogger = IFeeLogger(_feeLogger);

        changeState(State.Created);

        underlyingStart = NEGATIVE_INFINITY;
        underlyingEnd = NEGATIVE_INFINITY;

        authorFeeLimit = _authorFeeLimit;

        liveTime = initializationTime + derivativeSpecification.mintingPeriod();
        settleTime = liveTime + derivativeSpecification.livePeriod();
        require(liveTime > block.timestamp, "Live time");
        require(settleTime > block.timestamp, "Settle time");
    }

     
     
    function initialize() external {
        require(state == State.Created, "Incorrect state.");

        changeState(State.Minting);

        (primaryToken, complementToken) = tokenBuilder.buildTokens(derivativeSpecification, settleTime, address(collateralToken));

        emit MintingStateSet(address(primaryToken), address(complementToken));
    }

     
    function live() public {
        if(state != State.Minting) {
            revert('Incorrect state');
        }
        require(block.timestamp >= liveTime, "Incorrect time");
        changeState(State.Live);

        emit LiveStateSet();
    }

    function changeState(State _newState) internal {
        emit StateChanged(state, _newState);
        state = _newState;
    }


     
     
     
     
    function settle(uint[] memory underlyingStartRoundHints, uint[] memory underlyingEndRoundHints) public {
        if(state != State.Live) {
            revert('Incorrect state');
        }
        require(block.timestamp >= settleTime, "Incorrect time");
        changeState(State.Settled);

        uint split;
        (split, underlyingStart, underlyingEnd) = collateralSplit.split(
            oracles, oracleIterators, liveTime, settleTime, underlyingStartRoundHints, underlyingEndRoundHints
        );
        split = range(split);

        uint collectedCollateral = collateralToken.balanceOf(address(this));
        uint mintedPrimaryTokenAmount = primaryToken.totalSupply();

        if(mintedPrimaryTokenAmount > 0) {
            uint primaryCollateralPortion = collectedCollateral.mul(split);
            primaryConversion = primaryCollateralPortion.div(mintedPrimaryTokenAmount);
            complementConversion = collectedCollateral.mul(FRACTION_MULTIPLIER).sub(primaryCollateralPortion).div(mintedPrimaryTokenAmount);
        }

        emit SettledStateSet(underlyingStart, underlyingEnd, primaryConversion, complementConversion);
    }

    function range(uint _split) public pure returns(uint) {
        if(_split > FRACTION_MULTIPLIER) {
            return uint(FRACTION_MULTIPLIER);
        }
        return uint(_split);
    }

     
     
    function mint(uint _collateralAmount) external {
        if(block.timestamp >= liveTime && state == State.Minting) {
            live();
        }

        if(state != State.Minting){
            revert('Minting period is over');
        }

        require(_collateralAmount > 0, "Zero amount");
        _collateralAmount = doTransferIn(msg.sender, _collateralAmount);

        uint feeAmount = withdrawFee(_collateralAmount);

        uint netAmount = _collateralAmount.sub(feeAmount);

        uint tokenAmount = denominate(netAmount);

        primaryToken.mint(msg.sender, tokenAmount);
        complementToken.mint(msg.sender, tokenAmount);

        emit Minted(tokenAmount, _collateralAmount, feeAmount);
    }

     
    function refund(uint _tokenAmount) external {
        require(_tokenAmount > 0, "Zero amount");
        require(_tokenAmount <= primaryToken.balanceOf(msg.sender), "Insufficient primary amount");
        require(_tokenAmount <= complementToken.balanceOf(msg.sender), "Insufficient complement amount");

        primaryToken.burnFrom(msg.sender, _tokenAmount);
        complementToken.burnFrom(msg.sender, _tokenAmount);
        uint unDenominated = unDenominate(_tokenAmount);

        emit Refunded(_tokenAmount, unDenominated);
        doTransferOut(msg.sender, unDenominated);
    }

     
    function redeem(
        uint _primaryTokenAmount,
        uint _complementTokenAmount,
        uint[] memory underlyingStartRoundHints,
        uint[] memory underlyingEndRoundHints
    ) external {
        require(_primaryTokenAmount > 0 || _complementTokenAmount > 0, "Both tokens zero amount");
        require(_primaryTokenAmount <= primaryToken.balanceOf(msg.sender), "Insufficient primary amount");
        require(_complementTokenAmount <= complementToken.balanceOf(msg.sender), "Insufficient complement amount");

        if(block.timestamp >= liveTime && state == State.Minting) {
            live();
        }

        if(block.timestamp >= settleTime && state == State.Live) {
            settle(underlyingStartRoundHints,underlyingEndRoundHints);
        }

        if(state == State.Settled) {
            redeemAsymmetric(primaryToken, _primaryTokenAmount, true);
            redeemAsymmetric(complementToken, _complementTokenAmount, false);
        }
    }

    function redeemAsymmetric(IERC20MintedBurnable _derivativeToken, uint _amount, bool _isPrimary) internal {
        if(_amount > 0) {
            _derivativeToken.burnFrom(msg.sender, _amount);
            uint conversion = _isPrimary ? primaryConversion : complementConversion;
            uint collateral = _amount.mul(conversion).div(FRACTION_MULTIPLIER);
            emit Redeemed(_amount, conversion, collateral, _isPrimary);
            if(collateral > 0) {
                doTransferOut(msg.sender, collateral);
            }
        }
    }

    function denominate(uint _collateralAmount) internal view returns(uint) {
        return _collateralAmount.div(derivativeSpecification.primaryNominalValue() + derivativeSpecification.complementNominalValue());
    }

    function unDenominate(uint _tokenAmount) internal view returns(uint) {
        return _tokenAmount.mul(derivativeSpecification.primaryNominalValue() + derivativeSpecification.complementNominalValue());
    }

    function withdrawFee(uint _amount) internal returns(uint){
        uint protocolFeeAmount = calcAndTransferFee(_amount, payable(feeWallet), protocolFee);

        feeLogger.log(msg.sender, address(collateralToken), protocolFeeAmount, derivativeSpecification.author());

        uint authorFee = derivativeSpecification.authorFee();
        if(authorFee > authorFeeLimit) {
            authorFee = authorFeeLimit;
        }
        uint authorFeeAmount = calcAndTransferFee(_amount, payable(derivativeSpecification.author()), authorFee);

        return protocolFeeAmount.add(authorFeeAmount);
    }

    function calcAndTransferFee(uint _amount, address payable _beneficiary, uint _fee) internal returns(uint){
        uint feeAmount = _amount.mul(_fee).div(FRACTION_MULTIPLIER);
        if(feeAmount > 0) {
            doTransferOut(_beneficiary, feeAmount);
        }
        return feeAmount;
    }


     
     
     
     
     
     
    function doTransferIn(address from, uint amount) internal returns (uint) {
        EIP20NonStandardInterface token = EIP20NonStandardInterface(address(collateralToken));
        uint balanceBefore = collateralToken.balanceOf(address(this));
        token.transferFrom(from, address(this), amount);

        bool success;
        assembly {
            switch returndatasize()
            case 0 {                        
                success := not(0)           
            }
            case 32 {                       
                returndatacopy(0, 0, 32)
                success := mload(0)         
            }
            default {                       
                revert(0, 0)
            }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");

         
        uint balanceAfter = collateralToken.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceAfter - balanceBefore;    
    }

     
     
     
     
     
     
    function doTransferOut(address payable to, uint amount) internal {
        EIP20NonStandardInterface token = EIP20NonStandardInterface(address(collateralToken));
        token.transfer(to, amount);

        bool success;
        assembly {
            switch returndatasize()
            case 0 {                       
                success := not(0)           
            }
            case 32 {                      
                returndatacopy(0, 0, 32)
                success := mload(0)         
            }
            default {                      
                revert(0, 0)
            }
        }
        require(success, "TOKEN_TRANSFER_OUT_FAILED");
    }
}

 

pragma solidity >=0.4.21 <0.7.0;


interface IVaultBuilder {
    function buildVault(
        uint _initializationTime,
        uint _protocolFee,
        address _feeWallet,
        address _derivativeSpecification,
        address _collateralToken,
        address[] memory _oracles,
        address[] memory _oracleIterators,
        address _collateralSplit,
        address _tokenBuilder,
        address _feeLogger,
        uint _authorFeeLimit
    ) external returns(address);
}

 

 

pragma solidity >=0.4.21 <0.7.0;

contract VaultBuilder is IVaultBuilder{
    function buildVault(
        uint _initializationTime,
        uint _protocolFee,
        address _feeWallet,
        address _derivativeSpecification,
        address _collateralToken,
        address[] memory _oracles,
        address[] memory _oracleIterators,
        address _collateralSplit,
        address _tokenBuilder,
        address _feeLogger,
        uint _authorFeeLimit
    ) external override returns(address){
        address vault = address(
            new Vault(
                _initializationTime,
                _protocolFee,
                _feeWallet,
                _derivativeSpecification,
                _collateralToken,
                _oracles,
                _oracleIterators,
                _collateralSplit,
                _tokenBuilder,
                _feeLogger,
                _authorFeeLimit
            )
        );
        return vault;
    }
}