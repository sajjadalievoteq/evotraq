enum ShippingStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

ShippingStatus parseShippingStatus(String status) {
  switch (status.toUpperCase()) {
    case 'SUCCESS':
      return ShippingStatus.success;
    case 'PARTIAL_SUCCESS':
      return ShippingStatus.partialSuccess;
    case 'FAILED':
      return ShippingStatus.failed;
    case 'VALIDATION_ERROR':
      return ShippingStatus.validationError;
    default:
      return ShippingStatus.failed;
  }
}
