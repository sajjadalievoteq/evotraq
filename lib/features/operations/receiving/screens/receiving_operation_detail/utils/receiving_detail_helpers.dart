import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';

/// Receiving detail display helpers.
class ReceivingDetailHelpers {
  ReceivingDetailHelpers._();

  static bool hasTransportDetails(ReceivingResponse operation) {
    return operation.carrier != null ||
        operation.trackingNumber != null ||
        operation.billOfLadingNumber != null ||
        operation.purchaseOrderNumber != null ||
        operation.despatchAdviceNumber != null ||
        operation.receivingAdviceNumber != null ||
        operation.invoiceNumber != null;
  }
}
