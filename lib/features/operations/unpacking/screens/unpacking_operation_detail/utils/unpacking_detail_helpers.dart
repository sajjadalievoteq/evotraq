import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';

/// Unpacking detail display helpers.
class UnpackingDetailHelpers {
  UnpackingDetailHelpers._();

  static bool hasProductionDetails(UnpackingResponse operation) {
    return operation.workOrderNumber != null ||
        operation.batchNumber != null ||
        operation.productionOrder != null ||
        operation.unpackingLine != null;
  }
}
