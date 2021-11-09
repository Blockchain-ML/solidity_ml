pragma solidity ^0.4.25;

 
contract GorgonaKiller {

    address public GorgonaAddr;  
    uint constant public MIN_DEP = 0.01 ether;  
    uint public devidends;  
    uint public deposits;  
    uint public fromGorgona = 0;  

    constructor() public {
         
         
         
        GorgonaAddr = 0x4BcAc2879757ee44260C3A60D4C0d9cfA8c73634;
    }

     
    address[] addresses;

    mapping(address => Member) public members;

     
    struct Member
    {
        uint id;
        uint deposit;
    }

     
    function () external payable {

         
        if (msg.sender == GorgonaAddr) {
            fromGorgona = msg.value;
            return;
        }

         
        if (fromGorgona > 0) {
             
            devidends += fromGorgona;
             
            fromGorgona = 0;
        }

         
        if (devidends > MIN_DEP) {
            payDividends();
        }

         
        if (msg.value == 0) {
            return;
        }

         
        Member storage investor = members[msg.sender];

         
        if (investor.id == 0) {
            investor.id = addresses.push(msg.sender);
        }

         
        investor.deposit += msg.value;

         
        deposits += msg.value;

         
        if ( address(this).balance - devidends >= MIN_DEP ) {
            payToGorgona();
        }

    }

     
    function payToGorgona() private {
        GorgonaAddr.transfer( address(this).balance - devidends );
    }

     
    function payDividends() private {
        address[] memory _addresses = addresses;

        uint _devidends = devidends;

        for (uint i = 0; i < _addresses.length; i++) {
             
             
            uint amount = _devidends * members[ _addresses[i] ].deposit / deposits;
             
            if (_addresses[i].send( amount )) {
                devidends -= amount;  
            }
        }
    }

     
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

     
    function getInvestorCount() public view returns(uint) {
        return addresses.length;
    }

}