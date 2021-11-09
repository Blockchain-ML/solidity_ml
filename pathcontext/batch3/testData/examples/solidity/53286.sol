pragma solidity ^0.4.23;

contract LotteryFactory {

	 
	uint public commissionSum;
	 
	Params public defaultParams;
	 
	Lottery[] public lotteries;
	 
	uint public lotteryCount;
	 
	address public owner;

	struct Lottery {
		mapping(address => uint[]) ownerToken;
		mapping(uint => address) tokenOwner;
		mapping(address => uint) ownerTokenCountToSell; 
		mapping(uint => bool) tokenSell;
		uint createdAt;
		uint tokenCount;
		uint tokenCountToSell;
		uint winnerSum;
		bool prizeRedeemed;
		address winner;
		address[] participants;
		uint[] tokensToSellOnce;
		Params params;
	}

	 
	struct Params {
		uint gameDuration;
		uint initialTokenPrice; 
		uint durationToTokenPriceUp; 
		uint tokenPriceIncreasePercent; 
		uint tradeCommission; 
		uint winnerCommission;
	}

	 
	event PurchaseError(address oldOwner, uint amount);

	 
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	 
	constructor() public {
		 
		owner = msg.sender;
		 
		updateParams(6 hours, 0.01 ether, 15 minutes, 10, 15, 20);
		 
		_createNewLottery();
	}

	 
	function approveToSell(uint _tokenCount) public {
		Lottery storage lottery = lotteries[lotteryCount - 1];
		 
		require(lottery.ownerToken[msg.sender].length - lottery.ownerTokenCountToSell[msg.sender] >= _tokenCount);
		 
		for(uint i = 0; i < _tokenCount; i++) {
			uint tokenId = lottery.ownerToken[msg.sender][i];
			 
			if(!lottery.tokenSell[tokenId]) {
				lottery.tokenSell[tokenId] = true;
				lottery.tokensToSellOnce.push(tokenId);
			}
		}
		lottery.ownerTokenCountToSell[msg.sender] += _tokenCount;
		lottery.tokenCountToSell += _tokenCount;
	}

	 
	function balanceOf(address _user) public view returns(uint) {
		Lottery storage lottery = lotteries[lotteryCount - 1];
		return lottery.ownerToken[_user].length;
	}

	 
	function balanceSellingOf(address _user) public view returns(uint) {
		Lottery storage lottery = lotteries[lotteryCount - 1];
		return lottery.ownerTokenCountToSell[_user];
	}

	 
	function buyTokens() public payable {
		if(_isNeededNewLottery()) _createNewLottery();
		 
		Lottery storage lottery = lotteries[lotteryCount - 1];
		 
		uint price = _getCurrentTokenPrice();
		uint tokenCountToBuy = msg.value / price;
		 
		require(tokenCountToBuy > 0);
		 
		uint tokenCountToBuyFromSeller = _getTokenCountToBuyFromSeller(tokenCountToBuy);
		if(tokenCountToBuyFromSeller > 0) {
			_buyTokensFromSeller(tokenCountToBuyFromSeller);
		}
		 
		uint tokenCountToBuyFromSystem = tokenCountToBuy - tokenCountToBuyFromSeller;
		if(tokenCountToBuyFromSystem > 0) {
			_buyTokensFromSystem(tokenCountToBuyFromSystem);
		}
		 
		_addToParticipants(msg.sender);
		 
		lottery.winnerSum += msg.value;
		lottery.winner = _getWinner();
	}

	 
	function disapproveToSell(uint _tokenCount) public {
		Lottery storage lottery = lotteries[lotteryCount - 1];
		 
		require(lottery.ownerTokenCountToSell[msg.sender] >= _tokenCount);
		 
		uint disapprovedCount = 0;
		for(uint i = 0; i < lottery.ownerToken[msg.sender].length; i++) {
			uint tokenId = lottery.ownerToken[msg.sender][i];
			 
			if(lottery.tokenSell[tokenId]) {
				lottery.tokenSell[tokenId] = false;
				disapprovedCount++;
			}
			 
			if(disapprovedCount == _tokenCount) break;
		}
		lottery.ownerTokenCountToSell[msg.sender] -= _tokenCount;
		lottery.tokenCountToSell -= _tokenCount;
	}

	 
	function getLotteryAtIndex(uint _index) public view returns(
		uint createdAt,
		uint tokenCount,
		uint tokenCountToSell,
		uint winnerSum,
		address winner,
		bool prizeRedeemed,
		address[] participants,
		uint paramGameDuration,
		uint paramInitialTokenPrice,
		uint paramDurationToTokenPriceUp,
		uint paramTokenPriceIncreasePercent,
		uint paramTradeCommission,
		uint paramWinnerCommission
	) {
		 
		require(_index < lotteryCount);
		 
		Lottery memory lottery = lotteries[_index];
		createdAt = lottery.createdAt;
		tokenCount = lottery.tokenCount;
		tokenCountToSell = lottery.tokenCountToSell;
		winnerSum = lottery.winnerSum;
		winner = lottery.winner;
		prizeRedeemed = lottery.prizeRedeemed;
		participants = lottery.participants;
		paramGameDuration = lottery.params.gameDuration;
		paramInitialTokenPrice = lottery.params.initialTokenPrice;
		paramDurationToTokenPriceUp = lottery.params.durationToTokenPriceUp;
		paramTokenPriceIncreasePercent = lottery.params.tokenPriceIncreasePercent;
		paramTradeCommission = lottery.params.tradeCommission;
		paramWinnerCommission = lottery.params.winnerCommission;
	}

	 
	function isTokenSelling(uint _tokenId) public view returns(bool) {
		Lottery storage lottery = lotteries[lotteryCount - 1];
		return lottery.tokenSell[_tokenId];
	}

	 
	function ownerOf(uint _tokenId) public view returns(address) {
		Lottery storage lottery = lotteries[lotteryCount - 1];
		return lottery.tokenOwner[_tokenId];
	}

	 
	function tokensOf(address _user) public view returns(uint[]) {
		Lottery storage lottery = lotteries[lotteryCount - 1];
		return lottery.ownerToken[_user];
	}

	 
	function tokensToSellOnce() public view returns(uint[]) {
		Lottery memory lottery = lotteries[lotteryCount - 1];
		return lottery.tokensToSellOnce;
	}

	 
	function updateParams(
		uint _gameDuration,
		uint _initialTokenPrice,
		uint _durationToTokenPriceUp,
		uint _tokenPriceIncreasePercent,
		uint _tradeCommission,
		uint _winnerCommission
	) public onlyOwner {
		Params memory params;
		params.gameDuration = _gameDuration;
		params.initialTokenPrice = _initialTokenPrice;
		params.durationToTokenPriceUp = _durationToTokenPriceUp;
		params.tokenPriceIncreasePercent = _tokenPriceIncreasePercent;
		params.tradeCommission = _tradeCommission;
		params.winnerCommission = _winnerCommission;
		defaultParams = params;
	}

	 
	function withdraw() public onlyOwner {
		owner.transfer(commissionSum);
	}

	 
	function withdrawForWinner(uint _lotteryIndex) public {
		 
		require(lotteries.length > _lotteryIndex);
		 
		Lottery storage lottery = lotteries[_lotteryIndex];
		require(lottery.winner == msg.sender);
		 
		require(now > lottery.createdAt + lottery.params.gameDuration);
		 
		require(!lottery.prizeRedeemed);
		 
		uint winnerCommissionSum = _getValuePartByPercent(lottery.winnerSum, lottery.params.winnerCommission);
		commissionSum += winnerCommissionSum;
		uint winnerSum = lottery.winnerSum - winnerCommissionSum;
		 
		lottery.prizeRedeemed = true;
		 
		lottery.winner.transfer(winnerSum);
	}

	 
	function() public payable {
		revert();
	}

	 
	function _addToParticipants(address _user) internal {
		 
		Lottery storage lottery = lotteries[lotteryCount - 1];
		bool isParticipant = false;
		for(uint i = 0; i < lottery.participants.length; i++) {
			if(lottery.participants[i] == _user) {
				isParticipant = true;
				break;
			}
		}
		if(!isParticipant) {
			lottery.participants.push(_user);
		}
	}

	 
	function _buyTokensFromSeller(uint _tokenCountToBuy) internal {
		 
		require(_tokenCountToBuy > 0);
		 
		Lottery storage lottery = lotteries[lotteryCount - 1];
		 
		uint currentTokenPrice = _getCurrentTokenPrice();
		uint currentCommissionSum = _getValuePartByPercent(currentTokenPrice, lottery.params.tradeCommission);
		uint purchaseSum = currentTokenPrice - currentCommissionSum;
		 
		for(uint i = 0; i < lottery.tokensToSellOnce.length; i++) {
			uint tokenId = lottery.tokensToSellOnce[i];
			 
			if(lottery.tokenSell[tokenId]) {
				 
				address oldOwner = lottery.tokenOwner[tokenId];
				 
				_transferFrom(oldOwner, msg.sender, tokenId);
				 
				commissionSum += currentCommissionSum;
				if(!oldOwner.send(purchaseSum)) {
					emit PurchaseError(oldOwner, purchaseSum);
				}
			}
		}
	}

	 
	function _buyTokensFromSystem(uint _tokenCountToBuy) internal {
		 
		require(_tokenCountToBuy > 0);
		 
		Lottery storage lottery = lotteries[lotteryCount - 1];
		 
		for(uint tokenIndex = lottery.tokenCount; tokenIndex < lottery.tokenCount + _tokenCountToBuy; tokenIndex++) {
			lottery.ownerToken[msg.sender].push(tokenIndex);
			lottery.tokenOwner[tokenIndex] = msg.sender;
		}
		 
		lottery.tokenCount += _tokenCountToBuy;
	}

	 
	function _createNewLottery() internal {
		Lottery memory lottery;
		lottery.createdAt = _getNewLotteryCreatedAt();
		lottery.params = defaultParams;
		lotteryCount = lotteries.push(lottery);
	}

	 
	function _getCurrentTokenPrice() internal view returns(uint) {
		Lottery memory lottery = lotteries[lotteryCount - 1];
		uint diffInSec = now - lottery.createdAt;
		uint stageCount = diffInSec / lottery.params.durationToTokenPriceUp;
		uint price = lottery.params.initialTokenPrice;
		uint addPerStage = _getValuePartByPercent(price, lottery.params.tokenPriceIncreasePercent);
		for(uint i = 0; i < stageCount; i++) {
			price += addPerStage;
		}
		return price;
	}

	 
	function _getNewLotteryCreatedAt() internal view returns(uint) {
		 
		if(lotteries.length == 0) return now;
		 
		 
		uint latestEndAt = lotteries[lotteryCount - 1].createdAt + lotteries[lotteryCount - 1].params.gameDuration;
		 
		uint nextEndAt = latestEndAt + defaultParams.gameDuration;
		while(now > nextEndAt) {
			nextEndAt += defaultParams.gameDuration;
		}
		return nextEndAt - defaultParams.gameDuration;
	} 

	 
	function _getTokenCountToBuyFromSeller(uint _tokenCountToBuy) internal view returns(uint) {
		 
		require(_tokenCountToBuy > 0);
		 
		Lottery memory lottery = lotteries[lotteryCount - 1];
		 
		if(lottery.tokenCountToSell == 0) return 0;
		 
		if(lottery.tokenCountToSell < _tokenCountToBuy) {
			return lottery.tokenCountToSell;
		} else {
			 
			return _tokenCountToBuy;
		}
	}

	 
	function _getValuePartByPercent(uint _initialValue, uint _percent) internal pure returns(uint) {
		uint onePercentValue = _initialValue / 100;
		return onePercentValue * _percent;
	}

	 
	function _getWinner() internal view returns(address) {
		Lottery storage lottery = lotteries[lotteryCount - 1];
		 
		if(lottery.participants.length == 0) return address(0);
		 
		address winner = lottery.participants[0];
		uint maxTokenCount = lottery.ownerToken[winner].length;
		 
		for(uint i = 0; i < lottery.participants.length; i++) {
			uint currentTokenCount = lottery.ownerToken[lottery.participants[i]].length;
			if(currentTokenCount > maxTokenCount) {
				winner = lottery.participants[i];
				maxTokenCount = currentTokenCount; 
			}
		}
		return winner;
	}

	 
	function _isNeededNewLottery() internal view returns(bool) {
		 
		if(lotteries.length == 0) return true;
		 
		Lottery memory lottery = lotteries[lotteries.length - 1];
		return now > lottery.createdAt + defaultParams.gameDuration;
	}

	 
	function _transferFrom(address _oldOwner, address _newOwner, uint _tokenId) internal {
		 
		Lottery storage lottery = lotteries[lotteryCount - 1];
		 
		uint[] storage ownerTokens = lottery.ownerToken[_oldOwner];
		bool indexFound = false;
		for(uint j = 0; j < ownerTokens.length; j++) {
			if(ownerTokens[j] == _tokenId) {
				uint indexToRemove = j;
				indexFound = true;
				break;
			}
		}
		assert(indexFound);
		ownerTokens[indexToRemove] = ownerTokens[ownerTokens.length - 1];
		ownerTokens.length--;
		 
		lottery.ownerTokenCountToSell[lottery.tokenOwner[_tokenId]]--;
		 
		lottery.tokenOwner[_tokenId] = _newOwner;
		 
		lottery.ownerToken[_newOwner].push(_tokenId);
		 
		lottery.tokenSell[_tokenId] = false;
		 
		lottery.tokenCountToSell--;
	}

}