 

pragma solidity ^0.5.0;

 
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

 

pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.5.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

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

 

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 

pragma solidity ^0.5.0;

 
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
         
         
         
         
         
         
        _notEntered = true;
    }

     
    modifier nonReentrant() {
         
        require(_notEntered, "ReentrancyGuard: reentrant call");

         
        _notEntered = false;

        _;

         
         
        _notEntered = true;
    }
}

 

pragma solidity 0.5.12;


 

 
 
 
 
 
 
 
 
 
 
 







interface ICurveGenZapOut {
    function ZapOut(
        address payable _toWhomToIssue,
        address _curveExchangeAddress,
        uint256 _IncomingCRV,
        address _ToTokenAddress
    ) external returns (uint256 ToTokensBought);
}


interface ICurveGenZapIn {
    function ZapIn(
        address _toWhomToIssue,
        address _IncomingTokenAddress,
        address _curvePoolExchangeAddress,
        uint256 _IncomingTokenQty
    ) external payable returns (uint256 crvTokensBought);
}


interface IUniswapFactory_uni_curve_pipe {
    function getExchange(address token)
        external
        view
        returns (address exchange);
}


interface IUniswapPoolZap {
    function LetsInvest(address _TokenContractAddress, address _towhomtoissue)
        external
        payable
        returns (uint256);
}


interface IUniswapRemoveLiq {
    function LetsWithdraw_onlyERC(
        address _TokenContractAddress,
        uint256 LiquidityTokenSold,
        bool _returnInDai
    ) external payable returns (bool);

    function LetsWithdraw_onlyETH(
        address _TokenContractAddress,
        uint256 LiquidityTokenSold
    ) external payable returns (bool);
}


contract Uni_Curve_Pipe is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    bool private stopped = false;

    ICurveGenZapIn public curveGenZapIn;
    ICurveGenZapOut public curveGenZapOut;

    IUniswapFactory_uni_curve_pipe public uniswapFactory = IUniswapFactory_uni_curve_pipe(
        0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
    );
    IUniswapPoolZap public uniswapPoolZap;
    IUniswapRemoveLiq public uniswapRemoveLiq;

    address public DaiTokenAddress = address(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    address public sUSDCurveExchangeAddress = address(
        0xA5407eAE9Ba41422680e2e00537571bcC53efBfD
    );
    address public sUSDCurvePoolTokenAddress = address(
        0xC25a3A3b969415c80451098fa907EC722572917F
    );
    address public yCurveExchangeAddress = address(
        0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3
    );
    address public yCurvePoolTokenAddress = address(
        0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8
    );
    address public bUSDCurveExchangeAddress = address(
        0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB
    );
    address public bUSDCurvePoolTokenAddress = address(
        0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B
    );
    address public paxCurveExchangeAddress = address(
        0xA50cCc70b6a011CffDdf45057E39679379187287
    );
    address public paxCurvePoolTokenAddress = address(
        0xD905e2eaeBe188fc92179b6350807D8bd91Db0D8
    );

    mapping(address => address) internal exchange2Token;

    constructor(
        address _genCurveZapInAddress,
        address _curveZapOutAddress,
        address _uniswapPoolZapAddress,
        address _uniswapRemoveLiqAddr
    ) public {
        curveGenZapIn = ICurveGenZapIn(_genCurveZapInAddress);
        curveGenZapOut = ICurveGenZapOut(_curveZapOutAddress);
        uniswapPoolZap = IUniswapPoolZap(_uniswapPoolZapAddress);
        uniswapRemoveLiq = IUniswapRemoveLiq(_uniswapRemoveLiqAddr);

        exchange2Token[sUSDCurveExchangeAddress] = sUSDCurvePoolTokenAddress;
        exchange2Token[yCurveExchangeAddress] = yCurvePoolTokenAddress;
        exchange2Token[bUSDCurveExchangeAddress] = bUSDCurvePoolTokenAddress;
        exchange2Token[paxCurveExchangeAddress] = paxCurvePoolTokenAddress;

        approveToken();
    }

    function approveToken() public {
        IERC20(sUSDCurvePoolTokenAddress).approve(
            address(curveGenZapOut),
            uint256(-1)
        );
        IERC20(yCurvePoolTokenAddress).approve(
            address(curveGenZapOut),
            uint256(-1)
        );
        IERC20(bUSDCurvePoolTokenAddress).approve(
            address(curveGenZapOut),
            uint256(-1)
        );
        IERC20(paxCurvePoolTokenAddress).approve(
            address(curveGenZapOut),
            uint256(-1)
        );

        IERC20(DaiTokenAddress).approve(address(curveGenZapIn), uint256(-1));
    }

     
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function Curve2Uni(
        address _toWhomToIssue,
        address _incomingCurveExchange,
        uint256 _IncomingCRV,
        address _toUniUnderlyingTokenAddress
    ) public nonReentrant stopInEmergency {
        require(
            IERC20(exchange2Token[_incomingCurveExchange]).transferFrom(
                _toWhomToIssue,
                address(this),
                _IncomingCRV
            ),
            "Error transferring CRV"
        );

        uint256 initialBalance = address(this).balance;

        curveGenZapOut.ZapOut(
            address(uint160(address(this))),
            _incomingCurveExchange,
            _IncomingCRV,
            address(0)
        );

        uint256 ethBought = address(this).balance;

        ethBought = SafeMath.sub(ethBought, initialBalance);

        uniswapPoolZap.LetsInvest.value(ethBought)(
            _toUniUnderlyingTokenAddress,
            _toWhomToIssue
        );
    }

    function Uni2Curve(
        address _toWhomToIssue,
        address _incomingUniUnderlyingTokenAddress,
        uint256 _IncomingLPT,
        address _toCurveExchange
    ) public nonReentrant stopInEmergency {
        require(
            IERC20(
                uniswapFactory.getExchange(_incomingUniUnderlyingTokenAddress)
            ).transferFrom(_toWhomToIssue, address(this), _IncomingLPT),
            "Error transferring CRV"
        );

        IERC20(uniswapFactory.getExchange(_incomingUniUnderlyingTokenAddress))
            .approve(address(uniswapRemoveLiq), _IncomingLPT);

        uint256 initialBalance = address(this).balance;

        uniswapRemoveLiq.LetsWithdraw_onlyETH(
            _incomingUniUnderlyingTokenAddress,
            _IncomingLPT
        );

        uint256 ethBought = address(this).balance;
        ethBought = SafeMath.sub(ethBought, initialBalance);

        curveGenZapIn.ZapIn.value(ethBought)(
            _toWhomToIssue,
            address(0),
            _toCurveExchange,
            0
        );
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(owner(), qty);
    }

     
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

     
    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }

     
    function destruct() public onlyOwner {
        address payable _to = owner().toPayable();
        selfdestruct(_to);
    }

     
    function() external payable {}
}