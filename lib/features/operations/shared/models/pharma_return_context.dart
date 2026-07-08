import 'package:traqtrace_app/features/operations/shared/models/pharma_return_reason.dart';

class PharmaReturnContext {
  const PharmaReturnContext({
    required this.sourceEventId,
    required this.epcs,
    required this.senderGln,
    required this.receiverGln,
    this.gtin,
    this.lotNumber,
    this.expiryDate,
    this.quantity,
    this.productDescription,
    this.returnReason,
    this.returnShippingEventId,
  });

  final String sourceEventId;
  final List<String> epcs;
  final String senderGln;
  final String receiverGln;
  final String? gtin;
  final String? lotNumber;
  final DateTime? expiryDate;
  final int? quantity;
  final String? productDescription;
  final PharmaReturnReason? returnReason;
  final String? returnShippingEventId;

  String get returnShippingSourceGln => receiverGln;
  String get returnShippingDestinationGln => senderGln;

  String get returnReceivingSourceGln => receiverGln;
  String get returnReceivingDestinationGln => senderGln;

  Map<String, dynamic> toExtra() => {
        'sourceEventId': sourceEventId,
        'epcs': epcs,
        'senderGln': senderGln,
        'receiverGln': receiverGln,
        'gtin': gtin,
        'lotNumber': lotNumber,
        'expiryDate': expiryDate?.toIso8601String(),
        'quantity': quantity,
        'productDescription': productDescription,
        'returnReason': returnReason?.code,
        'returnShippingEventId': returnShippingEventId,
      };

  factory PharmaReturnContext.fromExtra(Map<String, dynamic>? extra) {
    if (extra == null || extra.isEmpty) {
      throw ArgumentError('Missing pharma return context');
    }
    final epcs = (extra['epcs'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final expiryRaw = extra['expiryDate']?.toString();
    return PharmaReturnContext(
      sourceEventId: extra['sourceEventId']?.toString() ?? '',
      epcs: epcs,
      senderGln: extra['senderGln']?.toString() ?? '',
      receiverGln: extra['receiverGln']?.toString() ?? '',
      gtin: extra['gtin']?.toString(),
      lotNumber: extra['lotNumber']?.toString(),
      expiryDate: expiryRaw != null && expiryRaw.isNotEmpty
          ? DateTime.tryParse(expiryRaw)
          : null,
      quantity: (extra['quantity'] as num?)?.toInt(),
      productDescription: extra['productDescription']?.toString(),
      returnReason: PharmaReturnReason.fromCode(extra['returnReason']?.toString()),
      returnShippingEventId: extra['returnShippingEventId']?.toString(),
    );
  }

  bool get isValid =>
      sourceEventId.isNotEmpty &&
      epcs.isNotEmpty &&
      senderGln.isNotEmpty &&
      receiverGln.isNotEmpty &&
      senderGln != receiverGln;
}
