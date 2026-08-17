enum SgtinBatchLookupStatus {
  idle,
  lookingUp,
  found,
  notFound,
  registering,
  registered,
  error,
}

extension SgtinBatchLookupStatusX on SgtinBatchLookupStatus {
  bool get isBusy =>
      this == SgtinBatchLookupStatus.lookingUp ||
      this == SgtinBatchLookupStatus.registering;

  bool get isResolved =>
      this == SgtinBatchLookupStatus.found ||
      this == SgtinBatchLookupStatus.registered;

  bool get needsRegistration =>
      this == SgtinBatchLookupStatus.notFound ||
      this == SgtinBatchLookupStatus.registering;

  bool get canSubmitSgtin => isResolved;
}
