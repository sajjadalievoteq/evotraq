enum PackingStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

PackingStatus parsePackingStatus(String status) {
  switch (status.toUpperCase()) {
    case 'SUCCESS':
      return PackingStatus.success;
    case 'PARTIAL_SUCCESS':
      return PackingStatus.partialSuccess;
    case 'FAILED':
      return PackingStatus.failed;
    case 'VALIDATION_ERROR':
      return PackingStatus.validationError;
    default:
      return PackingStatus.failed;
  }
}
