import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_gln_validators.dart';

class ReceivingDetailHelpers {
  ReceivingDetailHelpers._();

  static String? receivingGlnCode(ReceivingResponse operation) {
    final raw = operation.receivingGLN ?? operation.receivingLocation?.glnCode;
    if (raw == null || raw.trim().isEmpty) return null;
    final normalized = EpcisGlnValidators.parseGlnToCode(raw.trim());
    return normalized.trim().isEmpty ? null : normalized;
  }

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
