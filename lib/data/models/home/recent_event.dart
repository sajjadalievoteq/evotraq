/// Recent EPCIS-style event row for dashboard lists.
class RecentEvent {
  final String id;
  final String eventType;
  final String action;
  final String? bizStep;
  final DateTime eventTime;

  /// Normalised EPC list. Source field varies by event type:
  /// - ObjectEvent / TransactionEvent → `epcList`
  /// - AggregationEvent              → `childEPCs`
  /// - TransformationEvent           → `outputEPCList`
  final List<String> epcList;

  /// Number of input EPCs for TransformationEvent (`inputEPCList` length).
  final int inputEpcCount;

  /// Parent EPC/SSCC for AggregationEvent and TransactionEvent (`parentID`).
  final String? parentId;

  /// GTIN-14 from ILMD `traqtrace:gtin` (commissioning / transformation events).
  final String? gtinCode;

  /// Lot/batch number from ILMD `cbvmda:lotNumber`.
  final String? batchLotNumber;

  RecentEvent({
    required this.id,
    required this.eventType,
    required this.action,
    this.bizStep,
    required this.eventTime,
    required this.epcList,
    this.inputEpcCount = 0,
    this.parentId,
    this.gtinCode,
    this.batchLotNumber,
  });

  factory RecentEvent.fromJson(Map<String, dynamic> json) {
    final ilmd = json['ilmd'] as Map<String, dynamic>?;
    return RecentEvent(
      id: json['id']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? 'Unknown',
      action: json['action']?.toString() ?? '',
      bizStep: (json['bizStep'] ?? json['businessStep'])?.toString(),
      eventTime: json['eventTime'] != null
          ? DateTime.tryParse(json['eventTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      epcList: _parseEpcList(json),
      inputEpcCount: (json['inputEPCList'] as List?)?.length ?? 0,
      parentId: json['parentID']?.toString(),
      gtinCode: ilmd?['traqtrace:gtin']?.toString(),
      batchLotNumber: ilmd?['cbvmda:lotNumber']?.toString(),
    );
  }

  /// Returns the first non-empty EPC list found across the known field names.
  static List<String> _parseEpcList(Map<String, dynamic> json) {
    for (final key in const ['epcList', 'childEPCs', 'outputEPCList']) {
      if (json[key] is List && (json[key] as List).isNotEmpty) {
        return (json[key] as List).map((e) => e.toString()).toList();
      }
    }
    return [];
  }
}
