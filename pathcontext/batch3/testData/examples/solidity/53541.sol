pragma solidity ^0.4.23;

contract Cestificate{
     
    struct student{
        address addr;                            
        string email;                            
        uint phone;                              
        string name;                             
        uint courseId;                           
        bool check;                              
         
    }
    
     
    struct course{
        string name;                             
        uint id;                                 
        uint dbegin;                             
        uint dend;                               
        string decription;                       
        string lecture;                          
         
    }
    
     
    mapping(address => mapping(uint => bool)) student2course;
    
     
    course[] public courses;
    
     
    student[] public studentRequest;
    
     
    function addCourse(string _name, uint _id, uint _begin, uint _dend, string _description, string _lecture) public{
        courses.push(course(_name, _id, _begin, _dend, _description, _lecture));       
    }
    
     
    function getCourseLength() public view returns(uint){
        return courses.length;
    }
    
     
    function applyForCertifition(address _addr, string _email, uint _phone, string _name, uint _courseId, bool _check) public{
        studentRequest.push(student(_addr, _email, _phone, _name, _courseId, _check));
    }
    
     
    function getStudentRequest() public view returns(uint){
        return studentRequest.length;
    }
    
     
    function approCertificate(uint _requestId) public{
        student storage request = studentRequest[_requestId];
        request.check = true;
        student2course[request.addr][request.courseId] = true;
    }
    
     
    function rejectCertificate(uint _requestId) public {
        student storage request = studentRequest[_requestId];
        request.check = true;
    }
    
     
    function clearAllRequests() public {
         
         
        studentRequest.length = 0;
    }
    
     
    function verifyCestificate(address _addr, uint _courseId) public view returns(string) {
        string memory courseName;
        if (student2course[_addr][_courseId]){
            courseName = courses[_courseId].name;
        }
        return courseName;
    }

}