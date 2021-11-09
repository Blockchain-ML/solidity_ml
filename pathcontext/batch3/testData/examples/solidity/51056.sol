pragma solidity^0.4.25;
contract CertificateShare {
      
	    event Log(string  eventMessage);
	    
	      struct Certificate {
	         string id;
	         string certId;
	         address organisation;
	         address requester;
	         string action;
	         string createdDate;
	     }
	     
	       
	     mapping(string => Certificate) certificate;
	     
	   
	      
	     mapping(address => Certificate[]) orgSharedCerts;
	     
	       
	     Certificate[] certificates;
	     
	       
	    string creatorName;
	    address creatorAddress;
	     
	      
	    constructor (string _creator) public {
	      creatorName = _creator;
	      creatorAddress = msg.sender;
	      emit Log("Contract deployed successfully");
	    }
	    
	    function shareCertificate(string _sharedId,string _certId, string _date,  address _org,
	          address _requester, string _action) public payable returns(bool) {
	       Certificate storage cert = certificate[_sharedId];   
	       cert.id = _sharedId;
	       cert.certId=_certId;
	       cert.createdDate = _date;
	       cert.organisation = _org;
	       cert.requester = _requester;
	       cert.action = _action;
	        
	       certificates.push(cert);
	        
	       certificate[_sharedId] = cert;
	        
	       orgSharedCerts[_org].push(cert);
	       return true;
	   }
	    
    
}