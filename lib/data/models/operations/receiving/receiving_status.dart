enum ReceivingStatus { success, partialSuccess, failed, validationError, accepted }

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
    case 'ACCEPTED':
      return ReceivingStatus.accepted;
    default:
      return ReceivingStatus.failed;
  }
}
