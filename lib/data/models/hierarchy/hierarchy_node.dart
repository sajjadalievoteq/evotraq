class HierarchyNode {
  final String epc;
  final String type;
  final bool hasChildren;
  final int? childCount;
  final String? gtin;
  final String? productName;
  final String? lotNumber;
  final String? expiryDate;
  final String? sscc;
  final String? containerType;
  final String? status;
  final String? disposition;

  const HierarchyNode({
    required this.epc,
    required this.type,
    required this.hasChildren,
    this.childCount,
    this.gtin,
    this.productName,
    this.lotNumber,
    this.expiryDate,
    this.sscc,
    this.containerType,
    this.status,
    this.disposition,
  });

  bool get isSscc => type == 'SSCC';
  bool get isSgtin => type == 'SGTIN';

  String get shortEpc {
    if (epc.length <= 12) return epc;
    return '…${epc.substring(epc.length - 12)}';
  }

  factory HierarchyNode.fromJson(Map<String, dynamic> json) {
    final nodeType = json['identifierType'] as String? ?? json['type'] as String? ?? 'UNKNOWN';
    return HierarchyNode(
      epc: json['epc'] as String,
      type: nodeType,
      hasChildren: json['hasChildren'] as bool? ?? false,
      childCount: (json['childCount'] as num?)?.toInt(),
      gtin: json['gtin'] as String?,
      productName: json['productName'] as String?,
      lotNumber: json['lotNumber'] as String?,
      expiryDate: json['expiryDate'] as String?,
      sscc: json['sscc'] as String?,
      containerType: json['containerType'] as String?,
      status: json['status'] as String?,
      disposition: json['disposition'] as String?,
    );
  }
}
