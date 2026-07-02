enum CancelReceivingStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

CancelReceivingStatus parseCancelReceivingStatus(String status) {
  switch (status.toUpperCase()) {
    case 'SUCCESS':
      return CancelReceivingStatus.success;
    case 'PARTIAL_SUCCESS':
      return CancelReceivingStatus.partialSuccess;
    case 'FAILED':
      return CancelReceivingStatus.failed;
    case 'VALIDATION_ERROR':
      return CancelReceivingStatus.validationError;
    default:
      return CancelReceivingStatus.failed;
  }
}
