pragma solidity ^0.5.1;
contract StudyPass{
    
    struct Student{
        bytes32 fname;
        bytes32 lname;
        bytes32 qual;
        uint year;
        bytes32 school;
    }
    
    struct School{
        bytes32 school_name;
        bytes32 school_loc;
        uint index;
    }
    
    struct Doc{
        uint stud_id;
        uint school_id;
        bytes32 doc;
        uint grade;
    }
    
    mapping(uint => Student) students;
    mapping(uint => School) schools;
    mapping(uint => Doc) docs;
    address owner;
    uint[] schoolArray;

     
     
     
 
     modifier isOwner(){ 
        require(owner == msg.sender);
        _;
    }
    
     
     
     
     
    
    function QuaLed() public payable{
        owner = msg.sender;
    }

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
    
     
     
     
     
     
     
     
     
     
     
     
    
     
     
     
     
    
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function setSchool(uint _address, string memory _school_name, string memory _school_loc) public returns (bool){
         
         
        schools[_address].school_name = stringToBytes32(_school_name);
        schools[_address].school_loc = stringToBytes32(_school_loc);
        schools[_address].index = schoolArray.push(_address) -1;
        return true;
         
    }
    
    function setDocs(uint _id, uint _school_id, uint _stud_id, string memory _doc, uint _grade) public returns (bool){
         
         
        docs[_id].school_id = _school_id;
        docs[_id].stud_id = _stud_id;
        docs[_id].doc = stringToBytes32(_doc);
        docs[_id].grade = _grade;
        return true;
         
    }
    
    function getDocs(uint _id) public view returns (uint, uint, bytes32, uint){
         
        return(docs[_id].school_id, docs[_id].stud_id, docs[_id].doc, docs[_id].grade);
    }
    
    
    function getSchool(uint _address) public view returns (bytes32, bytes32){
         
        return(schools[_address].school_name, schools[_address].school_loc);
    }
    
    function setStudent(uint _idno, string memory  _fname, string memory  _lname, string memory  _qual, uint _year) public returns (bool){
         
         
        students[_idno].fname = stringToBytes32(_fname);
        students[_idno].lname = stringToBytes32(_lname);
        students[_idno].qual = stringToBytes32(_qual);
        students[_idno].year = _year;
        students[_idno].school = schools[_idno].school_name;
        
         
        
        return true;
   }
   
    function viewStudent(uint _idnum) view public returns (uint  , bytes32 , bytes32, bytes32   , uint, bytes32){
        return (_idnum, students[_idnum].fname, students[_idnum].lname, students[_idnum].qual, students[_idnum].year, students[_idnum].school);
   }
   
   function updateStudent(uint _idnum, string memory   _fname, string memory   _lname, string memory   _qual, uint _year)  public returns (bool){
     
     
        students[_idnum].fname = stringToBytes32(_fname);
        students[_idnum].lname = stringToBytes32(_lname);
        students[_idnum].qual = stringToBytes32(_qual);
        students[_idnum].year = _year;
     
       return true;
   }
   
   
    
    
    
    
}