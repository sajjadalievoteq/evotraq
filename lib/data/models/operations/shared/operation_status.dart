enum OperationStatus {
  success,
  partialSuccess,
  failed,
  validationError,
  accepted,
}

OperationStatus parseOperationStatus(Object? status) {
  if (status == null) return OperationStatus.failed;

  final raw = status.toString().trim();
  if (raw.isEmpty) return OperationStatus.failed;

  final upper = raw.toUpperCase().replaceAll(' ', '_');
  final lower = raw.toLowerCase().replaceAll(' ', '_');

  switch (upper) {
    case 'SUCCESS':
      return OperationStatus.success;
    case 'PARTIAL_SUCCESS':
    case 'PARTIALSUCCESS':
      return OperationStatus.partialSuccess;
    case 'FAILED':
      return OperationStatus.failed;
    case 'VALIDATION_ERROR':
    case 'VALIDATIONERROR':
      return OperationStatus.validationError;
    case 'ACCEPTED':
      return OperationStatus.accepted;
  }

  switch (lower) {
    case 'success':
      return OperationStatus.success;
    case 'partialsuccess':
    case 'partial_success':
      return OperationStatus.partialSuccess;
    case 'failed':
      return OperationStatus.failed;
    case 'validationerror':
    case 'validation_error':
      return OperationStatus.validationError;
    case 'accepted':
      return OperationStatus.accepted;
  }

  return OperationStatus.failed;
}
