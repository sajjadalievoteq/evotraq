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
  final bool? cycle;
  final bool? focused;

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
    this.cycle,
    this.focused,
  });

  bool get isSscc => type == 'SSCC';
  bool get isSgtin => type == 'SGTIN';
  bool get isCycle => cycle == true;
  bool get isFocused => focused == true;

  String get shortEpc {
    if (epc.length <= 12) return epc;
    return '…${epc.substring(epc.length - 12)}';
  }

  factory HierarchyNode.fromJson(Map<String, dynamic> json) {
    final nodeType =
        json['identifierType'] as String? ??
        json['type'] as String? ??
        'UNKNOWN';
    final cycle = json['cycle'] as bool?;
    final hasChildrenRaw = json['hasChildren'] as bool? ?? false;
    return HierarchyNode(
      epc: json['epc'] as String,
      type: nodeType,
      // Cycle nodes must not be expandable (backend also forces hasChildren=false).
      hasChildren: cycle == true ? false : hasChildrenRaw,
      childCount: (json['childCount'] as num?)?.toInt(),
      gtin: json['gtin'] as String?,
      productName: json['productName'] as String?,
      lotNumber: json['lotNumber'] as String?,
      expiryDate: json['expiryDate'] as String?,
      sscc: json['sscc'] as String?,
      containerType: json['containerType'] as String?,
      status: json['status'] as String?,
      disposition: json['disposition'] as String?,
      cycle: cycle,
      focused: json['focused'] as bool?,
    );
  }
}
