pragma solidity ^0.4.24;

contract PeerWalletsEngine{
    
     
    address whiteListContractAddress;
    
     

    function launchPeerWallet(address[] _peers, address[] _exchangeGroups, uint[] _distribution)
        public
        payable
        returns(address) {
        if(_peers.length > 1 && _exchangeGroups.length == _distribution.length){
        WhiteList whiteListSCObj = WhiteList(whiteListContractAddress);
            if(whiteListSCObj.validateInvestmentGroups(_exchangeGroups) == true){
                PeerWallets peerWalletsSCObj = new PeerWallets();
                return address(peerWalletsSCObj.createPeerWallet.value(msg.value)(msg.sender, _peers, _exchangeGroups, _distribution));
            }
        }
        return address(0);
    }

     
    function setWhiteListContractAddress(address _whiteListContractAddress) 
        public {
        whiteListContractAddress = _whiteListContractAddress;
    }
}

contract PeerWallets{
    
     
    address[] private peers;
    
     
    address[] private investedPeersAddress;
    
     
    address private leader;
    
     
    address[] private exchangeGroupKeys;
    
     
    address private whiteListContractAddress;
    
     
    uint[] private distribution;
    
     
    uint private totalInvested;
    
     
    bool private investmentLaunched;
    
     
     
     
    mapping (address => uint) private ownership;
    
     
     
     
    mapping (address => uint8) private isInvestedPeer;
    
     
     
     
    mapping (address => uint) private peerAmount;
    
     
     
     
     
    mapping (address => mapping (address => uint)) private peerTokens;
    
     
     
     
    mapping (address => uint) private walletTokens;
    
     
    function createPeerWallet(address _leader, address[] _peers, address[] _exchangeGroupKeys, uint[] _distribution)
        public
        payable
        returns(address) {
        leader = _leader;
        totalInvested = msg.value;
        peerAmount[leader] = totalInvested;
        if(totalInvested > 0){
            investedPeersAddress.push(leader);
            isInvestedPeer[leader] = 1;
        }
        peers = _peers;
        distribution = _distribution;
        exchangeGroupKeys = _exchangeGroupKeys;
        investmentLaunched = false;
        return this;
    }
    
     
    function makeInvestment()
        public
        payable {
        if(validatePeer(msg.sender) == true){
            if(isInvestedPeer[msg.sender] == 0){
                investedPeersAddress.push(msg.sender);
                isInvestedPeer[msg.sender] = 1;
            }
            totalInvested += msg.value;
            peerAmount[msg.sender] += msg.value;
            if(investmentLaunched == true){
                if(investedPeersAddress.length == peers.length){
                    completeInvestment();
                }
            }
            else{
                completeInvestment();
            }
        }
    }
    
     
    function completeInvestment() 
        private {
        calculateOwnership();
        calculateWalletTokens();
        calculatePeerTokens();
        resetPeerWallet();
    }
    
     
    function launchInvestment()
        public 
        payable {
        if(leader == msg.sender){
            if(isInvestedPeer[msg.sender] == 0){
                investedPeersAddress.push(msg.sender);
                isInvestedPeer[msg.sender] = 1;
            }
            investmentLaunched = true;
            peerAmount[msg.sender] += msg.value;
            totalInvested += peerAmount[msg.sender];
        }
    }
    
     
    function triggerInvestment()
        public {
        if(leader == msg.sender && totalInvested > 0)
            completeInvestment();
    }
    
     
    function addPeer(address _peer)
        public {
        if(leader == msg.sender)
            peers.push(_peer);
    }

     
    function removePeer(address _peer)
        public {
        if(leader == msg.sender){
            if(peers[peers.length - 1] == _peer){
                delete peers[peers.length - 1];
                peers.length--;
                return;
            }
            else {
                for(uint i = 0; i < peers.length; ++i)
                    if(peers[i] == _peer){
                        peers[i] = peers[peers.length - 1];
                        delete peers[peers.length - 1];
                        peers.length--;
                        return;
                    }
            }
        }
    }
    
     
    function validatePeer(address _peer)
        public
        view
        returns(bool) {
        for(uint i = 0; i < peers.length; ++i)
            if(peers[i] == _peer)
                return true;
        return false;
    }
    
     
    function calculateWalletTokens()
        private {
        WhiteList WhiteListSCObject = WhiteList(whiteListContractAddress);
        for(uint i=0; i< exchangeGroupKeys.length; ++i)
            walletTokens[exchangeGroupKeys[i]] = ((distribution[i] * totalInvested) / 100) * WhiteListSCObject.getRespectiveValue(exchangeGroupKeys[i]);
    }
    
     
    function calculateOwnership()
        private {
        for(uint i = 0; i < investedPeersAddress.length; ++i)
            ownership[investedPeersAddress[i]] = (peerAmount[investedPeersAddress[i]] * 100) / totalInvested;
    }
    
     
    function calculatePeerTokens()
        private {
        for(uint j = 0; j < investedPeersAddress.length; ++j)
            for(uint i = 0; i < exchangeGroupKeys.length; ++i)
                peerTokens[investedPeersAddress[j]][exchangeGroupKeys[i]] = walletTokens[exchangeGroupKeys[i]] * ownership[investedPeersAddress[j]];
    }
    
     
    function getPeerOwnership(address _peer)
        public
        view
        returns(uint) {
        if(validatePeer(_peer) == true)
            return ownership[_peer];
        return 0;
    }
    
     
    function getPeerTokens(address _peer)
        public
        view 
        returns(uint) {
        if(validatePeer(_peer) == true)
            for(uint i = 0; i < exchangeGroupKeys.length; ++i)
                return peerTokens[_peer][exchangeGroupKeys[i]];
        return 0;
    }
    
     
    function resetPeerWallet() 
        private {
        for(;investedPeersAddress.length > 0;){
            peerAmount[investedPeersAddress[0]] = 0;
            isInvestedPeer[investedPeersAddress[0]] = 0;
            
            investedPeersAddress[0] = investedPeersAddress[investedPeersAddress.length - 1];
            delete investedPeersAddress[investedPeersAddress.length - 1];
            --investedPeersAddress.length;
        }
        totalInvested = 0;
    }
    
     
    function setWhiteListContractAddress(address _whiteListContractAddress)
        public {
        whiteListContractAddress = _whiteListContractAddress;
    }
}

contract WhiteList{
    
     
     
     
    mapping (address => uint) exchangeGroupValue;
    
     
    function validateInvestmentGroups(address[] _exchangeGroupKeys) 
        public 
        view
        returns(bool) {
        for(uint i=0; i<_exchangeGroupKeys.length; ++i){
            if(exchangeGroupValue[_exchangeGroupKeys[i]] == 0){
                return false;
            }
        }
        return true;
    }
    
     
    function setExchangeGroup(address _exchangeGroupAddress, uint _exchangeGroupValue) 
        public {
        require(_exchangeGroupValue != 0);
        exchangeGroupValue[_exchangeGroupAddress] = _exchangeGroupValue;
    }
    
     
    function getRespectiveValue(address _exchangeGroupKey) 
        public
        view
        returns(uint) {
        return exchangeGroupValue[_exchangeGroupKey];
    }
}