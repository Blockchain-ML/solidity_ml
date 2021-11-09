pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;


contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        
        require(newOwner != address(0));
        owner = newOwner;
    }
}



 
contract TBContract is owned {
    

    struct TBProjects {
        
        address owner;
        string projectName;
        
        string milestoneData;
        string projectData;
        
        string[] paymentData;
        string[] activityData;
    }
    
    address owner;
    
    TBProjects[] public tbProjects;

     
    
    function initProject(string _project_name, string _project_data, string _milestone_data)
    public onlyOwner returns(uint256) {

        tbProjects.length++;
        
        tbProjects[tbProjects.length - 1].owner = msg.sender;
        tbProjects[tbProjects.length - 1].projectName = _project_name;
        
        tbProjects[tbProjects.length - 1].projectData = _project_data;
        tbProjects[tbProjects.length - 1].milestoneData= _milestone_data;
        
        return(tbProjects.length);
        
    }


     
    function setPaymentDetails(uint256 _id, string _payment_data)
    public onlyOwner returns(uint256) {
        
        require(_id < tbProjects.length);

        tbProjects[_id].paymentData.length++;    
        tbProjects[_id].paymentData[tbProjects[_id].paymentData.length - 1] = _payment_data;
        
        return(tbProjects[_id].paymentData.length);
    
    }
    
     
    function setActivityDetails(uint256 _id, string _activity_data)
    public onlyOwner returns(uint256) {
        
        require(_id < tbProjects.length);
        
        tbProjects[_id].activityData.length++;
        tbProjects[_id].activityData[tbProjects[_id].activityData.length -1] = _activity_data;
        
        return(tbProjects[_id].activityData.length);

    }

     
    function getProjectById(uint256 _id) onlyOwner public returns(string, string, string[], string[]) {
        
        require(_id < tbProjects.length);
        
        return (
            tbProjects[_id].projectData,
            tbProjects[_id].milestoneData,
            tbProjects[_id].paymentData,
            tbProjects[_id].activityData);
    }
            
      
    function getMilestoneInformation(uint256 _id) onlyOwner public returns(string) {
    
        require(_id < tbProjects.length);
    
        return (tbProjects[_id].milestoneData);
    }
            
     
    function getProjectInformation(uint256 _id) onlyOwner public returns(string) {
       
        require(_id < tbProjects.length);
       
        return (tbProjects[_id].projectData);
    }
            
     
    function getAllPayment(uint256 _id) onlyOwner public returns(string[]) {
        
        require(_id < tbProjects.length);
        
        return (tbProjects[_id].paymentData);
    }
            
     
    function getAllActivity(uint256 _id) onlyOwner public returns(string[]) {
        
        require(_id < tbProjects.length);
        
        return (tbProjects[_id].activityData);
    }
            
     
    function getPaymentById(uint256 _id, uint256 _p_id) onlyOwner public returns(string) {
        
        require(_id < tbProjects.length);
        require(_p_id < tbProjects[_id].paymentData.length);
        
        return (tbProjects[_id].paymentData[_p_id]);
    }
            
      
    function getActivityById(uint256 _id, uint256 _a_id) onlyOwner public returns(string) {
        
        require(_id < tbProjects.length);
        require(_a_id < tbProjects[_id].activityData.length);
        
        return (tbProjects[_id].activityData[_a_id]);
    }
    
     
    function getProjectCount() onlyOwner public returns(uint256) {
        return(tbProjects.length + 1);
    }
    
     
    function getPaymentCount(uint256 _id) onlyOwner public returns(uint256) {
        
        require (_id < tbProjects.length);
        
        return(tbProjects[_id].paymentData.length + 1);
    }
    
     
    function getActivityCount(uint256 _id) onlyOwner public returns(uint256) {
        
        require (_id < tbProjects.length);
        
        return(tbProjects[_id].activityData.length + 1);
    }
}