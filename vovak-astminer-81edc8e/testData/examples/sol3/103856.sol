 

 

pragma solidity ^0.6.0;

 
contract Context {
     
     
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

 

pragma solidity ^0.6.0;

 
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

 

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

 

 

pragma solidity ^0.6.2;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 

pragma solidity ^0.6.0;

 
 
 
 
 
 
 
 
 
 
 
 
library BokkyPooBahsRedBlackTreeLibrary {

    struct Node {
        uint parent;
        uint left;
        uint right;
        bool red;
    }

    struct Tree {
        uint root;
        mapping(uint => Node) nodes;
    }

    uint private constant EMPTY = 0;

    function first(Tree storage self) internal view returns (uint _key) {
        _key = self.root;
        if (_key != EMPTY) {
            while (self.nodes[_key].left != EMPTY) {
                _key = self.nodes[_key].left;
            }
        }
    }
    function last(Tree storage self) internal view returns (uint _key) {
        _key = self.root;
        if (_key != EMPTY) {
            while (self.nodes[_key].right != EMPTY) {
                _key = self.nodes[_key].right;
            }
        }
    }
    function next(Tree storage self, uint target) internal view returns (uint cursor) {
        require(target != EMPTY);
        if (self.nodes[target].right != EMPTY) {
            cursor = treeMinimum(self, self.nodes[target].right);
        } else {
            cursor = self.nodes[target].parent;
            while (cursor != EMPTY && target == self.nodes[cursor].right) {
                target = cursor;
                cursor = self.nodes[cursor].parent;
            }
        }
    }
    function prev(Tree storage self, uint target) internal view returns (uint cursor) {
        require(target != EMPTY);
        if (self.nodes[target].left != EMPTY) {
            cursor = treeMaximum(self, self.nodes[target].left);
        } else {
            cursor = self.nodes[target].parent;
            while (cursor != EMPTY && target == self.nodes[cursor].left) {
                target = cursor;
                cursor = self.nodes[cursor].parent;
            }
        }
    }
    function exists(Tree storage self, uint key) internal view returns (bool) {
        return (key != EMPTY) && ((key == self.root) || (self.nodes[key].parent != EMPTY));
    }
    function isEmpty(uint key) internal pure returns (bool) {
        return key == EMPTY;
    }
    function getEmpty() internal pure returns (uint) {
        return EMPTY;
    }
    function getNode(Tree storage self, uint key) internal view returns (uint _returnKey, uint _parent, uint _left, uint _right, bool _red) {
        require(exists(self, key));
        return(key, self.nodes[key].parent, self.nodes[key].left, self.nodes[key].right, self.nodes[key].red);
    }

    function insert(Tree storage self, uint key) internal {
        require(key != EMPTY);
        require(!exists(self, key));
        uint cursor = EMPTY;
        uint probe = self.root;
        while (probe != EMPTY) {
            cursor = probe;
            if (key < probe) {
                probe = self.nodes[probe].left;
            } else {
                probe = self.nodes[probe].right;
            }
        }
        self.nodes[key] = Node({parent: cursor, left: EMPTY, right: EMPTY, red: true});
        if (cursor == EMPTY) {
            self.root = key;
        } else if (key < cursor) {
            self.nodes[cursor].left = key;
        } else {
            self.nodes[cursor].right = key;
        }
        insertFixup(self, key);
    }
    function remove(Tree storage self, uint key) internal {
        require(key != EMPTY);
        require(exists(self, key));
        uint probe;
        uint cursor;
        if (self.nodes[key].left == EMPTY || self.nodes[key].right == EMPTY) {
            cursor = key;
        } else {
            cursor = self.nodes[key].right;
            while (self.nodes[cursor].left != EMPTY) {
                cursor = self.nodes[cursor].left;
            }
        }
        if (self.nodes[cursor].left != EMPTY) {
            probe = self.nodes[cursor].left;
        } else {
            probe = self.nodes[cursor].right;
        }
        uint yParent = self.nodes[cursor].parent;
        self.nodes[probe].parent = yParent;
        if (yParent != EMPTY) {
            if (cursor == self.nodes[yParent].left) {
                self.nodes[yParent].left = probe;
            } else {
                self.nodes[yParent].right = probe;
            }
        } else {
            self.root = probe;
        }
        bool doFixup = !self.nodes[cursor].red;
        if (cursor != key) {
            replaceParent(self, cursor, key);
            self.nodes[cursor].left = self.nodes[key].left;
            self.nodes[self.nodes[cursor].left].parent = cursor;
            self.nodes[cursor].right = self.nodes[key].right;
            self.nodes[self.nodes[cursor].right].parent = cursor;
            self.nodes[cursor].red = self.nodes[key].red;
            (cursor, key) = (key, cursor);
        }
        if (doFixup) {
            removeFixup(self, probe);
        }
        delete self.nodes[cursor];
    }

    function treeMinimum(Tree storage self, uint key) private view returns (uint) {
        while (self.nodes[key].left != EMPTY) {
            key = self.nodes[key].left;
        }
        return key;
    }
    function treeMaximum(Tree storage self, uint key) private view returns (uint) {
        while (self.nodes[key].right != EMPTY) {
            key = self.nodes[key].right;
        }
        return key;
    }

    function rotateLeft(Tree storage self, uint key) private {
        uint cursor = self.nodes[key].right;
        uint keyParent = self.nodes[key].parent;
        uint cursorLeft = self.nodes[cursor].left;
        self.nodes[key].right = cursorLeft;
        if (cursorLeft != EMPTY) {
            self.nodes[cursorLeft].parent = key;
        }
        self.nodes[cursor].parent = keyParent;
        if (keyParent == EMPTY) {
            self.root = cursor;
        } else if (key == self.nodes[keyParent].left) {
            self.nodes[keyParent].left = cursor;
        } else {
            self.nodes[keyParent].right = cursor;
        }
        self.nodes[cursor].left = key;
        self.nodes[key].parent = cursor;
    }
    function rotateRight(Tree storage self, uint key) private {
        uint cursor = self.nodes[key].left;
        uint keyParent = self.nodes[key].parent;
        uint cursorRight = self.nodes[cursor].right;
        self.nodes[key].left = cursorRight;
        if (cursorRight != EMPTY) {
            self.nodes[cursorRight].parent = key;
        }
        self.nodes[cursor].parent = keyParent;
        if (keyParent == EMPTY) {
            self.root = cursor;
        } else if (key == self.nodes[keyParent].right) {
            self.nodes[keyParent].right = cursor;
        } else {
            self.nodes[keyParent].left = cursor;
        }
        self.nodes[cursor].right = key;
        self.nodes[key].parent = cursor;
    }

    function insertFixup(Tree storage self, uint key) private {
        uint cursor;
        while (key != self.root && self.nodes[self.nodes[key].parent].red) {
            uint keyParent = self.nodes[key].parent;
            if (keyParent == self.nodes[self.nodes[keyParent].parent].left) {
                cursor = self.nodes[self.nodes[keyParent].parent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[keyParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].right) {
                      key = keyParent;
                      rotateLeft(self, key);
                    }
                    keyParent = self.nodes[key].parent;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    rotateRight(self, self.nodes[keyParent].parent);
                }
            } else {
                cursor = self.nodes[self.nodes[keyParent].parent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[keyParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].left) {
                      key = keyParent;
                      rotateRight(self, key);
                    }
                    keyParent = self.nodes[key].parent;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    rotateLeft(self, self.nodes[keyParent].parent);
                }
            }
        }
        self.nodes[self.root].red = false;
    }

    function replaceParent(Tree storage self, uint a, uint b) private {
        uint bParent = self.nodes[b].parent;
        self.nodes[a].parent = bParent;
        if (bParent == EMPTY) {
            self.root = a;
        } else {
            if (b == self.nodes[bParent].left) {
                self.nodes[bParent].left = a;
            } else {
                self.nodes[bParent].right = a;
            }
        }
    }
    function removeFixup(Tree storage self, uint key) private {
        uint cursor;
        while (key != self.root && !self.nodes[key].red) {
            uint keyParent = self.nodes[key].parent;
            if (key == self.nodes[keyParent].left) {
                cursor = self.nodes[keyParent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[keyParent].red = true;
                    rotateLeft(self, keyParent);
                    cursor = self.nodes[keyParent].right;
                }
                if (!self.nodes[self.nodes[cursor].left].red && !self.nodes[self.nodes[cursor].right].red) {
                    self.nodes[cursor].red = true;
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].right].red) {
                        self.nodes[self.nodes[cursor].left].red = false;
                        self.nodes[cursor].red = true;
                        rotateRight(self, cursor);
                        cursor = self.nodes[keyParent].right;
                    }
                    self.nodes[cursor].red = self.nodes[keyParent].red;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[cursor].right].red = false;
                    rotateLeft(self, keyParent);
                    key = self.root;
                }
            } else {
                cursor = self.nodes[keyParent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[keyParent].red = true;
                    rotateRight(self, keyParent);
                    cursor = self.nodes[keyParent].left;
                }
                if (!self.nodes[self.nodes[cursor].right].red && !self.nodes[self.nodes[cursor].left].red) {
                    self.nodes[cursor].red = true;
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].left].red) {
                        self.nodes[self.nodes[cursor].right].red = false;
                        self.nodes[cursor].red = true;
                        rotateLeft(self, cursor);
                        cursor = self.nodes[keyParent].left;
                    }
                    self.nodes[cursor].red = self.nodes[keyParent].red;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[cursor].left].red = false;
                    rotateRight(self, keyParent);
                    key = self.root;
                }
            }
        }
        self.nodes[key].red = false;
    }
}
 
 
 

 

pragma solidity ^0.6.2;

interface ESTokenInterface {
    function isESToken() external pure returns (bool);
    function parentReferral(address user) external view returns (address);
    function setParentReferral(address user, address parent, uint256 reward) external;
}

interface ExchangeInterface {
    function isExchange() external pure  returns (bool);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

interface IERC20USDTCOMPATIBLE {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external;
    function approve(address spender, uint256 value) external;
    function decimals() external view returns (uint256);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

 

pragma solidity ^0.6.2;







contract Exchange is ExchangeInterface, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using BokkyPooBahsRedBlackTreeLibrary for BokkyPooBahsRedBlackTreeLibrary.Tree;

    struct Order {
         
        uint256 uid;
        address trader;
        uint256 srcAmount;
        uint256 destAmount;
        uint256 filled;
    }

    struct MemoryOrder {
        address trader;
        address src;
        uint256 srcAmount;
        address dest;
        uint256 destAmount;
        uint256 filled;
    }

    struct TokenEntity {
        uint256 reservedBalance;
        Order[] orders;
        mapping(uint256 => uint256) ids;  
    }

    struct OrderBook {
         
        BokkyPooBahsRedBlackTreeLibrary.Tree tree;
         
        mapping(uint256 => uint256[]) uids;
    }

    address constant private RESERVE_ADDRESS = 0x0000000000000000000000000000000000000001;
    uint8 constant private ESTT_2_USDT = 1;
    uint8 constant private USDT_2_ESTT = 2;
    uint256 private _referralBonus;
    uint256 private _exchangeFee;
    uint256 private _minESTTPrice;
    mapping(address => OrderBook) private _orderBooks;  
    mapping(uint256 => address) private _usersAddresses;  
    mapping(address => mapping(address => TokenEntity)) private _ledger;  

    IERC20 private _ESTT;
    IERC20USDTCOMPATIBLE private _USDT;
    uint256 private _ESTTDecimals;
    uint256 private _USDTDecimals;
    address private _ESTTAddress;
    address private _USDTAddress;

    uint192 private _lastUid;

    constructor (address esttAddress, address usdtAddress) public {
        ESTokenInterface potentialESTT = ESTokenInterface(esttAddress);
        require(potentialESTT.isESToken(), "address doesn't match to ESTT");
        _ESTT = IERC20(esttAddress);
        _ESTTDecimals = 10 ** uint256(_ESTT.decimals());
        _ESTTAddress = esttAddress;
        IERC20USDTCOMPATIBLE potentialUSDT = IERC20USDTCOMPATIBLE(usdtAddress);
        _USDTDecimals = potentialUSDT.decimals();
        require(_USDTDecimals == 6, "address doesn't match to USDT");
        _USDT = potentialUSDT;
        _USDTAddress = usdtAddress;
        _USDTDecimals = 10 ** _USDTDecimals;
        _referralBonus = 500_000_000_000_000;  
        _exchangeFee = 8_000_000_000_000_000;  
        _minESTTPrice = _ESTTDecimals;
    }

    function isExchange() pure external override returns (bool) {
        return true;
    }

    function setReferralBonus(uint256 newReferralBonus) external onlyOwner {
        require(newReferralBonus >= 10 ** 18, "negative referral bonus");
        _referralBonus = newReferralBonus.sub(10 ** 18);
    }

    function referralBonus() external view returns (uint256) {
        return _referralBonus.add(10 ** 18);
    }

    function setExchangeFee(uint256 newExchangeFee) external onlyOwner {
        require(newExchangeFee >= 10 ** 18, "negative exchange fee");
        _exchangeFee = newExchangeFee.sub(10 ** 18);
    }

    function exchangeFee() external view returns (uint256) {
        return _exchangeFee.add(10 ** 18);
    }

    function setMinPrice(uint256 newMinPrice) external onlyOwner {
        require(newMinPrice >= 1000000, "min possible price not in range [1, 9999]");
        require(newMinPrice < 10000000000, "min possible price not in range [1, 9999]");
        _minESTTPrice = _USDTDecimals.mul(_ESTTDecimals).div(newMinPrice);
    }

    function minPrice() external view returns (uint256) {
        return _ESTTDecimals.mul(_USDTDecimals).div(_minESTTPrice);
    }

    function getNextPrice (address tokenSrc, uint256 price) external view returns (uint256) {
        return price == 0 ? _orderBooks[tokenSrc].tree.first() : _orderBooks[tokenSrc].tree.next(price);
    }

    function getUidsByPrice (address tokenSrc, uint256 price) external view returns (uint256[] memory) {
        return _orderBooks[tokenSrc].uids[price];
    }

    function getMyOrders () external view returns (uint256[] memory) {
        uint256 lengthESTT = _ledger[_msgSender()][_ESTTAddress].orders.length;
        uint256 lengthUSDT = _ledger[_msgSender()][_USDTAddress].orders.length;
        uint256[] memory myOrderUids = new uint256[](lengthESTT + lengthUSDT);
        for (uint256 i = 0; i < lengthESTT; ++i) {
            myOrderUids[i] = _ledger[_msgSender()][_ESTTAddress].orders[i].uid;
        }
        for (uint256 i = 0; i < lengthUSDT; ++i) {
            myOrderUids[i + lengthESTT] = _ledger[_msgSender()][_USDTAddress].orders[i].uid;
        }
        return myOrderUids;
    }

    function getOrderByUid (uint256 uid) external view returns (uint256, address, uint256, uint256, uint256) {
        (address srcAddress, address user, uint256 index) = _unpackUid(uid);
        Order memory o = _ledger[user][srcAddress].orders[index];
        return (o.uid, o.trader, o.srcAmount, o.destAmount, o.filled);
    }

    function trade (
        address src,
        uint256 srcAmount,
        address dest,
        uint256 destAmount,
        address referral
    ) external {
        uint32 userId = uint32(_msgSender());
        if (_usersAddresses[userId] == address(0)) {
            _usersAddresses[userId] = _msgSender();
        }
        require(_usersAddresses[userId] == _msgSender(), "user address already exist");
        MemoryOrder memory order = MemoryOrder(
            _msgSender(),
            src,
            srcAmount,
            dest,
            destAmount,
            0
        );
        _orderCheck(order);
        _ledger[_msgSender()][src].reservedBalance = _ledger[_msgSender()][src].reservedBalance.add(srcAmount);
         
        if(_trade(order) > 10) {
            _insertOrder(order, src);
        }
        ESTokenInterface esttInerface = ESTokenInterface(_ESTTAddress);
        if (referral != address(0) &&
            esttInerface.parentReferral(_msgSender()) == address(0) &&
            src == _USDTAddress
        ) {
            uint256 price = _getPriceInverted(order);
            uint256 orderBonus = order.filled.mul(price).div(_USDTDecimals);
            esttInerface.setParentReferral(_msgSender(), referral, orderBonus.mul(_referralBonus).div(10 ** 18));
        }
    }

    function continueTrade (uint256 uid) external {
        (address tokenSrcAddress, address user, uint256 index) = _unpackUid(uid);
        Order memory storageOrder = _ledger[user][tokenSrcAddress].orders[index];
        require(_msgSender() == storageOrder.trader, "has no rights to continue trade");
        MemoryOrder memory order = MemoryOrder(
            storageOrder.trader,
            tokenSrcAddress,
            storageOrder.srcAmount,
            tokenSrcAddress == _ESTTAddress ? _USDTAddress : _ESTTAddress,
            storageOrder.destAmount,
            storageOrder.filled
        );
        if(_trade(order) == 0) {
            _removeOrder(uid, order.src, order.trader);
            uint256 price = _getPriceInverted(order);
            _removeOrderFromOrderBook(uid, order.src, price);
        } else {
            _ledger[user][tokenSrcAddress].orders[index].filled = order.filled;
        }
    }

    function cancel (uint256 uid) external {
        (address tokenSrcAddress, address user, uint256 index) = _unpackUid(uid);
        Order memory storageOrder = _ledger[user][tokenSrcAddress].orders[index];
        MemoryOrder memory order = MemoryOrder(
            storageOrder.trader,
            tokenSrcAddress,
            storageOrder.srcAmount,
            tokenSrcAddress == _ESTTAddress ? _USDTAddress : _ESTTAddress,
            storageOrder.destAmount,
            storageOrder.filled
        );
        require(_msgSender() == order.trader, "doesn't have rights to cancel order");
        uint256 restAmount = order.srcAmount.sub(order.filled);
        _ledger[order.trader][order.src].reservedBalance = _ledger[order.trader][order.src].reservedBalance.sub(restAmount);
        _removeOrder(uid, order.src, order.trader);
        uint256 price = _getPriceInverted(order);
        _removeOrderFromOrderBook(uid, order.src, price);
    }

     
     
    function _trade (MemoryOrder memory order) internal returns (uint256) {
        OrderBook storage destOrderBook = _orderBooks[order.dest];
        uint256 maxPrice = _getPrice(order);
        uint256 destKey = destOrderBook.tree.first();

        while (destKey != 0) {
             
            uint256 nextKey = 0;
            if (maxPrice >= destKey) {
                while (destOrderBook.uids[destKey].length != 0) {
                    uint256 uid = destOrderBook.uids[destKey][0];
                    (address src, address user, uint256 index) = _unpackUid(uid);
                    Order memory opposite = _ledger[user][src].orders[index];
                    (bool badOpposite, uint256 filledOpposite) = _match(order, opposite, destKey);
                    opposite.filled = opposite.filled.add(filledOpposite);
                    if (opposite.srcAmount.sub(opposite.filled) < 10 || !badOpposite) {
                        nextKey = destOrderBook.tree.next(destKey);
                        _removeOrder(destOrderBook.uids[destKey][0], order.dest, opposite.trader);
                        _removeOrderFromPriceIndex(destOrderBook, 0, destKey);
                    } else {
                        _ledger[user][src].orders[index].filled = opposite.filled;
                    }
                    if (order.filled == order.srcAmount || gasleft() < 600000) {
                        return order.srcAmount.sub(order.filled);
                    }
                }
            }
            if (order.filled == order.srcAmount || gasleft() < 600000) {
                return order.srcAmount.sub(order.filled);
            }
            if (nextKey > 0)
                destKey = nextKey;
            else
                destKey = destOrderBook.tree.next(destKey);
        }

        if (
            (order.src == _ESTTAddress && maxPrice == _minESTTPrice)
            ||
            (order.src == _USDTAddress && maxPrice == _ESTTDecimals.mul(_USDTDecimals).div(_minESTTPrice))
        ) {
            _match(order, Order(0, address(0), 0, 0, 0), maxPrice);
        }
        return order.srcAmount.sub(order.filled);
    }

    function _insertOrder (MemoryOrder memory order, address src) internal {
        _lastUid++;
        Order memory storageOrder = Order(
            _packUid(_lastUid, src, _msgSender()),
            order.trader,
            order.srcAmount,
            order.destAmount,
            order.filled
        );
        _ledger[order.trader][src].orders.push(storageOrder);
        uint256 length = _ledger[order.trader][src].orders.length;
        _ledger[order.trader][src].ids[storageOrder.uid] = length;
        uint256 price = _getPriceInverted(order);
        _insertOrderToPriceIndex(_orderBooks[src], storageOrder.uid, price);
    }

    function _removeOrder (uint256 uid, address src, address user) internal {
        uint256 index = _ledger[user][src].ids[uid];
        uint256 length = _ledger[user][src].orders.length;
        if (index != length) {
            _ledger[user][src].orders[index.sub(1)] = _ledger[user][src].orders[length.sub(1)];
            uint256 lastOrderUid = _ledger[user][src].orders[length.sub(1)].uid;
            _ledger[user][src].ids[lastOrderUid] = index;
        }
        _ledger[user][src].orders.pop();
        delete  _ledger[user][src].ids[uid];
    }

    function _removeOrderFromOrderBook (uint256 uid, address srcToken, uint256 price) internal {
        uint256[] storage uids = _orderBooks[srcToken].uids[price];
        for (uint256 i = 0; i < uids.length; ++i) {
            if (uids[i] == uid) {
                _removeOrderFromPriceIndex(_orderBooks[srcToken], i, price);
                break;
            }
        }
    }

    function _insertOrderToPriceIndex (OrderBook storage orderBook, uint256 uid, uint256 key) internal {
        if (!orderBook.tree.exists(key)) {
            orderBook.tree.insert(key);
        }
        orderBook.uids[key].push(uid);
    }

    function _removeOrderFromPriceIndex (OrderBook storage orderBook, uint256 index, uint256 key) internal {
        orderBook.uids[key][index] = orderBook.uids[key][orderBook.uids[key].length.sub(1)];
        orderBook.uids[key].pop();
        if (orderBook.uids[key].length == 0) {
            orderBook.tree.remove(key);
            delete orderBook.uids[key];
        }
    }

     
    function _orderCheck (MemoryOrder memory order) internal view {
        uint256 price = _getPrice(order);
        if (order.src == _ESTTAddress) {
            require(order.dest == _USDTAddress, "wrong dest");
            require(price <= _minESTTPrice, "ESTT can't be cheaper USDT");
        } else if (order.src == _USDTAddress) {
            require(order.dest == _ESTTAddress, "wrong dest");
            require(price >= _ESTTDecimals.mul(_USDTDecimals).div(_minESTTPrice), "ESTT can't be cheaper USDT");
        } else {
            revert("wrong src");
        }
        require(order.srcAmount > 0, "wrong src amount");
        require(order.destAmount > 0, "wrong dest amount");
        uint256 totalAllowance = _ledger[order.trader][order.src].reservedBalance.add(order.srcAmount);
        IERC20 ierc20 = IERC20(order.src);
        require(ierc20.allowance(order.trader, address(this)) >= totalAllowance, "not enough balance");
    }

    function _match (MemoryOrder memory order, Order memory opposite, uint256 price) internal returns (bool, uint256) {
        uint256 availableOpposite;
        IERC20 erc20dest = IERC20(order.dest);
        if (opposite.uid != 0) {
            availableOpposite = (opposite.srcAmount.sub(opposite.filled)).mul(price).div(_decimals(order.dest));
        } else {
            availableOpposite = (erc20dest.balanceOf(address(this))).mul(price).div(_decimals(order.dest));
        }
        (uint256 needed, uint256 fee, uint256 neededOpposite, uint256 feeOpposite) = _calcMatch(order, opposite, availableOpposite, price);

        IERC20 erc20src = IERC20(order.src);
        require(erc20src.allowance(order.trader, address(this)) >= needed.add(fee), "src not enough balance");
        if (opposite.uid != 0 && erc20dest.allowance(opposite.trader, address(this)) < neededOpposite) {
            return (false, 0);
        }

        _ledger[order.trader][order.src].reservedBalance = _ledger[order.trader][order.src].reservedBalance.sub(needed.add(fee));
        if (opposite.uid != 0) {
            _ledger[opposite.trader][order.dest].reservedBalance = _ledger[opposite.trader][order.dest].reservedBalance.sub(neededOpposite.add(feeOpposite));
        }

        if (order.src == _ESTTAddress) {
            if (opposite.uid != 0) {
                _ESTT.transferFrom(order.trader, opposite.trader, needed);
                _USDT.transferFrom(opposite.trader, order.trader, neededOpposite);
            } else {
                _ESTT.transferFrom(order.trader, address(this), needed);
                _USDT.transfer(order.trader, neededOpposite);
            }
            if (fee > 0) {
                _ESTT.transferFrom(order.trader, RESERVE_ADDRESS, fee);
            }
        } else {
            if (opposite.uid != 0) {
                _USDT.transferFrom(order.trader, opposite.trader, needed);
                _ESTT.transferFrom(opposite.trader, order.trader, neededOpposite);
            } else {
                _USDT.transferFrom(order.trader, address(this), needed);
                _ESTT.transfer(order.trader, neededOpposite);
            }
            if (feeOpposite > 0) {
                _ESTT.transferFrom(opposite.trader, RESERVE_ADDRESS, feeOpposite);
            }
        }

        order.filled = order.filled.add(needed.add(fee));

        return (true, neededOpposite.add(feeOpposite));
    }

    function _calcMatch (MemoryOrder memory order, Order memory opposite, uint256 availableOpposite, uint256 price) internal view returns
    (
        uint256 needed,
        uint256 fee,
        uint256 neededOpposite,
        uint256 feeOpposite
    ) {
        needed = order.srcAmount.sub(order.filled);
        uint256 available = needed;
        if (needed > availableOpposite) {
            needed = availableOpposite;
        }
        neededOpposite = needed.mul(_decimals(order.dest)).div(price);
        if (order.src == _ESTTAddress && order.trader != address(this)) {
            fee = needed.mul(_exchangeFee).div(10 ** 18);
            if (needed.add(fee) > available) {
                fee = available.mul(_exchangeFee).div(10 ** 18);
                needed = available.sub(fee);
                neededOpposite = needed.mul(_decimals(order.dest)).div(price);
            } else {
                neededOpposite = needed.mul(_decimals(order.dest)).div(price);
            }
        } else if (order.src == _USDTAddress && opposite.uid > 0 && opposite.trader != address(this)) {
            feeOpposite = neededOpposite.mul(_exchangeFee).div(10 ** 18);
            availableOpposite = availableOpposite.mul(_decimals(order.dest)).div(price);
            if (neededOpposite.add(feeOpposite) > availableOpposite) {
                feeOpposite = availableOpposite.mul(_exchangeFee).div(10 ** 18);
                neededOpposite = availableOpposite.sub(feeOpposite);
                needed = neededOpposite.mul(price).div(_decimals(order.dest));
            } else {
                needed = neededOpposite.mul(price).div(_decimals(order.dest));
            }
        }
        return (needed, fee, neededOpposite, feeOpposite);
    }

    function _packUid (uint256 index, address tokenSrc, address userAddress) internal view returns (uint256) {
        uint8 tradeType = tokenSrc == _ESTTAddress ? ESTT_2_USDT : USDT_2_ESTT;
        return index << 40 | (uint64(tradeType) << 32) | uint32(userAddress);
    }

    function _unpackUid (uint256 uid) internal view returns (address, address, uint256) {
        uint8 tradeType = uint8(uid >> 32);
        address tokenSrc;
        if (tradeType == ESTT_2_USDT)
            tokenSrc = _ESTTAddress;
        else if (tradeType == USDT_2_ESTT)
            tokenSrc = _USDTAddress;
        else
            revert("wrong token type");
        address userAddress = _usersAddresses[uint32(uid)];
        uint256 index = _ledger[userAddress][tokenSrc].ids[uid];
         
         
        return (tokenSrc, userAddress, index.sub(1));
    }

    function _getPrice (MemoryOrder memory order) internal view returns (uint256) {
        uint256 decimals = order.src == _ESTTAddress ? _USDTDecimals : _ESTTDecimals;
        return order.srcAmount.mul(decimals).div(order.destAmount);
    }

    function _getPriceInverted (MemoryOrder memory order) internal view returns (uint256) {
        uint256 decimals = order.src == _ESTTAddress ? _ESTTDecimals : _USDTDecimals;
        return order.destAmount.mul(decimals).div(order.srcAmount);
    }

    function _decimals (address tokenAddress) internal view returns (uint256) {
        if (tokenAddress == _ESTTAddress) {
            return _ESTTDecimals;
        }
        return _USDTDecimals;
    }
}

 

pragma solidity ^0.6.0;





 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

     
    mapping (address => uint256) internal _balances;     

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
     
    function balanceOf(address account) public view override virtual returns (uint256) {     
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

 

pragma solidity ^0.6.2;







contract ESToken is ESTokenInterface, Context, ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    struct Referral {
        address user;
        uint256 expIndex;
    }

    struct ParentRef {
        address user;
        uint256 index;
    }

    address constant private RESERVE_ADDRESS = 0x0000000000000000000000000000000000000001;
    address private _reserveAddress;
    address private _exchangeAddress;

    uint256 private _dailyInterest;
    uint256 private _referralInterest;
    uint256 private _accrualTimestamp;
    uint256 private _expIndex;
    uint256 private _expReferralIndex;
    uint256 private _holdersCounter;

    mapping (address => uint256) private _holderIndex;
    mapping (address => ParentRef) private _parentRef;
    mapping (address => Referral[]) private _referrals;

    modifier onlyExchange () {
        require(_msgSender() == address(_exchangeAddress), "caller is not allowed to do some");
        _;
    }

    constructor () public ERC20("ESToken", "ESTT") {
        _setupDecimals(6);
        _dailyInterest = 300_000_000_000_000;  
        _referralInterest = 150_000_000_000_000;  
        _expIndex = 10 ** 18;
        _expReferralIndex = 10 ** 18;
        _accrualTimestamp = block.timestamp;
    }

    function init(address newExchangeAddress) external onlyOwner {
        ExchangeInterface exchangeI = ExchangeInterface(newExchangeAddress);
        require(exchangeI.isExchange(), "ESToken: newExchangeAddress does not match the exchange");
        require(_reserveAddress == address(0), "ESToken: re-initialization");
        _reserveAddress = RESERVE_ADDRESS;
        _exchangeAddress = newExchangeAddress;
        _mint(_exchangeAddress, 70_000_000 * 10 ** uint256(decimals()));
        _mint(_reserveAddress, 25_000_000 * 10 ** uint256(decimals()));
        _mint(_msgSender(), 5_000_000 * 10 ** uint256(decimals()));
    }

    function isESToken() pure external override returns (bool) {
        return true;
    }

    function setDailyInterest(uint256 newDailyInterest) external onlyOwner {
        require(newDailyInterest >= 10 ** 18, "ESToken: negative daily interest");
        _dailyInterest = newDailyInterest.sub(10 ** 18);
    }

    function reserveAddress() external view returns (address) {
        return _reserveAddress;
    }

    function exchangeAddress() external view returns (address) {
        return _exchangeAddress;
    }

    function dailyInterest() external view returns (uint256) {
        return _dailyInterest.add(10 ** 18);
    }

    function setReferralInterest(uint256 newReferralInterest) external onlyOwner {
        require(newReferralInterest >= 10 ** 18, "ESToken: negative referral interest");
        _referralInterest = newReferralInterest.sub(10 ** 18);
    }

    function referralInterest() external view returns (uint256) {
        return _referralInterest.add(10 ** 18);
    }

    function parentReferral(address user) external view override returns (address) {
        return _parentRef[user].user;
    }

    function holdersCounter() external view returns (uint256) {
        return _holdersCounter;
    }

    function setParentReferral(address user, address parent, uint256 reward) external override onlyExchange {
        require(parent != _reserveAddress &&
                parent != _exchangeAddress &&
                parent != owner(), "Wrong referral");
        _updateBalance(parent);
        _parentRef[user].user = parent;
        _parentRef[user].index = _referrals[parent].length;
        Referral memory referral = Referral(user, _expReferralIndex);
        _referrals[parent].push(referral);
        if (_balances[_reserveAddress] < reward) {
            reward = _balances[_reserveAddress];
        }
        _balances[parent] = _balances[parent].add(reward);
        _balances[_reserveAddress] = _balances[_reserveAddress].sub(reward);
    }

    function getMyReferrals() public view returns (address[] memory) {
        uint256 length = _referrals[_msgSender()].length;
        address[] memory addresses = new address[](length);
        for (uint i = 0; i < length; ++i) {
            addresses[i] = _referrals[_msgSender()][i].user;
        }
        return addresses;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balanceByTime(account, block.timestamp);
    }

    function balanceByTime(address account, uint256 timestamp) public view returns (uint256) {
        if (account == _reserveAddress ||
            account == owner() ||
            account == _exchangeAddress) {
            return super.balanceOf(account);
        }
        uint256 bonus = 0;
        for(uint256 i = 0; i < _referrals[account].length; ++i) {
            uint256 newExpReferralIndex = _calculateInterest(timestamp, _referralInterest, _expReferralIndex);
            Referral memory referral = _referrals[account][i];
            if (referral.expIndex < (10 ** 18) || _holderIndex[referral.user] < (10 ** 18)) {
                continue;
            }
            uint256 newBalanceOfPartner = _balances[referral.user].mul(_expIndex).div(_holderIndex[referral.user]);
            uint256 bonusBalance = newBalanceOfPartner.mul(newExpReferralIndex).div(referral.expIndex);
            uint256 partnerBonus = bonusBalance.sub(newBalanceOfPartner);
            bonus = bonus.add(partnerBonus);
        }
        if (_balances[account] > 0 && _holderIndex[account] > 0) {
            uint256 newExpIndex = _calculateInterest(timestamp, _dailyInterest, _expIndex);
            return _balances[account].mul(newExpIndex).div(_holderIndex[account]).add(bonus);  
        }
        return super.balanceOf(account).add(bonus);
    }

    function accrueInterest() public {
        _expIndex = _calculateInterest(block.timestamp, _dailyInterest, _expIndex);
        _expReferralIndex = _calculateInterest(block.timestamp, _referralInterest, _expReferralIndex);
        _accrualTimestamp = block.timestamp;
    }

    function _calculateInterest(uint256 timestampNow, uint256 interest, uint256 prevIndex) internal view returns (uint256) {
        uint256 period = timestampNow.sub(_accrualTimestamp);
        if (period < 60) {
            return prevIndex;
        }
        uint256 interestFactor = interest.mul(period);
        uint newExpIndex = (interestFactor.mul(prevIndex).div(10 ** 18).div(86400)).add(prevIndex);
        return newExpIndex;
    }

    function _updateBalance(address account) internal {
        if (account == _reserveAddress ||
            account == owner() ||
            account == _exchangeAddress) {
            return ;
        }
        if (_holderIndex[account] > 0) {
            uint256 newBalance = _balances[account].mul(_expIndex).div(_holderIndex[account]);  
            uint256 delta = newBalance.sub(_balances[account]);
            for(uint256 i = 0; i < _referrals[account].length; ++i) {
                Referral storage referral = _referrals[account][i];
                if (referral.expIndex < (10 ** 18) || _holderIndex[referral.user] < (10 ** 18)) {
                    continue;
                }
                uint256 newBalanceOfPartner = _balances[referral.user].mul(_expIndex).div(_holderIndex[referral.user]);
                uint256 bonusBalance = newBalanceOfPartner.mul(_expReferralIndex).div(referral.expIndex);
                uint256 partnerBonus = bonusBalance.sub(newBalanceOfPartner);
                newBalance = newBalance.add(partnerBonus);
                delta = delta.add(partnerBonus);
                referral.expIndex = _expReferralIndex;
            }
            if (delta != 0 && _balances[_reserveAddress] >= delta) {
                if (_balances[account] == 0) {
                    _holdersCounter++;
                }
                _balances[account] = newBalance;
                _balances[_reserveAddress] = _balances[_reserveAddress].sub(delta);
                if (_parentRef[account].user != address(0)) {
                    _referrals[_parentRef[account].user][_parentRef[account].index].expIndex = _expReferralIndex;
                }
            }
        }
        _holderIndex[account] = _expIndex;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        accrueInterest();
        if (from != address(0)) {
            _updateBalance(from);
            _updateBalance(to);
        }
        if (_balances[from] == amount) {
            _holdersCounter--;
        }
        if (_balances[to] == 0) {
            _holdersCounter++;
        }
        super._beforeTokenTransfer(from, to, amount);
    }
}