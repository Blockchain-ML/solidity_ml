pragma solidity ^0.4.24;

 
contract Parking2 {

    uint constant public preisProSekunde = 0.0000085 ether;  

    uint constant public preisProMinute = preisProSekunde * 60;

     
    uint constant public vorausszahlung = preisProMinute * 24;

     
    uint constant public vermittlungsgebuehr = 10;

    address public kunde;
    address public vermittler = 0xF5910828f21F41F81A603309DAC5C010f5f941bE;
    address public vermieter = 0xF1d20E5100d9756B59126f3b6CF6a621457d4d90;
    uint public checkInZeit;
    uint public checkOutZeit;
    uint public parkZeit;

    uint public restGeld;
    uint public parkGebuehr;
    uint public vermittlerProfit;
    uint public vermieterProfit;

     
     

     
     
    function() public payable {
        if (kunde == address(0)) {
            checkIn();
        } else {
            checkOut();
        }
    }

    function checkIn() private {
        require(msg.value >= vorausszahlung);
        require(checkInZeit == 0);
        kunde = msg.sender;
        checkInZeit = currentTime();
    }

    function checkOut() private {
        require(msg.sender == kunde);
        berechneBuchhaltung();
        starteAbrechnung();
        checkInZeit = 0;
        kunde = address(0);
    }

    function berechneBuchhaltung() public {
        require(checkInZeit > 0);
        checkOutZeit = currentTime();
        parkZeit = checkOutZeit - checkInZeit;
        parkGebuehr = parkZeit * preisProSekunde;
         
        if (parkGebuehr >= address(this).balance) {
            parkGebuehr = address(this).balance;
            restGeld = 0;
        } else {
            restGeld = address(this).balance - parkGebuehr;
        }
        vermittlerProfit = parkGebuehr / 100 * vermittlungsgebuehr;
        vermieterProfit = parkGebuehr - vermittlerProfit;
    }

    function starteAbrechnung() private {
        if (restGeld > 0) {
            kunde.transfer(restGeld);
        }
        if (vermittlerProfit > 0) {
            vermittler.transfer(vermittlerProfit);
        }
        if (vermieterProfit > 0) {
            vermieter.transfer(vermieterProfit);
        }
        require(address(this).balance == 0);
    }

    function currentTime() private view returns (uint _currentTime) {
        return now;
    }

}