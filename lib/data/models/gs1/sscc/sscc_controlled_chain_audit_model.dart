class SsccControlledChainAudit {
  const SsccControlledChainAudit({
    this.id,
    required this.ssccId,
    this.ssccCode,
    this.witnessName,
    this.witnessGln,
    this.transferAt,
    this.notes,
  });

  final int? id;
  final int ssccId;
  final String? ssccCode;
  final String? witnessName;
  final String? witnessGln;
  final DateTime? transferAt;
  final String? notes;

  factory SsccControlledChainAudit.fromJson(Map<String, dynamic> json) {
    return SsccControlledChainAudit(
      id: json['id'] as int?,
      ssccId: json['ssccId'] as int,
      ssccCode: json['ssccCode'] as String?,
      witnessName: json['witnessName'] as String?,
      witnessGln: json['witnessGln'] as String?,
      transferAt: json['transferAt'] != null
          ? DateTime.tryParse(json['transferAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (witnessName != null) 'witnessName': witnessName,
        if (witnessGln != null) 'witnessGln': witnessGln,
        if (transferAt != null) 'transferAt': transferAt!.toIso8601String(),
        if (notes != null) 'notes': notes,
      };
}
