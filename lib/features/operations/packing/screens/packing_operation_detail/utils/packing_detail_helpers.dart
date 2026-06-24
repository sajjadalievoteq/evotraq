import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';

/// Packing detail display helpers.
class PackingDetailHelpers {
  PackingDetailHelpers._();

  static bool hasProductionDetails(PackingResponse operation) {
    return operation.workOrderNumber != null ||
        operation.batchNumber != null ||
        operation.productionOrder != null ||
        operation.packingLine != null;
  }
}
