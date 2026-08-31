import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';

class SsccCommissioningPrefill {
  const SsccCommissioningPrefill({
    required this.ssccCode,
    this.commissioningLocationGln,
    this.readPointGln,
    this.batchLotNumber,
    this.expiryDate,
    this.productionDate,
    this.commissioningReference,
  });

  final String ssccCode;
  final String? commissioningLocationGln;
  final String? readPointGln;
  final String? batchLotNumber;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final String? commissioningReference;

  factory SsccCommissioningPrefill.fromSscc({
    required SSCC sscc,
    GLN? issuingGln,
    GLN? shipFromGln,
    String? purchaseOrder,
  }) {
    return SsccCommissioningPrefill(
      ssccCode: sscc.ssccCode,
      commissioningLocationGln:
          issuingGln?.glnCode ?? sscc.issuingGLN?.glnCode,
      readPointGln: shipFromGln?.glnCode ?? sscc.shipFromGln,
      batchLotNumber: sscc.containedBatch,
      expiryDate: sscc.containedExpiry,
      productionDate: sscc.packingDate,
      commissioningReference: purchaseOrder?.trim().isNotEmpty == true
          ? purchaseOrder!.trim()
          : sscc.purchaseOrderNumber,
    );
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'identifierType': 'sscc',
      'epc': ssccCode.trim(),
    };
    void add(String key, String? value) {
      if (value == null || value.trim().isEmpty) return;
      params[key] = value.trim();
    }

    add('locationGln', commissioningLocationGln);
    add('readPointGln', readPointGln);
    add('batchLot', batchLotNumber);
    add('reference', commissioningReference);
    if (expiryDate != null) {
      params['expiry'] = _formatDate(expiryDate!);
    }
    if (productionDate != null) {
      params['productionDate'] = _formatDate(productionDate!);
    }
    return params;
  }

  static SsccCommissioningPrefill? fromQueryParameters(
    Map<String, String> query,
  ) {
    final ssccCode = query['epc']?.trim();
    if (ssccCode == null || ssccCode.isEmpty) return null;

    return SsccCommissioningPrefill(
      ssccCode: ssccCode,
      commissioningLocationGln: query['locationGln'],
      readPointGln: query['readPointGln'],
      batchLotNumber: query['batchLot'],
      commissioningReference: query['reference'],
      expiryDate: _parseDate(query['expiry']),
      productionDate: _parseDate(query['productionDate']),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw.trim());
  }
}
