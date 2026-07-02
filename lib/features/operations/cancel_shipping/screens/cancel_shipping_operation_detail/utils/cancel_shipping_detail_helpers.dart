import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';

abstract final class CancelShippingDetailHelpers {
  static bool hasComplianceDetails(CancelShippingResponse operation) {
    return operation.originalShippingReference != null ||
        operation.cancelReason != null;
  }
}
