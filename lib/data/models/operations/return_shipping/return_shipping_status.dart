enum ReturnShippingStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

ReturnShippingStatus parseReturnShippingStatus(String status) {
  switch (status.toUpperCase()) {
    case 'SUCCESS':
      return ReturnShippingStatus.success;
    case 'PARTIAL_SUCCESS':
      return ReturnShippingStatus.partialSuccess;
    case 'FAILED':
      return ReturnShippingStatus.failed;
    case 'VALIDATION_ERROR':
      return ReturnShippingStatus.validationError;
    default:
      return ReturnShippingStatus.failed;
  }
}
