pragma solidity 0.4.24;

 
contract DisclosureAgreementTracker {

     
    struct Agreement {
         
        bytes32 previous;
         
        uint disclosureIndex;
         
        uint signedCount;
         
        address[] signatories;
         
        mapping(address => bool) requiredSignatures;
    }

     
    struct Latest {
        bytes32 agreementHash;
        uint agreementCount;
    }

     
    address public owner;

     
    address public disclosureManager;

     
    mapping(bytes32 => Agreement) public agreementMap;

     
    mapping(uint => Latest) public latestMap;

     
    event agreementAdded(
        bytes32 agreementHash,
        uint disclosureIndex,
        address[] signatories);

     
    event agreementSigned(
        bytes32 agreementHash,
        uint disclosureIndex,
        address signatory);

     
    event agreementFullySigned(
        bytes32 agreementHash,
        uint disclosureIndex);

    constructor(address disclosureManagerAddress) public {
        owner = msg.sender;
        disclosureManager = disclosureManagerAddress;
    }

     
    modifier isOwner() {
        if (msg.sender != owner) revert("sender must be owner");
        _;
    }

    function _agreementExists(Agreement agreement) private pure returns(bool) {
        return agreement.disclosureIndex != 0;
    }

     
    function agreementExists(bytes32 agreementHash) public view returns(bool) {
        return _agreementExists(agreementMap[agreementHash]);
    }

     
    function hasAgreement(uint disclosureIndex) public view returns(bool) {
        return latestMap[disclosureIndex].agreementCount != 0;
    }
    
    function _isAgreementSigned(Agreement agreement)
    private pure returns(bool) {
        return agreement.signedCount == agreement.signatories.length;
    }

     
    function isAgreementSigned(bytes32 agreementHash)
    public view returns(bool) {
        Agreement storage agreement = agreementMap[agreementHash];
        return _agreementExists(agreement) && _isAgreementSigned(agreement);
    }
    
     
    function isDisclosureSigned(uint disclosureIndex)
    public view returns(bool) {
        return isAgreementSigned(
            latestMap[disclosureIndex].agreementHash
        );
    }

     
    function addAgreement(
        bytes32 agreementHash,
        uint disclosureIndex,
        address[] signatories
    ) public isOwner {
        require(disclosureIndex > 0, "disclosureIndex must be greater than 0");
        require(agreementHash != 0, "agreementHash must not be 0");
        require(signatories.length > 0, "signatories must not be empty");

        Agreement storage agreement = agreementMap[agreementHash];
        agreement.disclosureIndex = disclosureIndex;
        agreement.signatories = signatories;

        Latest storage latest = latestMap[disclosureIndex];
        agreement.previous = latest.agreementHash;
        latest.agreementHash = agreementHash;
        latest.agreementCount++;

        for (uint i = 0; i < signatories.length; i++) {
            address signatory = signatories[i];
            if (agreement.requiredSignatures[signatory]) {
                revert("signatories must not contain duplicates");
            }
            agreement.requiredSignatures[signatory] = true;
        }

        emit agreementAdded(agreementHash, disclosureIndex, signatories);
    }

     
    function signAgreement(bytes32 agreementHash) public returns(bool signed) {
        require(agreementExists(agreementHash), "agreeement must exist");
        Agreement storage agreement = agreementMap[agreementHash];
        signed = agreement.requiredSignatures[msg.sender];
        if (signed) {
            agreement.requiredSignatures[msg.sender] = false;
            agreement.signedCount++;
            
            emit agreementSigned(
                agreementHash,
                agreement.disclosureIndex,
                msg.sender);
                
            if (_isAgreementSigned(agreement)) {
                emit agreementFullySigned(
                    agreementHash,
                    agreement.disclosureIndex);
            }
        }
    }

     
    function () public payable {
        revert("payment not supported");
    }

}