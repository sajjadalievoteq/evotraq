class SsccAggregationLink {
  const SsccAggregationLink({
    this.id,
    required this.parentSsccCode,
    required this.childEpc,
    required this.childKind,
    this.aggregatedAt,
    this.aggregationEventId,
    this.disaggregatedAt,
    this.disaggregationEventId,
    this.active = true,
  });

  final int? id;
  final String parentSsccCode;
  final String childEpc;
  final String childKind;
  final DateTime? aggregatedAt;
  final String? aggregationEventId;
  final DateTime? disaggregatedAt;
  final String? disaggregationEventId;
  final bool active;

  factory SsccAggregationLink.fromJson(Map<String, dynamic> json) {
    return SsccAggregationLink(
      id: json['id'] as int?,
      parentSsccCode: json['parentSsccCode'] as String? ?? '',
      childEpc: json['childEpc'] as String? ?? '',
      childKind: json['childKind'] as String? ?? 'SGTIN',
      aggregatedAt: json['aggregatedAt'] != null
          ? DateTime.tryParse(json['aggregatedAt'] as String)
          : null,
      aggregationEventId: json['aggregationEventId'] as String?,
      disaggregatedAt: json['disaggregatedAt'] != null
          ? DateTime.tryParse(json['disaggregatedAt'] as String)
          : null,
      disaggregationEventId: json['disaggregationEventId'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }
}
