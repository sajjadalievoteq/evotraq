
enum CommissioningBatchLookupStatus {
  idle,
  lookingUp,
  found,
  notFound,
  registering,
  registered,
  error,
}

extension CommissioningBatchLookupStatusX on CommissioningBatchLookupStatus {
  bool get isBusy =>
      this == CommissioningBatchLookupStatus.lookingUp ||
      this == CommissioningBatchLookupStatus.registering;

  bool get isReadyForCommissioning =>
      this == CommissioningBatchLookupStatus.found ||
      this == CommissioningBatchLookupStatus.registered ||
      this == CommissioningBatchLookupStatus.idle ||
      this == CommissioningBatchLookupStatus.error;
}
