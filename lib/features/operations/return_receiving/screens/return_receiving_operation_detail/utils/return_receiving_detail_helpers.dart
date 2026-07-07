import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';

/// Return Receiving Detail display helpers.
class ReturnReceivingDetailHelpers {
  ReturnReceivingDetailHelpers._();

  static bool hasTransportDetails(ReturnReceivingResponse operation) {
    return operation.carrier != null ||
        operation.trackingNumber != null ||
        operation.billOfLadingNumber != null ||
        operation.purchaseOrderNumber != null ||
        operation.despatchAdviceNumber != null ||
        operation.receivingAdviceNumber != null ||
        operation.invoiceNumber != null ||
        operation.gincNumber != null;
  }
}

