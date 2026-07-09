/// Per-EPC status from a pre-submission serial pool check.
enum CommissioningSerialPoolStatus {
  /// Async lookup in progress.
  checking,

  /// Exists as RESERVED or ALLOCATED — eligible for commissioning transition.
  preReserved,

  /// Already commissioned with a recorded EPCIS event.
  alreadyCommissioned,

  /// Not found in the serial pool.
  notPreAllocated,

  /// Found but lifecycle state cannot transition to commissioned.
  notTransitionable,

  /// Lookup failed (network/parse).
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
