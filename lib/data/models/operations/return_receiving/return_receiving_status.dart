enum ReturnReceivingStatus { success, partialSuccess, failed, validationError }

ReturnReceivingStatus parseReturnReceivingStatus(String status) {
  switch (status.toUpperCase()) {
    case 'SUCCESS':
      return ReturnReceivingStatus.success;
    case 'PARTIAL_SUCCESS':
      return ReturnReceivingStatus.partialSuccess;
    case 'FAILED':
      return ReturnReceivingStatus.failed;
    case 'VALIDATION_ERROR':
      return ReturnReceivingStatus.validationError;
    default:
      return ReturnReceivingStatus.failed;
  }
}
