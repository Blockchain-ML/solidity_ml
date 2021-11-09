 

pragma solidity >=0.4.0 <0.6.0;


contract Token {
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
}



contract LocalEthereum_1 {
    
    address public mediator;
    address public owner;
    
    
    uint32 public requestCancelMinimumTime;
    uint256 public feesAvailableForWithdraw;
    
     
    uint8 constant ACTION_SELLER_DISABLE_CANCEL = 0x01;  
    uint8 constant ACTION_BUYER_CANCEL = 0x02;
    uint8 constant ACTION_SELLER_CANCEL = 0x03;
    uint8 constant ACTION_SELLER_REQUEST_CANCEL = 0x04;
    uint8 constant ACTION_RELEASE = 0x05;
    uint8 constant ACTION_DISPUTE = 0x06;
    
    
     
    event Created(bytes32 _tradeHash);
    event SellerCancelDisabled(bytes32 _tradeHash);
    event SellerRequestedCancel(bytes32 _tradeHash);
    event CancelledBySeller(bytes32 _tradeHash);
    event CancelledByBuyer(bytes32 _tradeHash);
    event Released(bytes32 _tradeHash);
    event DisputeResolved(bytes32 _tradeHash);
    
    
    constructor () public {
        owner = msg.sender;
        mediator = msg.sender;
        requestCancelMinimumTime = 2 hours;
    }
    
    
    struct Escrow {
        bool escrowStatus;
        uint32 setTimeSellerCancel;
        uint128 totalGasSpentByConsumers;
        bool sellerDispute;
        bool buyerDispute;
    }
    
    mapping(bytes32 => Escrow) public escrow_map;
    
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyMediator() {
        require(msg.sender == mediator);
        _;
    }
    
    
     
    
     
     
    uint16 constant GAS_batchConsumerCost = 28500;
    
    function batchconsumerAction(uint16[] memory _tradeId, address payable[] memory _seller, address payable[] memory _buyer, uint256[] memory _amount, uint16[] memory _gasFee, uint128[] memory _additionalFee, uint8[] memory _actionByte) public returns(bool[] memory)
    {
        bool[] memory _results = new bool[](_tradeId.length);
        
        bool[] memory _consumer = new bool[](_tradeId.length);
        
        uint128 []  memory _additionalGas = new uint128[](_tradeId.length);
        
       for (uint8 i=0; i<_tradeId.length; i++) {
        
        _consumer[i] = (msg.sender == _seller[i] || msg.sender == _buyer[i]);
        
        _additionalGas[i] = uint128(_consumer[i] ==true ? GAS_batchConsumerCost / _tradeId.length : 0);
        
        _results[i] = consumerAction(_tradeId[i],_seller[i],_buyer[i],_amount[i],_gasFee[i],_additionalFee[i],_actionByte[i],_additionalGas[i]);
        
       }
       
       return _results;
    }
    
    
    
    
    
    
    
    
    
     
    
    
     
        
    
    function createEscrow(uint16 _tradeId, address _seller, address _buyer, uint256 _amount, uint16 _gasFee, uint32 _sellerCancelInSeconds, uint32 _expiryTime)  payable external returns(bool)
    {
        bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeId,_seller,_buyer,_amount,_gasFee));
        
        require (msg.sender == _seller,"Invalid User..");
        require(escrow_map[_tradeHash].escrowStatus==false, "Status Checking Failed.. ");
        require(now<_expiryTime, "Invalid Time..");
        require(_amount==msg.value && msg.value >0, "Invalid Amount..");
        
        uint32 _sellerCancelAfter = _sellerCancelInSeconds == 0 ? 1 : uint32(now) + _sellerCancelInSeconds;
        
        escrow_map[_tradeHash].escrowStatus = true;
        escrow_map[_tradeHash].setTimeSellerCancel = _sellerCancelAfter;
        escrow_map[_tradeHash].totalGasSpentByConsumers = 0;
        
        emit Created(_tradeHash);  
        
        return true;
        
    }
    
    
    
    
    function releseFunds(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee) external returns (bool)
    {
        
        return _releseFunds(_tradeId,_seller,_buyer,_amount,_gasFee,0);
        
    }
    
    
    function disableSellerCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee) external returns (bool) 
    {
    
      return _disableSellerCancel(_tradeId,_seller,_buyer,_amount,_gasFee,0);
      
    }
    
    function buyerCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee) external returns (bool) {
      
      return _buyerCancel(_tradeId,_seller,_buyer,_amount,_gasFee,0);
      
    }
    
    function sellerCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee) external returns (bool) {
     
      return _sellerCancel(_tradeId,_seller,_buyer,_amount,_gasFee,0);
      
    }
    
    function sellerRequestCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee) external returns (bool) 
    {
      
      return _sellerRequestCancel(_tradeId,_seller,_buyer,_amount,_gasFee,0);
      
    }

    
    
    
     
    
    
    function consumeSellerDisableCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) external returns (bool) 
    {
        
      return  consumerAction(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee,ACTION_SELLER_DISABLE_CANCEL, 0);
      
    }
    
    function consumeBuyerCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) external returns (bool) 
    {
      
      return  consumerAction(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee,ACTION_BUYER_CANCEL, 0);
    
    }
    
    function consumeRelease(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) external returns (bool) 
    {
        
      return  consumerAction(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee,ACTION_RELEASE, 0);
    
    }
    
    function consumeSellerCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) external returns (bool) 
    {
        
      return  consumerAction(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee,ACTION_SELLER_CANCEL, 0);
    
    }
    
    function consumeSellerRequestCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) external returns (bool) 
    {
        
      return  consumerAction(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee,ACTION_SELLER_REQUEST_CANCEL, 0);
      
    }
    
    function consumeDispute(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) external returns (bool) 
    {
      
      return  consumerAction(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee,ACTION_DISPUTE, 0);
      
    }
    
    
    
     
     
    
     uint16 constant GAS_dispute = 36100;
    
    function disputeByMediator(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _buyerPercent) external onlyMediator returns(bool)
    {
        
         bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeId,_seller,_buyer,_amount,_gasFee));
         
         require(escrow_map[_tradeHash].sellerDispute == true || escrow_map[_tradeHash].buyerDispute == true, " Seller or Buyer Doesn&#39;t Call Dispute");
         
         require(escrow_map[_tradeHash].escrowStatus == true, " Status Failed..");
         
         require(_buyerPercent <= 100, "Invalid Buyer Percentage");
         
         uint256 _totalFees = escrow_map[_tradeHash].totalGasSpentByConsumers + GAS_dispute;
         
         require(_amount - _totalFees <= _amount, "Amount Invalid .. ");
         
         feesAvailableForWithdraw += _totalFees; 
         
         delete escrow_map[_tradeHash];
         
         _buyer.transfer((_amount - _totalFees )*_buyerPercent/100);
         
         _seller.transfer((_amount - _totalFees)*(100 - _buyerPercent)/100);
         
         emit DisputeResolved(_tradeHash);  
         
         return true;
        
    }
    
    
     
    
   
    
    
    function withdrawFees(address payable _to, uint256 _amount) onlyOwner external
    {
        require(_amount <= feesAvailableForWithdraw);  
        feesAvailableForWithdraw -= _amount;
        _to.transfer(_amount);
    }

    
    
     
    
    function setMediator(address _newMediator) onlyOwner external 
    {
      
        mediator = _newMediator;
    }


     
    
    function setOwner(address _newOwner) onlyOwner external
    {
        
        owner = _newOwner;
    }
    
     
    
    function setRequestCancellationMinimumTime(uint32 _newRequestCancelMinimumTime) onlyOwner external 
    {
        
        requestCancelMinimumTime = _newRequestCancelMinimumTime;
        
    }
   
     
   
     
     
    
    function transferToken(Token _tokenContract, address _transferTo, uint256 _value) onlyOwner external 
    {
        
         _tokenContract.transfer(_transferTo, _value);
         
    }
    
    
     
     
    function transferTokenFrom(Token _tokenContract, address _transferTo, address _transferFrom, uint256 _value) onlyOwner external 
    {
       
         _tokenContract.transferFrom(_transferTo, _transferFrom, _value);
         
    }
    
    
     
     
    function approveToken(Token _tokenContract, address _spender, uint256 _value) onlyOwner external 
    {
        
         _tokenContract.approve(_spender, _value);
         
    }
    
    
    
    
    
    
    
     
    
     
    
    uint256 gas_releaseFunds = 36500;
    
    function _releseFunds(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) private returns(bool)
    {
        require(msg.sender == _seller, "Invalid User.. ");
        
        bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeId,_seller,_buyer,_amount,_gasFee));
         
        require(escrow_map[_tradeHash].escrowStatus == true, "Status Checking Failed.. ");
         
         
        uint256 _totalGas = escrow_map[_tradeHash].totalGasSpentByConsumers;
         
        uint256 _addGas = (msg.sender == _seller ? ( gas_releaseFunds + _additionalFee) * uint128(tx.gasprice) : 0);
         
        uint256 _gasEstimation = _totalGas + _addGas;
         
        delete escrow_map[_tradeHash];
         
        transferMinusFees(_buyer, _amount, _gasEstimation, _gasFee);
        
        emit Released(_tradeHash);
         
        return true;
         
    }  
    
   
    
    
    
     
    
    uint16 constant GAS_disableSellerCancel = 12100;
    
    function _disableSellerCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) private returns(bool)
    {
       bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeId,_seller,_buyer,_amount,_gasFee));
        
       require(escrow_map[_tradeHash].escrowStatus == true, "Status Checking Failed.. ");
       
       require(escrow_map[_tradeHash].setTimeSellerCancel !=0,  "Seller Cancel time is Differ.. ");
       
       require(msg.sender == _buyer, "Invalid User.. ");
       
       escrow_map[_tradeHash].setTimeSellerCancel = 0;
       
        
       increaseGasSpent(_tradeHash, GAS_disableSellerCancel + _additionalFee);
       
       emit SellerCancelDisabled(_tradeHash);  
       
       return true;
        
    }
    
    
    
    
     
    
     uint16 constant GAS_buyerCancel = 36100;
    
    function _buyerCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) private returns(bool)
    {
       bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeId,_seller,_buyer,_amount,_gasFee));
        
       require(escrow_map[_tradeHash].escrowStatus == true, "Status Checking Failed.. ");
       
       uint128 _gasFees = escrow_map[_tradeHash].totalGasSpentByConsumers + (msg.sender == _buyer ? (GAS_buyerCancel + _additionalFee) * uint128(tx.gasprice) : 0);
       
       delete escrow_map[_tradeHash];
       
       transferMinusFees(_seller, _amount, _gasFees, 0);
       
       emit CancelledByBuyer(_tradeHash);  
       
       return true;
    }
        
    
    
    
    
     
     
    
     uint16 constant GAS_sellerCancel = 36100;
     
    
    function _sellerCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) private returns(bool)
    {
       bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeId,_seller,_buyer,_amount,_gasFee));
        
       require(escrow_map[_tradeHash].escrowStatus == true, "Status Checking Failed.. ");
       
       if(escrow_map[_tradeHash].setTimeSellerCancel <= 1 || escrow_map[_tradeHash].setTimeSellerCancel > now) return false;
       
       uint128 _gasFees = escrow_map[_tradeHash].totalGasSpentByConsumers + (msg.sender == _seller ? (GAS_sellerCancel + _additionalFee) * uint128(tx.gasprice) : 0);
       
       delete escrow_map[_tradeHash];
       
       transferMinusFees(_seller, _amount, _gasFees, 0);
       
       emit CancelledBySeller(_tradeHash);  
       
       return true;
    }
    
    
    
    
     
     
     
    
    uint16 constant GAS_sellerRequestCancel = 12100;
    
    function _sellerRequestCancel(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) private returns(bool)
    {
       bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeId,_seller,_buyer,_amount,_gasFee));
       
       require(_seller==msg.sender, "Invalid User.. ");
         
       require(escrow_map[_tradeHash].escrowStatus == true, "Status Checking Failed.. ");
       
       require (escrow_map[_tradeHash].setTimeSellerCancel == 1,  "Seller Cancel time is Differ.. ");
       
       escrow_map[_tradeHash].setTimeSellerCancel = uint32(now) + requestCancelMinimumTime;
       
       increaseGasSpent(_tradeHash, GAS_sellerRequestCancel + _additionalFee);
       
       emit SellerRequestedCancel(_tradeHash);  
       
       return true;
        
    }
    
    
       
    
    function disputeCall(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee) private returns (bool)
    {
        bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeId,_seller,_buyer,_amount,_gasFee));
         
        require(msg.sender == _seller || msg.sender == _buyer, " Invalid User.. ");
         
        require(escrow_map[_tradeHash].escrowStatus == true, " Status Failed.. ");
         
        if(msg.sender == _seller)
        {
         escrow_map[_tradeHash].sellerDispute = true;
         
         return true;
        }
         
        else if(msg.sender == _buyer)
        {
         escrow_map[_tradeHash].buyerDispute = true;
             
         return true;
        }
         
         
    }
    
    
    
    
    
    
    
     
    
    function consumerAction(uint16 _tradeId, address payable _seller, address payable _buyer, uint256 _amount, uint16 _gasFee, uint128 _additionalFee, uint8 _actionByte,  uint128 _maxGas) private returns(bool)
    {
        require(msg.sender==_seller || msg.sender == _buyer);
        
        if(msg.sender == _buyer) {
            
            if(_actionByte == ACTION_SELLER_DISABLE_CANCEL)
            {
                return _disableSellerCancel(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee);
            }
            
            else if (_actionByte == ACTION_BUYER_CANCEL)
            {
                return _buyerCancel(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee);
            }
            
            else if(_actionByte == ACTION_DISPUTE )
            {
                return disputeCall(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee);
            }
            
            else 
            {
                return false;
            }
            
        }
        
        
        else if (msg.sender == _seller)
        {
            if(_actionByte == ACTION_RELEASE)
            {
                return _releseFunds(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee);
                
            }
            
            else if(_actionByte == ACTION_SELLER_REQUEST_CANCEL)
            {
                return _sellerRequestCancel(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee);
            }
            
            else if(_actionByte == ACTION_SELLER_CANCEL)
            {
                return _sellerCancel(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee);
            }
            
            else if(_actionByte == ACTION_DISPUTE )
            {
                return disputeCall(_tradeId,_seller,_buyer,_amount,_gasFee,_additionalFee);
            }
            
            else 
            {
                return false;
            }
            
            
        }
        
    }
    
    
    
    
    
    
     
    
    function increaseGasSpent(bytes32 _tradeHash, uint128 _gas) private 
    {
      escrow_map[_tradeHash].totalGasSpentByConsumers += _gas * uint128(tx.gasprice);
    }
    
    
    
     
    
     function transferMinusFees(address payable _to, uint256 _amount, uint256 _totalGasFeesSpentByConsumer, uint256 _gasFee) private returns(bool)
     {
        
      uint256 _totalFees = (_amount * _gasFee / 10000) + _totalGasFeesSpentByConsumer;
        
      if(_amount - _totalFees > _amount) return false;  
        
        feesAvailableForWithdraw += _totalFees;  
        
        _to.transfer(_amount - _totalFees);
        
        return true;        
    }
    
    
    
    
    
    
        
    }