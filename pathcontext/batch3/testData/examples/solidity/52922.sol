pragma solidity ^0.4.23;

contract Ownable {
    address public owner;
  
  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}
contract Betting is Ownable {
     
    mapping(address => uint256) public balances;
     
    uint8[] outcomes; 
     
    mapping(address => uint8) public bets;
    mapping(uint256 => address) accountIndex;
    mapping(address=>uint256) returnAmmount;
    uint8 public playerNb;
    uint sumColected;
    
    constructor(uint8[] _o) public {
        outcomes = _o;
        playerNb = 0;
        sumColected = 0;
    }

    function getOutcomes() public view returns(uint8[]) {
        return outcomes;
    }

    function min(uint8 _a, uint8 _b) internal pure returns(uint8) {
        if (_a < _b) return _a;
        else return _b;
    }
    
    function contains(uint8[] _array, uint8 _s) public pure returns(bool) {
        for (uint8 _i=0; _i<=_array.length; _i++) {
            if (_array[_i] == _s) return true;
        }
        return false;
    }
    
    function bet(uint8 _s) public payable {
        require(balances[msg.sender] == 0);
        require(playerNb <= 2); 
        require(contains(outcomes, _s));
        balances[msg.sender] = msg.value;
        bets[msg.sender] = _s;
        playerNb++;
        sumColected+=msg.value;
        accountIndex[playerNb]=msg.sender;
        if (playerNb == 2) startRound();
    }
    
     function rng() public view returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty))%outcomes.length);
    }

    function startRound() internal {
        uint8 choice = bets[accountIndex[0]];
        uint8 sameChoice = 0;
        uint8 rngResult = rng();
         
        for (uint8 _i=1; _i<playerNb; _i++) {
            if (bets[accountIndex[_i]] == choice) sameChoice++;
        }
         
        if (sameChoice == playerNb) {
            for (uint8 _j=0; _j<playerNb; _j++) {
                (accountIndex[_j]).transfer(balances[accountIndex[_j]]);
            }
        }
         
        else {
             
            for (uint8 _k=0; _k<playerNb; _k++) {
                if (outcomes[rngResult] == bets[accountIndex[_k]]) {
                     
                    if ((balances[accountIndex[_k]]*2) == sumColected) 
                        (accountIndex[_k]).transfer(balances[accountIndex[_k]]*playerNb);
                     
                    else if ((balances[accountIndex[_k]]*2) > sumColected) {
                        (accountIndex[_k]).transfer(sumColected);
                        }
                         
                         
                        else {
                             (accountIndex[_k]).transfer(balances[accountIndex[_k]]*playerNb);
                             for (uint8 _l=0; _l<playerNb; _l++) {
                                 if (accountIndex[_l] != accountIndex[_k]) {
                                      (accountIndex[_l]).transfer(sumColected - balances[accountIndex[_l]]);
                                 }
                             }
                        }
                }        
            }
        }
        resetRound();
    }
    
    function resetRound() internal {
        for (uint8 _i=0; _i<playerNb; _i++) {
            balances[accountIndex[_i]] == 0;
            bets[accountIndex[_i]] == 0;
            accountIndex[_i] = address(0);
        }
        playerNb = 0;
    }
        
}