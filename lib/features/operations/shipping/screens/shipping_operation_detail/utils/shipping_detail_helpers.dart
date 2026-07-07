import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';

/// Shipping detail display helpers.
class ShippingDetailHelpers {
  ShippingDetailHelpers._();

  static bool hasTransportDetails(ShippingResponse operation) {
    return operation.carrier != null ||
        operation.trackingNumber != null ||
        operation.billOfLadingNumber != null ||
        operation.purchaseOrderNumber != null ||
        operation.despatchAdviceNumber != null ||
        operation.gincNumber != null;
  }
}
