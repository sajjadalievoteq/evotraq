import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';

abstract final class CancelReceivingDetailHelpers {
  static bool hasComplianceDetails(CancelReceivingResponse operation) {
    return operation.originalReceivingReference != null ||
        operation.cancelReason != null;
  }
}
