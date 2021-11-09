 
    pragma solidity ^0.4.11;
    contract CMCToken  {
        string public constant name = "CMC Token";
        string public constant symbol = "CMC";
        uint public constant decimals = 18;
        uint256 _totalSupply = 1000 * 10**decimals;

        function totalSupply() public constant returns (uint256 supply) {
            return _totalSupply;
        }

        function balanceOf(address _owner) public constant returns (uint256 balance) {
            return balances[_owner];
        }

        function approve(address _spender, uint256 _value) public returns (bool success) {
            allowed[msg.sender][_spender] = _value;
            emit Approval(msg.sender, _spender, _value);
            return true;
        }

        function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
          return allowed[_owner][_spender];
        }

        mapping(address => uint256) balances;          
        mapping(address => uint256) distBalances;      
        mapping(address => mapping (address => uint256)) allowed;

        uint public baseStartTime;  

         
         

        address public founder;
        uint256 public distributed = 0;

        event AllocateFounderTokens(address indexed sender);
        event Transfer(address indexed _from, address indexed _to, uint256 _value);
        event Approval(address indexed _owner, address indexed _spender, uint256 _value);

         
        constructor () public {
            founder = msg.sender;
        }

        function setStartTime(uint _startTime) public {
            if (msg.sender!=founder) revert();
            baseStartTime = _startTime;
        }

         
        function distribute(uint256 _amount, address _to) public {
            if (msg.sender!=founder) revert();
            if (distributed + _amount > _totalSupply) revert();

            distributed += _amount;
            balances[_to] += _amount;
            distBalances[_to] += _amount;
        }

         
         
        function transfer(address _to, uint256 _value)public returns (bool success) {
            if (now < baseStartTime) revert();

             
             
            if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
                uint _freeAmount = freeAmount(msg.sender);
                if (_freeAmount < _value) {
                    return false;
                } 

                balances[msg.sender] -= _value;
                balances[_to] += _value;
                emit Transfer(msg.sender, _to, _value);
                return true;
            } else {
                return false;
            }
        }

        function freeAmount(address user) public view returns (uint256 amount) {
             
            if (user == founder) {
                return balances[user];
            }

             
            if (now < baseStartTime) {
                return 0;
            }

             
            uint monthDiff = (now - baseStartTime) / (30 days);

             
            if (monthDiff > 15) {
                return balances[user];
            }

             
            uint unrestricted = distBalances[user] / 10 + distBalances[user] * 6 / 100 * monthDiff;
            if (unrestricted > distBalances[user]) {
                unrestricted = distBalances[user];
            }

             
            if (unrestricted + balances[user] < distBalances[user]) {
                amount = 0;
            } else {
                amount = unrestricted + (balances[user] - distBalances[user]);
            }

            return amount;
        }

         
        function changeFounder(address newFounder) public {
            if (msg.sender!=founder) revert();
            founder = newFounder;
        }

         
         
        function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
            if (msg.sender != founder) revert();

             
            if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
                uint _freeAmount = freeAmount(_from);
                if (_freeAmount < _value) {
                    return false;
                } 

                balances[_to] += _value;
                balances[_from] -= _value;
                allowed[_from][msg.sender] -= _value;
                emit Transfer(_from, _to, _value);
                return true;
            } else { return false; }
        }

        function() payable public {
            if (!founder.call.value(msg.value)()) revert(); 
        }
    }