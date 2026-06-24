enum UnpackingStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

UnpackingStatus parseUnpackingStatus(String status) {
  switch (status.toUpperCase()) {
    case 'SUCCESS':
      return UnpackingStatus.success;
    case 'PARTIAL_SUCCESS':
      return UnpackingStatus.partialSuccess;
    case 'FAILED':
      return UnpackingStatus.failed;
    case 'VALIDATION_ERROR':
      return UnpackingStatus.validationError;
    default:
      return UnpackingStatus.failed;
  }
}
