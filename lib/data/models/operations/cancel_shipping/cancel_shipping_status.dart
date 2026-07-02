enum CancelShippingStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

CancelShippingStatus parseCancelShippingStatus(String status) {
  switch (status.toUpperCase()) {
    case 'SUCCESS':
      return CancelShippingStatus.success;
    case 'PARTIAL_SUCCESS':
      return CancelShippingStatus.partialSuccess;
    case 'FAILED':
      return CancelShippingStatus.failed;
    case 'VALIDATION_ERROR':
      return CancelShippingStatus.validationError;
    default:
      return CancelShippingStatus.failed;
  }
}
