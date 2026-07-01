class HierarchyNode {
  final String epc;
  final String type; // 'SSCC' | 'SGTIN' | 'UNKNOWN'
  final bool hasChildren;

  const HierarchyNode({
    required this.epc,
    required this.type,
    required this.hasChildren,
  });

  bool get isSscc => type == 'SSCC';
  bool get isSgtin => type == 'SGTIN';

  /// Returns a shortened display label: last 12 chars of the EPC.
  String get shortEpc {
    if (epc.length <= 12) return epc;
    return '…${epc.substring(epc.length - 12)}';
  }

  factory HierarchyNode.fromJson(Map<String, dynamic> json) {
    return HierarchyNode(
      epc: json['epc'] as String,
      type: json['type'] as String? ?? 'UNKNOWN',
      hasChildren: json['hasChildren'] as bool? ?? false,
    );
  }
}
