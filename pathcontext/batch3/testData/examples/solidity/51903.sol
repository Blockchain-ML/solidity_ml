 

  

pragma solidity ^0.4.24;


 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() public {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


 
contract Destructible is Ownable {

  function Destructible() public payable { }

   
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}

contract DragonKingConfig {


   
  uint128[] public costs;
   
  uint128[] public values;
   
  uint8 fee;
   
  uint16 public maxCharacters;
   
  uint256 public eruptionThreshold;
   
  uint256 public castleLootDistributionThreshold;
   
  uint8 public percentageToKill;
   
  uint256 public constant CooldownThreshold = 1 days;
   
  uint8 public fightFactor;

   
  uint256 public teleportPrice;
   
  uint256 public protectionPrice;

}

interface Token {
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
  function transfer(address _to, uint256 _value) external returns (bool success);
  function balanceOf(address who) external view returns (uint256);
}


contract DragonKing is Destructible {

  struct Character {
    uint8 characterType;
    uint128 value;
    address owner;
    uint64 purchaseTimestamp;
  }

  DragonKingConfig  config = DragonKingConfig(0x75D2eD78cd85C5fADe02069c21fe98A09510d102);

   
  Token  neverdieToken = Token(0xEe7ACd6b0FB65eeBC11cF733fdC606619CF633D4);
   
  Token  teleportToken = Token(0x8A01Bc6A9358388588247127fF7BE21B281B36d4);

   
  Token  sklToken = Token(0xD22d680d1fa045A07E8d335C1Bb815EbFC4D4e5E);
   
  Token  xperToken = Token(0x822afedd7d48ed1056247747c8ed6df7f02b50fc);
  

   
  uint32[]  ids;
   
  uint32  nextId = 1;
   
  uint16  constant INVALID_CHARACTER_INDEX = ~uint16(0);

   
  uint128 public castleTreasury;
   
  uint32 public oldest;
   
  mapping(uint32 => Character) characters;
   
  mapping(uint32 => bool) teleported;

   
  uint32 constant  noKing = ~uint32(0);

   
  uint16 public numCharacters;
   
  mapping(uint8 => uint16) numCharactersXType;

   
  uint256 public lastEruptionTimestamp;
   
  uint256 public lastCastleLootDistributionTimestamp;

   
  uint8  constant DRAGON_MIN_TYPE = 0;
  uint8  constant DRAGON_MAX_TYPE = 5;

  uint8  constant KNIGHT_MIN_TYPE = 6;
  uint8  constant KNIGHT_MAX_TYPE = 11;

  uint8  constant BALLOON_MIN_TYPE = 12;
  uint8  constant BALLOON_MAX_TYPE = 14;

  uint8  constant WIZARD_MIN_TYPE = 15;
  uint8  constant WIZARD_MAX_TYPE = 20;

  uint8  constant ARCHER_MIN_TYPE = 21;
  uint8  constant ARCHER_MAX_TYPE = 26;

  uint8  constant NUMBER_OF_LEVELS = 6;

  uint8  constant INVALID_CHARACTER_TYPE = 27;

   
  uint8  MIN_XPER_AMOUNT_TO_PURCHASE_WIZARD = 100;
  uint8  MIN_SKL_AMOUNT_TO_PURCHASE_WIZARD = 50;

   
  uint8  MIN_XPER_AMOUNT_TO_PURCHASE_ARCHER = 10;
  uint8  MIN_SKL_AMOUNT_TO_PURCHASE_ARCHER = 5;

     
  mapping(uint32 => uint)  cooldown;

     
  mapping(uint32 => uint8)  protection;

   

   
  event NewPurchase(address player, uint8 characterType, uint16 amount, uint32 startId);
   
  event NewExit(address player, uint256 totalBalance, uint32[] removedCharacters);
   
  event NewEruption(uint32[] hitCharacters, uint128 value, uint128 gasCost);
   
  event NewSell(uint32 characterId, address player, uint256 value);
   
  event NewFight(uint32 winnerID, uint32 loserID, uint256 value, uint16 probability, uint16 dice);
   
  event NewTeleport(uint32 characterId);
   
  event NewProtection(uint32 characterId, uint8 lifes);
   
  event NewDistributionCastleLoot(uint128 castleLoot);


   
  function addCharacters(uint8 characterType) payable public {
    uint16 amount = uint16(msg.value / config.costs(characterType));
    uint16 nchars = numCharacters;
    if (characterType >= INVALID_CHARACTER_TYPE || msg.value < config.costs(characterType) || nchars + amount > config.maxCharacters()) revert();
    uint32 nid = nextId;
     
    if (characterType <= DRAGON_MAX_TYPE) {
       
      if (oldest == 0 || oldest == noKing)
        oldest = nid;
      for (uint8 i = 0; i < amount; i++) {
        addCharacter(nid + i, nchars + i);
        characters[nid + i] = Character(characterType, config.values(characterType), msg.sender, uint64(now));
      }
      numCharactersXType[characterType] += amount;
      numCharacters += amount;
    }
    else {
      uint256 amountSKL = sklToken.balanceOf(msg.sender);
      uint256 amountXPER = xperToken.balanceOf(msg.sender);
      if (characterType >= WIZARD_MIN_TYPE && characterType <= WIZARD_MAX_TYPE) {
        require( amountSKL >= MIN_SKL_AMOUNT_TO_PURCHASE_WIZARD && amountXPER >= MIN_XPER_AMOUNT_TO_PURCHASE_WIZARD, 
                "insufficient amount of SKL and XPER tokens"
               );
      }
      if (characterType >= ARCHER_MIN_TYPE && characterType <= ARCHER_MAX_TYPE) {
        require( amountSKL >= MIN_SKL_AMOUNT_TO_PURCHASE_ARCHER && amountXPER >= MIN_XPER_AMOUNT_TO_PURCHASE_ARCHER, 
                "insufficient amount of SKL and XPER tokens" 
               );
      }
       
      for (uint8 j = 0; j < amount; j++) {
        characters[nid + j] = Character(characterType, config.values(characterType), msg.sender, uint64(now));
      }
    }
    nextId = nid + amount;
    emit NewPurchase(msg.sender, characterType, amount, nid);
  }


   
  function addCharacter(uint32 nId, uint16 nchars) internal {
    if (nchars < ids.length)
      ids[nchars] = nId;
    else
      ids.push(nId);
  }

   
  function replaceCharacter(uint16 index, uint16 nchars) internal {
    uint32 characterId = ids[index];
    numCharactersXType[characters[characterId].characterType]--;
    if (characterId == oldest) oldest = 0;
    delete characters[characterId];
    ids[index] = ids[nchars];
    delete ids[nchars];
  }

   
  function triggerVolcanoEruption() public {
    require(now >= lastEruptionTimestamp + config.eruptionThreshold(),
           "not enough time passed since last eruption");
    require(numCharacters > 0,
           "there are no characters in the game");
    lastEruptionTimestamp = now;
    uint128 pot;
    uint128 value;
    uint16 random;
    uint32 nextHitId;
    uint16 nchars = numCharacters;
    uint32 howmany = nchars * config.percentageToKill() / 100;
    uint128 neededGas = 80000 + 10000 * uint32(nchars);
    if(howmany == 0) howmany = 1; 
    uint32[] memory hitCharacters = new uint32[](howmany);
    bool[] memory alreadyHit = new bool[](nextId);
    uint8 i = 0;
    uint16 j = 0;
    while (i < howmany) {
      j++;
      random = uint16(generateRandomNumber(lastEruptionTimestamp + j) % nchars);
      nextHitId = ids[random];
      if (!alreadyHit[nextHitId]) {
        alreadyHit[nextHitId] = true;
        hitCharacters[i] = nextHitId;
        value = hitCharacter(random, nchars, 0);
        if (value > 0) {
          nchars--;
        }
        pot += value;
        i++;
      }
    }
    uint128 gasCost = uint128(neededGas * tx.gasprice);
    numCharacters = nchars;
    if (pot > gasCost){
      distribute(pot - gasCost);  
      emit NewEruption(hitCharacters, pot - gasCost, gasCost);
    }
    else
      emit NewEruption(hitCharacters, 0, gasCost);
  }

   
  function fight(uint32 characterID, uint16 characterIndex) public {
    if (characterID != ids[characterIndex])
      characterIndex = getCharacterIndex(characterID);
    Character storage character = characters[characterID];
    require(cooldown[characterID] + config.CooldownThreshold() <= now,
            "not enough time passed since the last fight of this character");
    require(character.owner == msg.sender,
            "only owner can initiate a fight for this character");

    uint8 ctype = character.characterType;
    require(ctype < BALLOON_MIN_TYPE || ctype > BALLOON_MAX_TYPE,
            "balloons cannot fight");

    uint16 adversaryIndex = getRandomAdversary(characterID, ctype);
    assert(adversaryIndex != INVALID_CHARACTER_INDEX);
    uint32 adversaryID = ids[adversaryIndex];

    Character storage adversary = characters[adversaryID];
    uint128 value;
    uint16 base_probability;
    uint16 dice = uint16(generateRandomNumber(characterID) % 100);
    uint256 characterPower = sklToken.balanceOf(character.owner) / 10**15 + xperToken.balanceOf(character.owner);
    uint256 adversaryPower = sklToken.balanceOf(adversary.owner) / 10**15 + xperToken.balanceOf(adversary.owner);
    
    if (character.value == adversary.value) {
        base_probability = 50;
      if (characterPower > adversaryPower) {
        base_probability += uint16(100 / config.fightFactor());
      } else if (adversaryPower > characterPower) {
        base_probability -= uint16(100 / config.fightFactor());
      }
    } else if (character.value > adversary.value) {
      base_probability = 100;
      if (adversaryPower > characterPower) {
        base_probability -= uint16((100 * adversary.value) / character.value / config.fightFactor());
      }
    } else if (characterPower > adversaryPower) {
        base_probability += uint16((100 * character.value) / adversary.value / config.fightFactor());
    }

    if (dice >= base_probability) {
       
      if (adversary.characterType < BALLOON_MIN_TYPE || adversary.characterType > BALLOON_MAX_TYPE) {
        value = hitCharacter(characterIndex, numCharacters, adversary.characterType);
        if (value > 0) {
          numCharacters--;
        }
        if (adversary.characterType >= ARCHER_MIN_TYPE && adversary.characterType <= ARCHER_MAX_TYPE) {
          castleTreasury += value;
        } else {
          adversary.value += value;
        }
        emit NewFight(adversaryID, characterID, value, base_probability, dice);
      } else {
        emit NewFight(adversaryID, characterID, 0, base_probability, dice);  
      }
    } else {
       
      value = hitCharacter(adversaryIndex, numCharacters, character.characterType);
      if (value > 0) {
        numCharacters--;
      }
      if (character.characterType >= ARCHER_MIN_TYPE && character.characterType <= ARCHER_MAX_TYPE) {
        castleTreasury += value;
      } else {
        character.value += value;
      }
      if (oldest == 0) findOldest();
      emit NewFight(characterID, adversaryID, value, base_probability, dice);
    }
    cooldown[characterID] = now;
  }

   
  function isValidAdversary(uint8 characterType, uint8 adversaryType) pure returns (bool) {
    if (characterType >= KNIGHT_MIN_TYPE && characterType <= KNIGHT_MAX_TYPE) {  
      return (adversaryType <= DRAGON_MAX_TYPE);
    } else if (characterType >= WIZARD_MIN_TYPE && characterType <= WIZARD_MAX_TYPE) {  
      return (adversaryType < BALLOON_MIN_TYPE || adversaryType > BALLOON_MAX_TYPE);
    } else if (characterType >= DRAGON_MIN_TYPE && characterType <= DRAGON_MAX_TYPE) {  
      return (adversaryType >= WIZARD_MIN_TYPE);
    } else if (characterType >= ARCHER_MIN_TYPE && characterType <= ARCHER_MAX_TYPE) {  
      return ((adversaryType >= BALLOON_MIN_TYPE && adversaryType <= BALLOON_MAX_TYPE)
             || (adversaryType >= KNIGHT_MIN_TYPE && adversaryType <= KNIGHT_MAX_TYPE));
 
    }
    return false;
  }

   
  function getRandomAdversary(uint256 nonce, uint8 characterType) internal view returns(uint16) {
    uint16 randomIndex = uint16(generateRandomNumber(nonce) % numCharacters);
     
    uint16 stepSize = numCharacters % 7 == 0 ? (numCharacters % 11 == 0 ? 13 : 11) : 7;
    uint16 i = randomIndex;
     
     
    do {
      if (isValidAdversary(characterType, characters[ids[i]].characterType) && characters[ids[i]].owner != msg.sender) {
        return i;
      }
      i = (i + stepSize) % numCharacters;
    } while (i != randomIndex);

    return INVALID_CHARACTER_INDEX;
  }


   
  function generateRandomNumber(uint256 nonce) internal view returns(uint) {
    return uint(keccak256(block.blockhash(block.number - 1), now, numCharacters, nonce));
  }

	 
  function hitCharacter(uint16 index, uint16 nchars, uint8 characterType) internal returns(uint128 characterValue) {
    uint32 id = ids[index];
    uint8 knockOffProtections = 1;
    if (characterType >= WIZARD_MIN_TYPE && characterType <= WIZARD_MAX_TYPE) {
      knockOffProtections = 2;
    }
    if (protection[id] >= knockOffProtections) {
      protection[id] -= knockOffProtections;
      return 0;
    }
    characterValue = characters[ids[index]].value;
    nchars--;
    replaceCharacter(index, nchars);
  }

   
  function findOldest() public {
    uint32 newOldest = noKing;
    for (uint16 i = 0; i < numCharacters; i++) {
      if (ids[i] < newOldest && characters[ids[i]].characterType <= DRAGON_MAX_TYPE)
        newOldest = ids[i];
    }
    oldest = newOldest;
  }

   
  function distribute(uint128 totalAmount) internal {
    uint128 amount;
    if (oldest == 0)
      findOldest();
    if (oldest != noKing) {
       
      characters[oldest].value += totalAmount / 10;
      amount  = totalAmount / 10 * 9;
    } else {
      amount  = totalAmount;
    }
     
    uint128 valueSum;
    uint8 size = ARCHER_MAX_TYPE;
    uint128[] memory shares = new uint128[](size);
    for (uint8 v = 0; v < size; v++) {
      if ((v < BALLOON_MIN_TYPE || v > BALLOON_MAX_TYPE) && numCharactersXType[v] > 0) {
           valueSum += config.values(v);
      }
    }
    for (uint8 m = 0; m < size; m++) {
      if ((v < BALLOON_MIN_TYPE || v > BALLOON_MAX_TYPE) && numCharactersXType[m] > 0) {
        shares[m] = amount * config.values(m) / valueSum / numCharactersXType[m];
      }
    }
    uint8 cType;
    for (uint16 i = 0; i < numCharacters; i++) {
      cType = characters[ids[i]].characterType;
      if (cType < BALLOON_MIN_TYPE || cType > BALLOON_MAX_TYPE)
        characters[ids[i]].value += shares[characters[ids[i]].characterType];
    }
  }


   
  

   
  function distributeCastleLoot() external {
    require(now >= lastCastleLootDistributionTimestamp + config.castleLootDistributionThreshold(),
            "not enough time passed since the last castle loot distribution");
    lastCastleLootDistributionTimestamp = now;
    uint128 luckFactor = uint128(generateRandomNumber(now) % 51);
    if (luckFactor < 5) {
      luckFactor = 5;
    }
    uint128 amount = castleTreasury * luckFactor / 100; 
    uint128 valueSum;
    uint128[] memory shares = new uint128[](NUMBER_OF_LEVELS);
    uint16 archersCount;
    uint32[] memory archers = new uint32[](numCharacters);

    uint8 cType;
    for (uint8 i = 0; i < ids.length; i++) {
      cType = characters[ids[i]].characterType; 
      if ((cType >= ARCHER_MIN_TYPE && cType <= ARCHER_MAX_TYPE) && (((uint64(now) - characters[ids[i]].purchaseTimestamp) / config.eruptionThreshold()) >= 7)) {
        valueSum += config.values(cType);
        archers[archersCount] = ids[i];
        archersCount++;
      }
    }

    if (valueSum > 0) {
      for (uint8 j = 0; j < NUMBER_OF_LEVELS; j++) {
          shares[j] = amount * config.values(ARCHER_MIN_TYPE + j) / valueSum;
      }

      for (uint16 k = 0; k < archersCount; k++) {
        characters[archers[k]].value += shares[characters[archers[k]].characterType - ARCHER_MIN_TYPE];
      }
      castleTreasury -= amount;
      emit NewDistributionCastleLoot(amount);
    } else {
      emit NewDistributionCastleLoot(0);
    }
  }

   
  function sellCharacter(uint32 characterId) public {
    require(msg.sender == characters[characterId].owner,
            "only owners can sell their characters");
    require(characters[characterId].characterType < BALLOON_MIN_TYPE || characters[characterId].characterType > BALLOON_MAX_TYPE,
            "balloons are not sellable");
    require(characters[characterId].purchaseTimestamp + 1 days < now,
            "character can be sold only 1 day after the purchase");
    uint128 val = characters[characterId].value;
    numCharacters--;
    replaceCharacter(getCharacterIndex(characterId), numCharacters);
    msg.sender.transfer(val);
    if (oldest == 0)
      findOldest();
    emit NewSell(characterId, msg.sender, val);
  }

   
  function receiveApproval(address sender, uint256 value, address tokenContract, bytes callData) public {
    uint32 id;
    uint256 price;
    if (msg.sender == address(teleportToken)) {
      id = toUint32(callData);
      price = config.teleportPrice();
      if (characters[id].characterType >= BALLOON_MIN_TYPE && characters[id].characterType <= WIZARD_MAX_TYPE) {
        price *= 2;
      }
      require(value >= price,
              "insufficinet amount of tokens to teleport this character");
      assert(teleportToken.transferFrom(sender, this, price));
      teleportCharacter(id);
    } else if (msg.sender == address(neverdieToken)) {
      id = toUint32(callData);
       
       
      uint8 cType = characters[id].characterType;
      require(characters[id].value == config.values(cType),
              "protection could be bought only before the first fight and before the first volcano eruption");

       
       

      uint256 lifePrice;
      uint8 max;
      if(cType <= KNIGHT_MAX_TYPE || (cType >= ARCHER_MIN_TYPE && cType <= ARCHER_MAX_TYPE)){
        lifePrice = ((cType % NUMBER_OF_LEVELS) + 1) * config.protectionPrice();
        max = 3;
      } else if (cType >= BALLOON_MIN_TYPE && cType <= BALLOON_MAX_TYPE) {
        lifePrice = (((cType+3) % NUMBER_OF_LEVELS) + 1) * config.protectionPrice() * 2;
        max = 6;
      } else if (cType >= WIZARD_MIN_TYPE && cType <= WIZARD_MAX_TYPE) {
        lifePrice = (((cType+3) % NUMBER_OF_LEVELS) + 1) * config.protectionPrice() * 2;
        max = 3;
      }

      price = 0;
      uint8 i = protection[id];
      for (i; i < max && value >= price + lifePrice * (i + 1); i++) {
        price += lifePrice * (i + 1);
      }
      assert(neverdieToken.transferFrom(sender, this, price));
      protectCharacter(id, i);
    } else {
      revert("Should be either from Neverdie or Teleport tokens");
    }
  }

   
  function teleportCharacter(uint32 id) internal {
     
    require(teleported[id] == false,
           "already teleported");
    teleported[id] = true;
    Character storage character = characters[id];
    require(character.characterType > DRAGON_MAX_TYPE,
           "dragons do not need to be teleported");  
    addCharacter(id, numCharacters);
    numCharacters++;
    numCharactersXType[character.characterType]++;
    emit NewTeleport(id);
  }

   
  function protectCharacter(uint32 id, uint8 lifes) internal {
    protection[id] = lifes;
    emit NewProtection(id, lifes);
  }


   

   
  function getCharacter(uint32 characterId) public view returns(uint8, uint128, address) {
    return (characters[characterId].characterType, characters[characterId].value, characters[characterId].owner);
  }

   
  function getCharacterIndex(uint32 characterId) public returns(uint16) {
    for (uint16 i = 0; i < ids.length; i++) {
      if (ids[i] == characterId) {
        return i;
      }
    }
    revert();
  }

   
  function get10Characters(uint16 startIndex) public returns(uint32[10] characterIds, uint8[10] types, uint128[10] values, address[10] owners) {
    uint32 endIndex = startIndex + 10 > numCharacters ? numCharacters : startIndex + 10;
    uint8 j = 0;
    uint32 id;
    for (uint16 i = startIndex; i < endIndex; i++) {
      id = ids[i];
      characterIds[j] = id;
      types[j] = characters[id].characterType;
      values[j] = characters[id].value;
      owners[j] = characters[id].owner;
      j++;
    }

  }

   

   
  function toUint32(bytes b) internal pure returns(uint32) {
    bytes32 newB;
    assembly {
      newB: = mload(0xa0)
    }
    return uint32(newB);
  }
}