
enum CommissioningSerialPoolStatus {
  
  checking,

  
  preReserved,

  
  alreadyCommissioned,

  
  notPreAllocated,

  
  notTransitionable,

  
  unknown,
}

extension CommissioningSerialPoolStatusX on CommissioningSerialPoolStatus {
  bool get blocksCommissioning =>
      this == CommissioningSerialPoolStatus.alreadyCommissioned ||
      this == CommissioningSerialPoolStatus.notPreAllocated ||
      this == CommissioningSerialPoolStatus.notTransitionable;

  bool get allowsCommissioning =>
      this == CommissioningSerialPoolStatus.preReserved;
}
