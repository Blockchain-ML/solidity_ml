pragma solidity ^0.4.19;

 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  function Ownable() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

 
contract UserDetails is Ownable {
    string userEmail;

    struct education {
        string nameOfIntitution;
        uint16 yearOfPassing;
    }

    struct certification {
        string certificationUrl;
        string certificationName;
        string certificationProvider;
        uint16 yearOfCertification;
    }

    struct profileDetails {
        string bio;
    }
    enum educationQualification{SSc,HSc,college}
    educationQualification educationQualificationOf;

    mapping(string => mapping(uint => education)) education_of;
    mapping(string => mapping(uint => certification)) certificationOf;
    mapping(string => profileDetails) profileDetailsOf;

    event EducationUpdate(string indexed _userEmail, education );
    event CertificationUpdate(string indexed _userEmail, certification );
    event ProfileUpdate(string indexed _userEmail,profileDetails);
    event UserEmailUpdate(string indexed _userEmail);

     
    function setUserEmail(string _userEmail) public {
        userEmail = _userEmail;
        emit UserEmailUpdate(userEmail);
    }

     
    function updateEducation(
      uint _index,
      string _nameOfIntitution,
      uint16 _yearOfPassing
      ) public onlyOwner {
        education memory _education = education(_nameOfIntitution,_yearOfPassing);
        education_of[userEmail][_index]=_education;
        emit EducationUpdate(userEmail, _education);
      }

     
    function updateCertification(
      uint _index,
      string _certificationUrl,
      string _certificationName,
      string _certificationProvider,
      uint16 _yearOfCertification
      ) public onlyOwner {
        certification memory _certification = certification(
          _certificationUrl,
          _certificationName,
          _certificationProvider,
          _yearOfCertification
          );
        certificationOf[userEmail][_index] = _certification;
        emit CertificationUpdate(userEmail, _certification);
      }

     
    function updateProfileDetails(string _bio) public onlyOwner {
      profileDetails memory _profileDetails = profileDetails(_bio);
      emit ProfileUpdate(userEmail, _profileDetails);
    }

     
    function showCertificationDetails(uint _index) public view returns(
      string _certificationUrl,
      string _certificationName,
      string _certificationProvider,
      uint _yearOfCertification
      ) {
        _certificationUrl = certificationOf[userEmail][_index].certificationUrl;
        _certificationName = certificationOf[userEmail][_index].certificationName;
        _certificationProvider = certificationOf[userEmail][_index].certificationProvider;
        _yearOfCertification = certificationOf[userEmail][_index].yearOfCertification;
      }

     
    function showEducationDetails(uint _index) public view returns(
      string _nameOfIntitution,
      uint _yearOfPassing
      ) {
        _nameOfIntitution = education_of[userEmail][_index].nameOfIntitution;
        _yearOfPassing = education_of[userEmail][_index].yearOfPassing;
      }

     
    function showProfileDetails() public view returns(string _bio) {
        _bio = profileDetailsOf[userEmail].bio;
    }
}