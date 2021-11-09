pragma solidity 0.6.6;

interface IRealityCards {

    function collectRentAllTokens() external;
    function numberOfTokens() external view returns(uint); 
    function ownerOf(uint) external view returns(address); 
    function currentOwnerRemainingDeposit(uint) external view returns(uint);

}

contract rentCollector {
    IRealityCards rc1 = IRealityCards(0x148Bb64E8910422E74f79feF1A2E830BDe0BB938);  
    IRealityCards rc2 = IRealityCards(0xf30a16DdFDfbA014789E577bC59c6e2E89cEE0f5);  
    
    function hasCardExpired() external view returns (bool) {
        bool _expired = false;
        
         
        for (uint i = 0; i < rc1.numberOfTokens(); i++) {
            if (rc1.currentOwnerRemainingDeposit(i) == 0 && rc1.ownerOf(i) != address(rc1)) {
                _expired = true;
            }
        }
        
         
        for (uint i = 0; i < rc2.numberOfTokens(); i++) {
            if (rc2.currentOwnerRemainingDeposit(i) == 0 && rc2.ownerOf(i) != address(rc2)) {
                _expired = true;
            }
        }
        
    return _expired;
        
    }
    
    function collectRentAllTokensAllMarkets() public 
    {
        bool _expired;
        
         
        _expired = false;
        for (uint i = 0; i < rc1.numberOfTokens(); i++) {
            if (rc1.currentOwnerRemainingDeposit(i) == 0 && rc1.ownerOf(i) != address(rc1)) {
                _expired = true;
            }
        if (_expired) {
            rc1.collectRentAllTokens(); 
            }
        }
        
         
        _expired = false;
        for (uint i = 0; i < rc2.numberOfTokens(); i++) {
            if (rc2.currentOwnerRemainingDeposit(i) == 0 && rc2.ownerOf(i) != address(rc2)) {
                _expired = true;
            }
        if (_expired) {
            rc2.collectRentAllTokens(); 
            }
        }
        
    }
}