pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);
    function deposit() external payable;
    function withdraw(uint256 amount) external;

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
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

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
        if (success) {
            return returndata;
        } else {
             
            if (returndata.length > 0) {
                 

                 
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract DSMath {
  uint constant WAD = 10 ** 18;
  uint constant RAY = 10 ** 27;

  function add(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(x, y);
  }

  function sub(uint x, uint y) internal virtual pure returns (uint z) {
    z = SafeMath.sub(x, y);
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.mul(x, y);
  }

  function div(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.div(x, y);
  }

  function wmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
  }

  function wdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
  }

  function rdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
  }

  function rmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
  }

}

interface Account {
    struct Info {
        address owner;  
        uint256 number;  
    }
}

interface Actions {
    enum ActionType {
        Deposit,  
        Withdraw,  
        Transfer,  
        Buy,  
        Sell,  
        Trade,  
        Liquidate,  
        Vaporize,  
        Call  
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        Types.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct DepositArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address from;
    }

    struct WithdrawArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address to;
    }

    struct CallArgs {
        Account.Info account;
        address callee;
        bytes data;
    }
}

interface Types {
    enum AssetDenomination {
        Wei,  
        Par  
    }

    enum AssetReference {
        Delta,  
        Target  
    }

    struct AssetAmount {
        bool sign;  
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct Wei {
        bool sign;  
        uint256 value;
    }
}


interface ISoloMargin {
    struct OperatorArg {
        address operator;
        bool trusted;
    }

    function getMarketTokenAddress(uint256 marketId)
        external
        view
        returns (address);

    function getNumMarkets() external view returns (uint256);


    function operate(
        Account.Info[] calldata accounts,
        Actions.ActionArgs[] calldata actions
    ) external;

    function getAccountWei(Account.Info calldata account, uint256 marketId)
        external
        view
        returns (Types.Wei memory);
}

contract DydxFlashloanBase {
    function _getMarketIdFromTokenAddress(address _solo, address token)
        internal
        view
        returns (uint256)
    {
        ISoloMargin solo = ISoloMargin(_solo);

        uint256 numMarkets = solo.getNumMarkets();

        address curToken;
        for (uint256 i = 0; i < numMarkets; i++) {
            curToken = solo.getMarketTokenAddress(i);

            if (curToken == token) {
                return i;
            }
        }

        revert("No marketId found for provided token");
    }

    function _getAccountInfo() internal view returns (Account.Info memory) {
        return Account.Info({owner: address(this), number: 1});
    }

    function _getWithdrawAction(uint marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Withdraw,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }

    function _getCallAction(bytes memory data)
        internal
        view
        returns (Actions.ActionArgs memory)
    {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Call,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: 0
                }),
                primaryMarketId: 0,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: data
            });
    }

    function _getDepositAction(uint marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Deposit,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: true,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }
}

 
interface ICallee {

     

     
    function callFunction(
        address sender,
        Account.Info calldata accountInfo,
        bytes calldata data
    )
        external;
}

interface DSAInterface {
    function cast(address[] calldata _targets, bytes[] calldata _datas, address _origin) external payable;
}

interface IndexInterface {
  function master() external view returns (address);
}

interface TokenInterface {
    function approve(address, uint256) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint);
}

interface ListInterface {
    function accountID(address) external view returns (uint64);
}

contract Setup {
    IndexInterface public constant instaIndex = IndexInterface(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);
    ListInterface public constant instaList = ListInterface(0x4c8a1BEb8a87765788946D6B19C6C6355194AbEb);

    address public constant soloAddr = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address public constant wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    TokenInterface wethContract = TokenInterface(wethAddr);
    ISoloMargin solo = ISoloMargin(soloAddr);

    address public makerConnect = address(0x33c4f6d6c0A123AF5F1655EA5Fd730098d0aBD50);
    address public compoundConnect = address(0x33d4876A16F712f1a305C5594A5AdeDc9b7A9f14);
    address public aaveConnect = address(0x01d0734e34B0251f46aD34d1a82c4946a5B943D9);

    uint public vaultId;
    uint public fee;  

    modifier isMaster() {
        require(msg.sender == instaIndex.master(), "not-master");
        _;
    }

     
    modifier isDSA {
        uint64 id = instaList.accountID(msg.sender);
        require(id != 0, "not-dsa-id");
        _;
    }

    struct CastData {
        address dsa;
        uint route;
        address[] tokens;
        uint[] amounts;
        address[] dsaTargets;
        bytes[] dsaData;
    }

}

contract Helper is Setup {
    event LogChangedFee(uint newFee);

    function encodeDsaCastData(
        address dsa,
        uint route,
        address[] memory tokens,
        uint[] memory amounts,
        bytes memory data
    ) internal pure returns (bytes memory _data) {
        CastData memory cd;
        (cd.dsaTargets, cd.dsaData) = abi.decode(
            data,
            (address[], bytes[])
        );
        _data = abi.encode(dsa, route, tokens, amounts, cd.dsaTargets, cd.dsaData);
    }

    function spell(address _target, bytes memory _data) internal {
        require(_target != address(0), "target-invalid");
        assembly {
        let succeeded := delegatecall(gas(), _target, add(_data, 0x20), mload(_data), 0, 0)
        switch iszero(succeeded)
            case 1 {
                let size := returndatasize()
                returndatacopy(0x00, 0x00, size)
                revert(0x00, size)
            }
        }
    }

    function updateFee(uint _fee) public isMaster {
        require(_fee != fee, "same-fee");
        require(_fee < 10 ** 15, "more-than-max-fee"); 
        fee = _fee;
        emit LogChangedFee(_fee);
    }

    function masterSpell(address _target, bytes calldata _data) external isMaster {
        spell(_target, _data);
    }

}

contract Resolver is Helper {

    function selectBorrow(address[] memory tokens, uint[] memory amts, uint route) internal {
        if (route == 0) {
            return;
        } else if (route == 1) {
            bytes memory _dataOne = abi.encodeWithSignature("deposit(uint256,uint256)", vaultId, uint(-1));
            bytes memory _dataTwo = abi.encodeWithSignature("borrow(uint256,uint256)", vaultId, amts[0]);
            spell(makerConnect, _dataOne);
            spell(makerConnect, _dataTwo);
        } else if (route == 2) {
            bytes memory _dataOne = abi.encodeWithSignature("deposit(address,uint256)", ethAddr, uint(-1));
            spell(compoundConnect, _dataOne);
            for (uint i = 0; i < amts.length; i++) {
                bytes memory _dataTwo = abi.encodeWithSignature("borrow(address,uint256)", tokens[i], amts[i]);
                spell(compoundConnect, _dataTwo);
            }
        } else if (route == 3) {
            bytes memory _dataOne = abi.encodeWithSignature("deposit(address,uint256)", ethAddr, uint(-1));
            spell(aaveConnect, _dataOne);
            for (uint i = 0; i < amts.length; i++) {
                bytes memory _dataTwo = abi.encodeWithSignature("borrow(address,uint256)", tokens[i], amts[i]);
                spell(aaveConnect, _dataTwo);
            }
        } else {
            revert("route-not-found");
        }
    }

    function selectPayback(address[] memory tokens, uint route) internal {
        if (route == 0) {
            return;
        } else if (route == 1) {
            bytes memory _dataOne = abi.encodeWithSignature("payback(uint256,uint256)", vaultId, uint(-1));
            bytes memory _dataTwo = abi.encodeWithSignature("withdraw(uint256,uint256)", vaultId, uint(-1));
            spell(makerConnect, _dataOne);
            spell(makerConnect, _dataTwo);
        } else if (route == 2) {
            for (uint i = 0; i < tokens.length; i++) {
                bytes memory _data = abi.encodeWithSignature("payback(address,uint256)", tokens[i], uint(-1));
                spell(compoundConnect, _data);
            }
            bytes memory _dataOne = abi.encodeWithSignature("withdraw(address,uint256)", ethAddr, uint(-1));
            spell(compoundConnect, _dataOne);
        } else if (route == 3) {
            for (uint i = 0; i < tokens.length; i++) {
                bytes memory _data = abi.encodeWithSignature("payback(address,uint256)", tokens[i], uint(-1));
                spell(aaveConnect, _data);
            }
            bytes memory _dataOne = abi.encodeWithSignature("withdraw(address,uint256)", ethAddr, uint(-1));
            spell(aaveConnect, _dataOne);
        } else {
            revert("route-not-found");
        }
    }

}

contract DydxFlashloaner is Resolver, ICallee, DydxFlashloanBase, DSMath {
    using SafeERC20 for IERC20;

    event LogFlashLoan(
        address indexed sender,
        address[] tokens,
        uint[] amounts,
        uint[] feeAmts,
        uint route
    );

    function checkWeth(address[] memory tokens, uint _route) internal pure returns (bool) {
        if (_route == 0) {
            for (uint i = 0; i < tokens.length; i++) {
                if (tokens[i] == ethAddr) {
                    return true;
                }
            }
        } else {
            return true;
        }
        return false;
    }


    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public override {
        require(sender == address(this), "not-same-sender");
        require(msg.sender == soloAddr, "not-solo-dydx-sender");
        CastData memory cd;
        (cd.dsa, cd.route, cd.tokens, cd.amounts, cd.dsaTargets, cd.dsaData) = abi.decode(
            data,
            (address, uint256, address[], uint256[], address[], bytes[])
        );

        bool isWeth = checkWeth(cd.tokens, cd.route);
        if (isWeth) {
            wethContract.withdraw(wethContract.balanceOf(address(this)));
        }

        selectBorrow(cd.tokens, cd.amounts, cd.route);

        uint _length = cd.tokens.length;

        for (uint i = 0; i < _length; i++) {
            if (cd.tokens[i] == ethAddr) {
                payable(cd.dsa).transfer(cd.amounts[i]);
            } else {
                IERC20(cd.tokens[i]).safeTransfer(cd.dsa, cd.amounts[i]);
            }
        }

        DSAInterface(cd.dsa).cast(cd.dsaTargets, cd.dsaData, 0xB7fA44c2E964B6EB24893f7082Ecc08c8d0c0F87);

        selectPayback(cd.tokens, cd.route);

        if (isWeth) {
            wethContract.deposit{value: address(this).balance}();
        }
    }

    function routeDydx(address[] memory _tokens, uint256[] memory _amounts, uint _route, bytes memory data) internal {
        uint _length = _tokens.length;
        IERC20[] memory _tokenContracts = new IERC20[](_length);
        uint[] memory _marketIds = new uint[](_length);

        for (uint i = 0; i < _length; i++) {
            address _token =  _tokens[i] == ethAddr ? wethAddr : _tokens[i];
            _marketIds[i] = _getMarketIdFromTokenAddress(soloAddr, _token);
            _tokenContracts[i] = IERC20(_token);
            _tokenContracts[i].approve(soloAddr, _amounts[i] + 2);  
        }

        uint _opLength = _length * 2 + 1;
        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](_opLength);

        for (uint i = 0; i < _length; i++) {
            operations[i] = _getWithdrawAction(_marketIds[i], _amounts[i]);
        }
        operations[_length] = _getCallAction(encodeDsaCastData(msg.sender, _route, _tokens, _amounts, data));
        for (uint i = 0; i < _length; i++) {
            uint _opIndex = _length + 1 + i;
            operations[_opIndex] = _getDepositAction(_marketIds[i], _amounts[i] + 2);
        }

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        uint[] memory iniBals = new uint[](_length);
        uint[] memory finBals = new uint[](_length);
        uint[] memory _feeAmts = new uint[](_length);
        for (uint i = 0; i < _length; i++) {
            iniBals[i] = _tokenContracts[i].balanceOf(address(this));
        }

        solo.operate(accountInfos, operations);

        for (uint i = 0; i < _length; i++) {
            finBals[i] = _tokenContracts[i].balanceOf(address(this));
            if (fee == 0) {
                _feeAmts[i] = 0;
                require(sub(iniBals[i], finBals[i]) < 10000, "amount-paid-less");
            } else {
                uint _feeLowerLimit = wmul(_amounts[i], wmul(fee, 999500000000000000));  
                uint _feeUpperLimit = wmul(_amounts[i], wmul(fee, 1000500000000000000));  
                require(finBals[i] >= iniBals[i], "final-balance-less-than-inital-balance");
                _feeAmts[i] = sub(finBals[i], iniBals[i]);
                require(_feeLowerLimit < _feeAmts[i] && _feeAmts[i] < _feeUpperLimit, "amount-paid-less");
            }
        }

        emit LogFlashLoan(
            msg.sender,
            _tokens,
            _amounts,
            _feeAmts,
            _route
        );

    }

    function routeProtocols(address[] memory _tokens, uint256[] memory _amounts, uint _route, bytes memory data) internal {
        uint _length = _tokens.length;
        uint256 wethMarketId = 0;

        uint _amount = wethContract.balanceOf(soloAddr);  
        _amount = wmul(_amount, 999000000000000000);  
        wethContract.approve(soloAddr, _amount + 2);

        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(wethMarketId, _amount);
        operations[1] = _getCallAction(encodeDsaCastData(msg.sender, _route, _tokens, _amounts, data));
        operations[2] = _getDepositAction(wethMarketId, _amount + 2);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        uint[] memory iniBals = new uint[](_length);
        uint[] memory finBals = new uint[](_length);
        uint[] memory _feeAmts = new uint[](_length);
        IERC20[] memory _tokenContracts = new IERC20[](_length);
        for (uint i = 0; i < _length; i++) {
            address _token =  _tokens[i] == ethAddr ? wethAddr : _tokens[i];
            _tokenContracts[i] = IERC20(_token);
            iniBals[i] = _tokenContracts[i].balanceOf(address(this));
        }

        solo.operate(accountInfos, operations);

        for (uint i = 0; i < _length; i++) {
            finBals[i] = _tokenContracts[i].balanceOf(address(this));
            if (fee == 0) {
                _feeAmts[i] = 0;
                uint _dif = wmul(_amounts[i], 200000000000);  
                require(sub(iniBals[i], finBals[i]) < _dif, "amount-paid-less");
            } else {
                uint _feeLowerLimit = wmul(_amounts[i], wmul(fee, 999500000000000000));  
                uint _feeUpperLimit = wmul(_amounts[i], wmul(fee, 1000500000000000000));  
                require(finBals[i] >= iniBals[i], "final-balance-less-than-inital-balance");
                _feeAmts[i] = sub(finBals[i], iniBals[i]);
                require(_feeLowerLimit < _feeAmts[i] && _feeAmts[i] < _feeUpperLimit, "amount-paid-less");
            }
        }

        emit LogFlashLoan(
            msg.sender,
            _tokens,
            _amounts,
            _feeAmts,
            _route
        );

    }

    function initiateFlashLoan(	
        address[] calldata _tokens,	
        uint256[] calldata _amounts,	
        uint _route,	
        bytes calldata data	
    ) external isDSA {	
        if (_route == 0) {	
            routeDydx(_tokens, _amounts, _route, data);	
        } else {	
            routeProtocols(_tokens, _amounts, _route, data);	
        }	
    }
}

contract InstaDydxFlashLoan is DydxFlashloaner {
    constructor(
        uint _vaultId
    ) public {
        wethContract.approve(wethAddr, uint(-1));
        vaultId = _vaultId;
        fee =  5 * 10 ** 14;
    }

    receive() external payable {}
}