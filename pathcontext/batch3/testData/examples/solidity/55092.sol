pragma solidity ^0.4.18;

 
 
 
 
 

library RedBlackTree {

    struct Item {
        bool red;
        uint32 parent;
        uint32 left;
        uint32 right;
        uint value;
    }

    struct Tree {
        uint32 root;
        mapping(uint32 => Item) items;
    }
    
    function find(Tree storage tree, uint value, bool isSell) public constant returns (uint32 parentId) {

        uint32 id = tree.root;
        parentId = id;

        if (id == 0)
            return;

        Item storage item = tree.items[id];

        if (isSell == true)
        {
            while (id != 0)
            {
                if (value == item.value)
                {
                    id = item.right;
                    while (id != 0 && value == item.value)
                    {
                        parentId = id;
                        id = item.right;
                    }
                    return;
                }
    
                parentId = id;
    
                if (value > item.value)
                {
                    id = item.right;
    
                    if (id != 0)
                        parentId = id;
    
                    while (id != 0 && value == item.value)
                    {
                        parentId = id;
                        id = item.right;
                    }
    
                }
                else
                {
                    id = item.left;
    
                    if (id != 0)
                        parentId = id;
    
                    while (id != 0 && value == item.value)
                    {
                        parentId = id;
                        id = item.right;
                    }
                }
            }
        }
        else
        {
            while (id != 0)
            {
            if (value == item.value)
            {
                id = item.left;
                while (id != 0 && value == item.value)
                {
                    parentId = id;
                    id = item.left;
                }
                return;
            }

            parentId = id;

            if (value > item.value)
            {
                id = item.right;

                if (id != 0)
                    parentId = id;

                while (id != 0 && value == item.value)
                {
                    parentId = id;
                    id = item.left;
                }

            }
            else
            {
                id = item.left;

                if (id != 0)
                    parentId = id;

                while (id != 0 && value == item.value)
                {
                    parentId = id;
                    id = item.left;
                }
            }
        }
        }
        return parentId;
    }
    
    function placeAfter(Tree storage tree, uint32 parent, uint32 id, uint value, bool isSell) internal
    {
        Item memory item;
        item.value = value;
        item.parent = parent;
        item.red = true;

        if (parent != 0) {
            Item storage itemParent = tree.items[parent];

            if (value == itemParent.value)
            {
                if (isSell == true)
                {
                    item.right = itemParent.right;
    
                    if (item.right != 0)
                        tree.items[item.right].parent = id;
    
                    if (parent != 0)
                        itemParent.right = id;
                }
                else
                {
                    item.left = itemParent.left;
    
                    if (item.left != 0)
                        tree.items[item.left].parent = id;
    
                    if (parent != 0)
                        itemParent.left = id;
                }
            }
            else if (value < itemParent.value)
            {
                itemParent.left = id;
            }
            else
            {
                itemParent.right = id;
            }
        }
        else
        {
            tree.root = id;
        }

        tree.items[id] = item;
        insert1(tree, id);
    }

    function insert1(Tree storage tree, uint32 n) private
    {
        uint32 p = tree.items[n].parent;
        if (p == 0)
        {
            tree.items[n].red = false;
        }
        else
        {
            if (tree.items[p].red)
            {
                uint32 g = grandparent(tree, n);
                uint32 u = uncle(tree, n);

                if (u != 0 && tree.items[u].red)
                {
                    tree.items[p].red = false;
                    tree.items[u].red = false;
                    tree.items[g].red = true;
                    insert1(tree, g);
                }
                else
                {
                    if ((n == tree.items[p].right) && (p == tree.items[g].left))
                    {
                        rotateLeft(tree, p);
                        n = tree.items[n].left;
                    }
                    else if ((n == tree.items[p].left) && (p == tree.items[g].right))
                    {
                        rotateRight(tree, p);
                        n = tree.items[n].right;
                    }

                    insert2(tree, n);
                }
            }
        }
    }

    function insert2(Tree storage tree, uint32 n) internal
    {
        uint32 p = tree.items[n].parent;
        uint32 g = grandparent(tree, n);

        tree.items[p].red = false;
        tree.items[g].red = true;

        if ((n == tree.items[p].left) && (p == tree.items[g].left))
        {
            rotateRight(tree, g);
        }
        else
        {
            rotateLeft(tree, g);
        }
    }

    function remove(Tree storage tree, uint32 n) internal {
        uint32 successor;
        uint32 nRight = tree.items[n].right;
        uint32 nLeft = tree.items[n].left;

        if (nRight != 0 && nLeft != 0)
        {
            successor = nRight;
            while (tree.items[successor].left != 0)
            {
                successor = tree.items[successor].left;
            }

            uint32 sParent = tree.items[successor].parent;

            if (sParent != n)
            {
                tree.items[sParent].left = tree.items[successor].right;
                tree.items[successor].right = nRight;
                tree.items[sParent].parent = successor;
            }

            tree.items[successor].left = nLeft;

            if (nLeft != 0)
            {
                tree.items[nLeft].parent = successor;
            }
        }
        else if (nRight != 0)
        {
            successor = nRight;
        }
        else
        {
            successor = nLeft;
        }
        
        uint32 p = tree.items[n].parent;

        if (successor != 0)
            tree.items[successor].parent = p;

        if (p != 0)
        {
            if (n == tree.items[p].left)
            {
                tree.items[p].left = successor;
            }
            else
            {
                tree.items[p].right = successor;
            }
        }
        else
        {
            tree.root = successor;
        }

        if (!tree.items[n].red && successor != 0)
        {
            if (tree.items[successor].red)
            {
                tree.items[successor].red = false;
            }
            else
            {
                delete1(tree, successor);
            }
        }

        delete tree.items[n];
        delete tree.items[0];
    }

    function delete1(Tree storage tree, uint32 n) private
    {
        uint32 p = tree.items[n].parent;

        if (p != 0) {
            uint32 s = sibling(tree, n);
            if (tree.items[s].red)
            {
                tree.items[p].red = true;
                tree.items[s].red = false;
                if (n == tree.items[p].left)
                {
                    rotateLeft(tree, p);
                }
                else
                {
                    rotateRight(tree, p);
                }
            }
            delete2(tree, n);
        }
    }

    function delete2(Tree storage tree, uint32 n) private
    {
        uint32 s = sibling(tree, n);
        uint32 p = tree.items[n].parent;
        uint32 sLeft = tree.items[s].left;
        uint32 sRight = tree.items[s].right;
        if (!tree.items[p].red && !tree.items[s].red && !tree.items[sLeft].red && !tree.items[sRight].red)
        {
            tree.items[s].red = true;
            delete1(tree, p);
        }
        else
        {
            if (tree.items[p].red && !tree.items[s].red && !tree.items[sLeft].red && !tree.items[sRight].red)
            {
                tree.items[s].red = true;
                tree.items[p].red = false;
            }
            else
            {
                if (!tree.items[s].red)
                {
                    if (n == tree.items[p].left && !tree.items[sRight].red && tree.items[sLeft].red)
                    {
                        tree.items[s].red = true;
                        tree.items[sLeft].red = false;
                        rotateRight(tree, s);
                    }
                    else if (n == tree.items[p].right && !tree.items[sLeft].red && tree.items[sRight].red)
                    {
                        tree.items[s].red = true;
                        tree.items[sRight].red = false;
                        rotateLeft(tree, s);
                    }
                }
                
                tree.items[s].red = tree.items[p].red;
                tree.items[p].red = false;

                if (n == tree.items[p].left)
                {
                    tree.items[sRight].red = false;
                    rotateLeft(tree, p);
                }
                else
                {
                    tree.items[sLeft].red = false;
                    rotateRight(tree, p);
                }
            }
        }
    }

    function grandparent(Tree storage tree, uint32 n) private returns (uint32)
    {
        return tree.items[tree.items[n].parent].parent;
    }

    function uncle(Tree storage tree, uint32 n) private returns (uint32)
    {
        uint32 g = grandparent(tree, n);
        if (g == 0)
            return 0;

        if (tree.items[n].parent == tree.items[g].left)
            return tree.items[g].right;

        return tree.items[g].left;
    }

    function sibling(Tree storage tree, uint32 n) private returns (uint32)
    {
        uint32 p = tree.items[n].parent;

        if (n == tree.items[p].left)
        {
            return tree.items[p].right;
        }
        else
        {
            return tree.items[p].left;
        }
    }

    function rotateRight(Tree storage tree, uint32 n) private
    {
        uint32 pivot = tree.items[n].left;
        uint32 p = tree.items[n].parent;
        tree.items[pivot].parent = p;

        if (p != 0)
        {
            if (tree.items[p].left == n)
            {
                tree.items[p].left = pivot;
            }
            else
            {
                tree.items[p].right = pivot;
            }
        }
        else
        {
            tree.root = pivot;
        }

        tree.items[n].left = tree.items[pivot].right;

        if (tree.items[pivot].right != 0)
        {
            tree.items[tree.items[pivot].right].parent = n;
        }

        tree.items[n].parent = pivot;
        tree.items[pivot].right = n;
    }

    function rotateLeft(Tree storage tree, uint32 n) private
    {
        uint32 pivot = tree.items[n].right;
        uint32 p = tree.items[n].parent;
        tree.items[pivot].parent = p;

        if (p != 0) {
            if (tree.items[p].left == n)
            {
                tree.items[p].left = pivot;
            }
            else
            {
                tree.items[p].right = pivot;
            }
        }
        else
        {
            tree.root = pivot;
        }

        tree.items[n].right = tree.items[pivot].left;

        if (tree.items[pivot].left != 0)
        {
            tree.items[tree.items[pivot].left].parent = n;
        }

        tree.items[n].parent = pivot;
        tree.items[pivot].left = n;
    }
}
library SafeMath2 {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract SafeMath {
  function safeMul(uint a, uint b) pure public returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) pure public returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) pure public returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

contract Token {
   
  function totalSupply() constant public returns (uint256 supply) {}

   
   
  function balanceOf(address _owner) constant public returns (uint256 balance) {}

   
   
   
   
  function transfer(address _to, uint256 _value) public returns (bool success) {}

   
   
   
   
   
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

   
   
   
   
  function approve(address _spender, uint256 _value) returns (bool success) {}

   
   
   
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  uint public decimals;
  string public name;
}

contract StandardToken is Token {

  function transfer(address _to, uint256 _value) returns (bool success) {
     
     
     
    if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
     
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
    } else { return false; }
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
     
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
     
      balances[_to] += _value;
      balances[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      Transfer(_from, _to, _value);
      return true;
    } else { return false; }
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  mapping(address => uint256) balances;

  mapping (address => mapping (address => uint256)) allowed;

  uint256 public totalSupply;
}

contract ReserveToken is StandardToken, SafeMath {
  address public minter;
  function ReserveToken() {
    minter = msg.sender;
  }
  function create(address account, uint amount) {
    if (msg.sender != minter) throw;
    balances[account] = safeAdd(balances[account], amount);
    totalSupply = safeAdd(totalSupply, amount);
  }
  function destroy(address account, uint amount) {
    if (msg.sender != minter) throw;
    if (balances[account] < amount) throw;
    balances[account] = safeSub(balances[account], amount);
    totalSupply = safeSub(totalSupply, amount);
  }
}

contract AccountLevels {
   
   
   
   
  function accountLevel(address user) constant returns(uint) {}
}

contract AccountLevelsTest is AccountLevels {
  mapping (address => uint) public accountLevels;

  function setAccountLevel(address user, uint level) {
    accountLevels[user] = level;
  }

  function accountLevel(address user) constant returns(uint) {
    return accountLevels[user];
  }
}

contract DEXHIGH_V1
{
    using SafeMath2 for uint;
    using RedBlackTree for RedBlackTree.Tree;

    struct OpenOrder
    {
        uint32 startId;
        mapping (uint64 => ListItem) id_orderList;
    }
    
    mapping (address => OpenOrder) holder_OpenOrder;
    
    function AddOpenOrder(uint32 id) private
    {
        OpenOrder storage openOrder = holder_OpenOrder[msg.sender];
        ListItem listItem;
        if (id != 0)
        {
            if (openOrder.startId != 0)
            {
                listItem.next = openOrder.startId;
                openOrder.id_orderList[openOrder.startId].prev = id;
            }
            openOrder.startId = id;
        }
        openOrder.id_orderList[id] = listItem;
    }
    
    function RemoveOpenOrder(uint32 id)
    {
        OpenOrder storage openOrder = holder_OpenOrder[msg.sender];
        if (id != 0)
        {
            ListItem storage removeItem = openOrder.id_orderList[id];
            ListItem replaceItem;
            if (removeItem.next != 0)
            {
                replaceItem = openOrder.id_orderList[removeItem.next];
                replaceItem.prev = removeItem.prev;
            }
    
            if (removeItem.prev != 0)
            {
                replaceItem = openOrder.id_orderList[removeItem.prev];
                replaceItem.next = removeItem.next;
            }
    
            delete openOrder.id_orderList[id];
        }
    }
    
    struct Balance
    {
        uint reserved;
        uint available;
    }

    struct ListItem
    {
        uint32 prev;
        uint32 next;
    }

    struct Order
    {
        address owner;
        address token;
        uint amount;
        uint price;
        bool sell;
        uint64 timestamp;
    }

    struct Pair
    {
        mapping (uint64 => ListItem) orderbook;
        RedBlackTree.Tree pricesTree;
        uint32 bestBid;
        uint32 bestAsk;
    }

    mapping (address => mapping (address => Balance)) private balances;

    uint32 lastOrderId;
    mapping(uint32 => Order) orders;
    mapping(address => Pair) pairs;

    event Deposit(address indexed token, address indexed owner, uint amount);
    event Withdraw(address indexed token, address indexed owner, uint amount);
    
     
     
     
    event NewOrder(address indexed token, address indexed owner, uint32 id, bool isSell, uint price); 
    event NewAsk(address indexed token, uint price);
    event NewBid(address indexed token, uint price);
    event NewTrade(address indexed token, uint32 indexed bidId, uint32 indexed askId, bool isSell, uint price, uint amount, uint64 timestamp);

    modifier isToken(address token) {
        require(token != 0);
        _;
    }

    function DEXHIGH_V1() public {
    }

    function depositETH() payable public
    {
        Balance storage balance = balances[0][msg.sender];
        balance.available = balance.available.add(msg.value);
        Deposit(0, msg.sender, msg.value);
    }

    function withdrawETH(uint amount) public
    {
        Balance storage balance = balances[0][msg.sender];
        balance.available = balance.available.sub(amount);
        require(msg.sender.call.value(amount)());
        Withdraw(0, msg.sender, amount);
    }

    function depositERC20(StandardToken token, uint amount) public
    {
        Balance storage balance = balances[token][msg.sender];
        token.transferFrom(msg.sender, this, amount);
        balance.available = balance.available.add(amount);
        Deposit(token, msg.sender, amount);
    }
 
    function withdrawERC20(StandardToken token, uint amount) public
    {
        Balance storage balance = balances[token][msg.sender];
        balance.available = balance.available.sub(amount);
        token.transfer(msg.sender, amount);
        Withdraw(token, msg.sender, amount);
    }
} 