pragma solidity ^0.4.24;

contract certificate_UITDZ13{
    
    struct StudentRequest{
        address addressStudent;
        string email;
        string phone;
        string nameStudent;
        uint courseid;
        bool isDone;
    }
    
    struct Course{
        string name;
        uint id;
        uint dayStart;
        uint dayEnd;
        string lecturer;
    }
    
     
    mapping(address=>mapping(uint=>bool)) student2course;
    
     
    Course[] public courses;
    
     
    StudentRequest[] public student_requests;
  
     
    address public educater = msg.sender;
    
     
    modifier hasPermission(){
        require(
            msg.sender ==educater, 
            "Just educater have permission"
        );
        _; 
    }
    
    
     
    function addCourse(string _name, uint _id, uint _dayStart, uint _dayEnd, string _lecturer)hasPermission public{
        courses.push(Course(_name,_id,_dayStart,_dayEnd, _lecturer));
    }
    
     
    function numCourse() public view returns(uint){
        return courses.length;
    } 
    
     
    function applyForCertification(string _email, string _phone, string nameStudent, uint _courseid, bool _isDone  ) public{ 
         
        student_requests.push(StudentRequest(msg.sender, _email ,_phone, nameStudent, _courseid, _isDone));
    }
    
     
    function numStudentRequest()public view returns(uint){
        return student_requests.length;
    }
    
     
    function approveCertificate(uint _requestID)hasPermission public{
        StudentRequest storage request = student_requests[_requestID]; 
        request.isDone = true; 
        student2course[request.addressStudent][request.courseid]=true; 
    }
    
     
    function rejectCertificate(uint _requestID)hasPermission public{
        StudentRequest storage request = student_requests[_requestID];
        request.isDone = false; 
    }
    
     
    function clearAllrequest()hasPermission public{
         
        bool allCompleted =true;
        for(uint i = 0; i < student_requests.length;i++){ 
            allCompleted = allCompleted && student_requests[i].isDone;
             
            if(!allCompleted){
                return;
            }
        }
         
         
        student_requests.length=0; 
    }
    
     
    function verifyCertification(address _studentAddress, uint _courseid) view public returns(string){
        string memory courseName;
        if(student2course[_studentAddress][_courseid]){ 
            courseName =courses[_courseid].name;
             
        }
        return courseName; 
        
    }
}