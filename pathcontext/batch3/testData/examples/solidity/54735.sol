pragma solidity ^0.4.24;

contract Trace {

  struct Object {
    uint256 id;
    string name;
    bool inTransit;
    address recipient;
    uint256[] ownershipIDs;
  }

  struct Ownership {
    uint256 id;
    address owner;
    uint256 receptionTime;
  }

  uint256 public nbObjects;
  mapping (uint256 => Object) public objects;

  uint256 public nbOwnerships;
  mapping (uint256 => Ownership) public ownerships;

  constructor() public {
    nbOwnerships = 0;
    nbObjects = 0;
  }

  function createObject(string _name) public {
    nbOwnerships += 1;
    uint256 _ownershipID = nbOwnerships;
    ownerships[_ownershipID] = Ownership({
      id: _ownershipID,
      owner: msg.sender,
      receptionTime: now
    });

    nbObjects += 1;
    uint256 _objectID = nbObjects;
    address _recipient;

    uint256[] memory _ownershipIDs;

    objects[_objectID] = Object({
      id: _objectID,
      name: _name,
      inTransit: false,
      recipient: _recipient,
      ownershipIDs: _ownershipIDs
    });

    Object storage o = objects[_objectID];
    o.ownershipIDs.push(_ownershipID);
  }

  modifier ownsObject(uint256 _objectID, address _sender) {
    Object storage o = objects[_objectID];
    require( getCurrentOwner(_objectID) == _sender ); _;
  }

  modifier canReceiveObject(uint256 _objectID, address _sender) {
    Object storage o = objects[_objectID];
    require( (o.inTransit) && (o.recipient == _sender) ); _;
  }

  function sendObjectWithApproval(uint256 _objectID, address _recipient) public
    ownsObject(_objectID, msg.sender)
  {
    Object storage o = objects[_objectID];
    o.inTransit = true;
    o.recipient = _recipient;
  }

  function approveObjectReception(uint256 _objectID) public
    canReceiveObject(_objectID, msg.sender)
  {
    receiveObject(_objectID, msg.sender);
  }

  function sendObjectWithoutApproval(uint256 _objectID, address _recipient) public
    ownsObject(_objectID, msg.sender)
  {
    receiveObject(_objectID, _recipient);
  }

  function receiveObject(uint256 _objectID, address _recipient) private
  {
    Object storage o = objects[_objectID];
    o.inTransit = false;
    o.recipient = address(0);

    nbOwnerships += 1;
    uint256 _ownershipID = nbOwnerships;
    ownerships[_ownershipID] = Ownership({
      id: _ownershipID,
      owner: _recipient,
      receptionTime: now
    });
    o.ownershipIDs.push(_ownershipID);
  }

  function getCurrentOwner(uint256 _objectID) public view returns(address) {
    Object storage o = objects[_objectID];
    uint256 ownershipID = o.ownershipIDs[getTotalNbOwners(_objectID)-1];
    return ownerships[ownershipID].owner;
  }

  function getTotalNbOwners(uint256 _objectID) public view returns(uint256) {
    Object storage o = objects[_objectID];
    return o.ownershipIDs.length;
  }

   

}