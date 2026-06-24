enum ReceivingStatus { success, partialSuccess, failed, validationError }

ReceivingStatus parseReceivingStatus(String status) {
  switch (status.toUpperCase()) {
    case 'SUCCESS':
      return ReceivingStatus.success;
    case 'PARTIAL_SUCCESS':
      return ReceivingStatus.partialSuccess;
    case 'FAILED':
      return ReceivingStatus.failed;
    case 'VALIDATION_ERROR':
      return ReceivingStatus.validationError;
    default:
      return ReceivingStatus.failed;
  }
}
