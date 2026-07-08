import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';

class ReturnShippingDetailHelpers {
  ReturnShippingDetailHelpers._();

  static bool hasTransportDetails(ReturnShippingResponse operation) {
    return operation.carrier != null ||
        operation.trackingNumber != null ||
        operation.billOfLadingNumber != null ||
        operation.purchaseOrderNumber != null ||
        operation.despatchAdviceNumber != null ||
        operation.gincNumber != null;
  }
}
