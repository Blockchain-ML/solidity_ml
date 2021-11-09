pragma solidity ^0.4.0;

contract Roulette {
     
     
    address company_address;
    
     
    uint[][] bet_lookup;
    
     
    struct Player {
        address wallet_address;
        uint[]  bet_types;
        uint[]  bet_amount;
    }
    
     
    mapping(uint => uint) payout_table;
    
     
    constructor(address company) public {
         
        company_address = company;
        
         
         
         
         
    }
    
     
     
     
     
     
     
    function bet(uint[] b_type, uint[] b_amount) payable public {
         
        require(b_type.length != b_amount.length);
        
         
        require(b_type.length > 0 && b_amount.length > 0);
        
        address sender_address = msg.sender;
        
        Player memory p;
        p.wallet_address = sender_address;
        p.bet_types      = b_type;
        p.bet_amount     = b_amount;
        
         
        uint result_number = getRandomResult();
        
         
        uint[] memory wining_list = getWiningType(result_number);
        uint win_amount           = 0;
        uint capital_amount       = 0;
        uint loss_amount          = 0;
        
         
        for(uint i = 0; i < p.bet_types.length; i++) {
            uint is_win = 0;
            
            for(uint j = 0; j < wining_list.length; j++) {
                 
                if(i == j) {
                    win_amount     += (p.bet_amount[0] * payout_table[i]);
                    capital_amount += p.bet_amount[0];
                    is_win = 1;
                }
                
                break;
            }
            
             
            if(is_win <= 0) {
                loss_amount += p.bet_amount[0];
            }
        }
        
         
        if(win_amount + capital_amount> 0) {
            msg.sender.transfer(win_amount + capital_amount);
        }
        
         
        if(loss_amount > 0) {
            company_address.transfer(loss_amount);
        }
    }
    
     
    function getRandomResult() private constant returns (uint) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty))%36);
    }
    
     
    function getWiningType(uint number) private constant returns (uint[]) {
        uint[] win_arr;

         
         
         
         
         
         
        
        for(uint i = 0; i < bet_lookup.length; i++) {
            for(uint j = 0; j < bet_lookup[i].length; j++) {
                if(number == j) {
                    win_arr.push(i);
                    break;
                }
            }
        }
        
        return win_arr;
    }
    
    function initPayoutTable() private {
         
        for(uint i = 1; i <= 36; i++) {
            payout_table[i] = 35;
        }
        
         
        payout_table[37] = 1;
         
        payout_table[38] = 1;
        
         
        payout_table[39] = 1;
         
        payout_table[40] = 1;

         
        payout_table[41] = 1;
         
        payout_table[42] = 1;
        
         
        payout_table[43] = 2;
         
        payout_table[44] = 2;
         
        payout_table[45] = 2;
        
         
        payout_table[46] = 2;
         
        payout_table[47] = 2;
         
        payout_table[48] = 2;
        
         
        for(uint j = 49; j <= 105; j++) {
            payout_table[j] = 17;
        }
        
         
        for(uint k = 106; k <= 129; k++) {
            payout_table[k] = 8;
        }
        
         
        for(uint l = 130; l <= 141; l++) {
            payout_table[l] = 11;
        }
        
         
        for(uint m = 142; m <= 147; m++) {
            payout_table[m] = 5;
        }
    }
    
    function initBetType() private {
        uint[] storage even_num;
        uint[] storage odd_num;
        uint[] storage one_to_oneEight;
        uint[] storage oneNine_to_threeSix;
        uint[] storage first_twelve;
        uint[] storage second_twelve;
        uint[] storage third_twelve;

         
        for(uint i = 0; i <= 36; i++) {
            bet_lookup.push([i]); 
            
            if(i % 2 != 0) {
                even_num.push(i);
            }else{
                odd_num.push(i);
            }
            
            if(i >= 1 && i <= 12) {
                first_twelve.push(i);
            }else if(i >= 13 && i <= 24){
                second_twelve.push(i);
            }else{
                third_twelve.push(i);
            }
        }

         
        for(uint j = 0; j <= 18; j++) {
            one_to_oneEight.push(j);
        }
        bet_lookup.push(one_to_oneEight);
        
         
        for(uint k = 0; k <= 18; k++) {
            oneNine_to_threeSix.push(k);
        }
        bet_lookup.push(oneNine_to_threeSix);
        
         
        bet_lookup.push(even_num);
        
         
        bet_lookup.push(odd_num);
        
         
        bet_lookup.push([1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36]);
        
         
        bet_lookup.push([2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35]);
        
         
        bet_lookup.push(first_twelve);
        
         
        bet_lookup.push(second_twelve);
        
         
        bet_lookup.push(third_twelve);
        
         
        bet_lookup.push([3,6,9,12,15,18,21,24,27,30,33,36]);
        
         
        bet_lookup.push([2,5,8,11,14,17,20,23,26,29,32,35]);
        
         
        bet_lookup.push([1,4,7,10,13,16,19,22,25,28,31,34]);
        
         
        for(uint l = 0; l < 12; i++) {
            if(l == 0) {
                bet_lookup.push([0, bet_lookup[46][l]]);
            }else{
                bet_lookup.push([bet_lookup[46][l - 1], bet_lookup[46][l]]);   
            }
        }
        
         
        for(uint m = 0; m < 12; m++) {
            if(m == 0) {
                bet_lookup.push([0, bet_lookup[47][m]]);
            }else {
                bet_lookup.push([bet_lookup[47][m - 1], bet_lookup[47][m]]);
            }
            
        }
        
         
        for(uint n = 0; n < 12; n++) {
            if(n == 0) {
                bet_lookup.push([0, bet_lookup[48][n]]);
            }else {
                bet_lookup.push([bet_lookup[48][n - 1], bet_lookup[48][n]]);
            }
        }
        
         
        bet_lookup.push([3,2]);
        bet_lookup.push([6,5]);
        bet_lookup.push([9,8]);
        bet_lookup.push([12,11]);
        bet_lookup.push([15,14]);
        bet_lookup.push([18,17]);
        bet_lookup.push([21,20]);
        bet_lookup.push([23,24]);
        bet_lookup.push([27,26]);
        bet_lookup.push([30,29]);
        bet_lookup.push([33,32]);
        bet_lookup.push([36,35]);
        
         
        bet_lookup.push([1,2]);
        bet_lookup.push([4,5]);
        bet_lookup.push([7,8]);
        bet_lookup.push([10,11]);
        bet_lookup.push([13,14]);
        bet_lookup.push([16,17]);
        bet_lookup.push([19,20]);
        bet_lookup.push([23,22]);
        bet_lookup.push([25,26]);
        bet_lookup.push([28,29]);
        bet_lookup.push([31,32]);
        bet_lookup.push([34,35]);
        
         
        bet_lookup.push([3,6,2,5]);
        bet_lookup.push([6,9,5,8]);
        bet_lookup.push([9,8,12,11]);
        bet_lookup.push([14,15,12,11]);
        bet_lookup.push([15,14,18,17]);
        bet_lookup.push([18,17,21,20]);
        bet_lookup.push([21,20,24,23]);
        bet_lookup.push([24,23,27,26]);
        bet_lookup.push([27,26,30,29]);
        bet_lookup.push([30,29,33,32]);
        bet_lookup.push([33,32,36,35]);
        
         
        bet_lookup.push([2,1,5,4]);
        bet_lookup.push([5,4,8,7]);
        bet_lookup.push([8,7,11,10]);
        bet_lookup.push([11,10,14,13]);
        bet_lookup.push([14,13,17,16]);
        bet_lookup.push([17,16,20,19]);
        bet_lookup.push([20,19,23,22]);
        bet_lookup.push([23,22,26,25]);
        bet_lookup.push([26,25,29,28]);
        bet_lookup.push([29,28,32,31]);
        bet_lookup.push([32,31,34,35]);
        
         
        bet_lookup.push([0,2,3]);
        
         
        bet_lookup.push([0,1,2]);
        
         
        for(uint o = 0; o <= 33; o+=3) {
            bet_lookup.push([o, o+1, o+2]); 
        }
        
         
        for(uint p = 0; p <= 33; p+=6) {
            bet_lookup.push([o, o+1, o+2, o+3, o+4, o+5]); 
        }
    }
}