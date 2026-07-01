enum DecommissioningStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

DecommissioningStatus parseDecommissioningStatus(String status) {
  switch (status.toLowerCase()) {
    case 'success':
      return DecommissioningStatus.success;
    case 'partialsuccess':
    case 'partial_success':
      return DecommissioningStatus.partialSuccess;
    case 'failed':
      return DecommissioningStatus.failed;
    case 'validationerror':
    case 'validation_error':
      return DecommissioningStatus.validationError;
    default:
      return DecommissioningStatus.failed;
  }
}
