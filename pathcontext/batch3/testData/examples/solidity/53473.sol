pragma solidity >0.4.99 <0.6.0;

contract Test {
     
     
     
     
     
    function() external { x = 1; }
    uint x;
}


 
 
contract Sink {
    function() external payable { }
}

contract Caller {
    function callTest(Test test) public returns (bool) {
        (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
         

         
         
         
        address payable testPayable = address(uint160(address(test)));

         
         
        return testPayable.send(2 ether);
    }
}