 

 

pragma solidity ^0.6.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
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
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
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

         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

 

pragma solidity ^0.6.0;





 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

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

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
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

 

pragma solidity ^0.6.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 

pragma solidity ^0.6.2;


 
interface IERC721 is IERC165 {
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

     
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) external view returns (address owner);

     
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

     
    function transferFrom(address from, address to, uint256 tokenId) external;

     
    function approve(address to, uint256 tokenId) external;

     
    function getApproved(uint256 tokenId) external view returns (address operator);

     
    function setApprovalForAll(address operator, bool _approved) external;

     
    function isApprovedForAll(address owner, address operator) external view returns (bool);

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

 

pragma solidity ^0.6.0;

 
interface IERC721Receiver {
     
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);
}

 

pragma solidity ^0.6.0;

 
contract WrapperSimple is ERC20, IERC721Receiver {
     
    address public _coreAddress;
    IERC721 private _coreContract;

     
    uint256 private _baseWrappedAmount;

     
    uint256[] private _tokenIds;

     
    mapping(uint256 => uint256) private _indices;

     
    address _depositor;

     
     
     
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

	constructor () ERC20("Wrapped Gods Unchained", "WGODS") public {
         
        _baseWrappedAmount = uint256(10) ** decimals();

        address contractAddress = 0x6EbeAf8e8E946F0716E6533A6f2cefc83f60e8Ab;  

         
        _coreAddress = contractAddress;
        _coreContract = IERC721(_coreAddress);

        _status = _NOT_ENTERED;
    }

     

     
    event TokenDeposited(uint256 tokenId);

     
    event TokenWithdrawn(uint256 tokenId);

     

     
    function onERC721Received(address operator, address from, uint256, bytes calldata) override external returns (bytes4) {
         
        require(_status == _ENTERED, "Reentrancy: non-reentrant call");

        require(operator == address(this), "Cannot call directly");
        require(from != address(0), "Zero address not allowed");
        require(from == _depositor, "Depositor mismatch");
        require(msg.sender == _coreAddress, "Token not allowed in vault");

         
        return IERC721Receiver.onERC721Received.selector;
    }

     

     
    function canWithdrawToken(uint256 tokenId) external view returns (bool) {
        return _indices[tokenId] != 0;
    }

    function size() external view returns (uint256) {
        return _tokenIds.length;
    }

     

     
    function deposit(uint256[] calldata tokenIds) external {
         
        require(_status != _ENTERED, "Reentrancy: reentrant call");
        _status = _ENTERED;

         
        uint256 _length = _tokenIds.length;

         
        uint count = tokenIds.length;
        require(count > 0, "No tokens to deposit");
        require(_length + count > _length, "Vault full");

         
        _depositor = msg.sender;

         
        uint256 tokenId;
        for (uint256 i; i < count; i ++) {
             
            tokenId = tokenIds[i];
            _tokenIds.push(tokenId);
            _indices[tokenId] = ++_length;

             
             
             
            require(_coreContract.ownerOf(tokenId) == msg.sender, "You don't own this token");
            _coreContract.safeTransferFrom(msg.sender, address(this), tokenId);
        
             
            emit TokenDeposited(tokenId);
        }

         
        _mint(msg.sender, count * _baseWrappedAmount);

         
        _depositor = address(0);
        _status = _NOT_ENTERED;
    }

     
    function withdrawAny(address destination, uint256 count) external {
         
        require(_status != _ENTERED, "Reentrancy: reentrant call");
        _status = _ENTERED;

         
        uint256 _length = _tokenIds.length;

         
        if (count > _length) {
            count = _length;
        }

        require(count > 0, "No tokens to withdraw");
        require(destination != address(0), "Zero address not allowed");
        require(destination != address(this), "Vault address not allowed");
        require(destination != _coreAddress, "Token contract not allowed");

         
        uint256 index;
        uint256 tokenId;
        for (uint256 i; i < count; i ++) {
             
            index = (--_length) - i;
            tokenId = _tokenIds[index];
            _tokenIds.pop();
            _indices[tokenId] = 0;

             
            _coreContract.safeTransferFrom(address(this), destination, tokenId);
        
             
            emit TokenWithdrawn(tokenId);
        }

         
        _burn(msg.sender, count * _baseWrappedAmount);

         
        _status = _NOT_ENTERED;
    }

     
    function withdrawTokens(address destination, uint256[] calldata tokenIds) external {
         
        require(_status != _ENTERED, "Reentrancy: reentrant call");
        _status = _ENTERED;

         
        uint256 _length = _tokenIds.length;

        require(_length > 0, "No tokens to withdraw");
        require(destination != address(0), "Zero address not allowed");
        require(destination != address(this), "Vault address not allowed");
        require(destination != _coreAddress, "Token contract not allowed");

        uint256 count = tokenIds.length;
        uint256 index;
        uint256 tokenId;
        uint256 tailTokenId;
        uint256 withdrawnCount;
        for (uint256 i; i < count; i ++) {
             
            tokenId = tokenIds[i];
            index = _indices[tokenId];
            if (index != 0 && _tokenIds[index - 1] == tokenId) {
                 
                tailTokenId = _tokenIds[--_length];
                _tokenIds[index - 1] == tailTokenId;
                _tokenIds.pop();
                _indices[tailTokenId] = index;
                _indices[tokenId] = 0;

                 
                _coreContract.safeTransferFrom(address(this), destination, tokenId);

                withdrawnCount++;
            
                 
                emit TokenWithdrawn(tokenId);
            }
        }

         
        _burn(msg.sender, withdrawnCount * _baseWrappedAmount);

         
        _status = _NOT_ENTERED;
    }
}