 
 
 
 
 
 
 
 
 


pragma solidity ^0.4.0;

contract SomeContract {

  function SomeContract() public payable{

  }

  event TheOemAddedAnItem(address oemaddress,bytes32 itemname,uint quantityofitem);
  event TheManufacturerRequestedForParts(bytes32 nameofpart,uint numberofparts);
  event TheManufacturerRequestedForMoreParts(bytes32 nameofthepart,uint numberoftheparts);
  event TheOemGotPaid(address _oemsaddress,uint moneyinthepoolforoem);
  event TheManufacturerRefundedTheDefectiveItem(bytes32 defectiveitem,uint numberofdefective);
  event TheVehicleIsReadyToBeSendToTheDealer(uint thevehicleid);

  struct auto_industry {

    uint typ;
    address add;

  }

   
  mapping(address => auto_industry ) addautoindustry;

  function add_OEM() {

    addautoindustry[msg.sender]=auto_industry(1,msg.sender);

  }

  modifier only_OEM() {

    if (addautoindustry[msg.sender].typ==1){
      _;
    }

    else {
      throw;
    }

  }
   
  function add_AUTO_MANU() {

    addautoindustry[msg.sender]=auto_industry(2,msg.sender);

  }

  modifier only_AUTO_MANU() {

    if (addautoindustry[msg.sender].typ==2){
      _;
    }

    else {
      throw;
    }

  }

  mapping (bytes32 => uint) parts_mapping;
  mapping (bytes32 => uint) id_mapping;
  mapping (bytes32 => uint) time_mapping;
  mapping (bytes32 => bytes32) hashing_item;
  mapping (bytes32 => uint) price_mapping;

   
  function addparts(bytes32 name, uint quantity, uint ids,uint price) only_OEM {

    uint p=parts_mapping[name];
    parts_mapping[name]=p+quantity;
    uint time_now=now;
    id_mapping[name] = ids;
    time_mapping[name]=time_now;
    price_mapping[name]=price;
    hashing_item[name]=sha3(name,ids,time_now);
    TheOemAddedAnItem(msg.sender,name,quantity);

  }

   
  function display(bytes32 part_name) constant returns(uint) {

    return parts_mapping[part_name];

  }

   
  function display_time(bytes32 part_name) constant returns(uint) {

    return time_mapping[part_name];

  }

   
  modifier auth_part(bytes32 name, uint id_item) {

    uint  time_created=time_mapping[name];
    bytes32 hash_temp=sha3(name,id_item,time_created);
    bytes32 orig_hash=hashing_item[name];
    if(hash_temp==orig_hash) {
      _;
    }
    else {
      throw;
    }

  }

  uint pooltime;

   
  function buy_part_amount_show (bytes32 name_of_part , uint how_many) constant returns(uint) {

    uint amount = how_many * price_mapping[name_of_part];
    return amount;

  }

   
  function use_OEM_Parts(bytes32 name_of_part, uint how_many, uint id_of_item) auth_part(name_of_part , id_of_item) payable {

    if( parts_mapping[name_of_part] < how_many ){
      TheManufacturerRequestedForMoreParts(name_of_part,how_many);
    }

    parts_mapping[name_of_part] = parts_mapping[name_of_part] - how_many;
    uint amount = msg.value;
    this.transfer(amount);
    pooltime=now;

    TheManufacturerRequestedForParts(name_of_part,how_many);


  }

   
  function getPoolMoney() constant returns (uint){

    return this.balance;

  }

   
  function defective(bytes32 _name_of_part, uint no_of_pieces) only_AUTO_MANU {

    uint __amount = no_of_pieces * price_mapping[_name_of_part];
    msg.sender.transfer(__amount);
    TheManufacturerRefundedTheDefectiveItem(_name_of_part,no_of_pieces);

  }

   
  function pay_to_OEM() payable only_OEM() {

    if(now-pooltime > 36000){
      TheOemGotPaid(msg.sender, this.balance);
      msg.sender.transfer(this.balance);
    }

  }
 mapping (uint => vehicle) partinauto;
 struct vehicle
 {
   uint vehicle_id;
   string vehicle_name;
 }
 mapping (uint => uint) completeness;
 
 function part_to_vehicle(uint partid,string vehicle_n,uint _vehicle_id) only_AUTO_MANU
 {
   if(completeness[_vehicle_id]==1)
   {
     throw;
   }
   else
   {
   partinauto[partid]=vehicle(_vehicle_id,vehicle_n);
   }
 }
 
 function check_part_location(uint partid) constant returns(uint a,string b)
 {
   a=partinauto[partid].vehicle_id;
   b=partinauto[partid].vehicle_name;
 }
 
 function vehicle_assembled(uint vehicle_id_)
 {
   completeness[vehicle_id_]=1;
   TheVehicleIsReadyToBeSendToTheDealer(vehicle_id_);
 }
  function () payable{

  }

}