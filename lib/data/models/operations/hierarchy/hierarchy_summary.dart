/// Lightweight summary of the full recursive hierarchy returned by the
/// traversal endpoint. Used for the summary banner; not used for tree display.
class HierarchySummary {
  final int totalItemCount;
  final int hierarchyDepth;
  final int directChildCount;

  const HierarchySummary({
    required this.totalItemCount,
    required this.hierarchyDepth,
    required this.directChildCount,
  });

  factory HierarchySummary.fromJson(Map<String, dynamic> json) {
    final directChildren = json['directChildren'] as List<dynamic>? ?? [];
    return HierarchySummary(
      totalItemCount: (json['totalItemCount'] as num?)?.toInt() ?? 0,
      hierarchyDepth: (json['hierarchyDepth'] as num?)?.toInt() ?? 0,
      directChildCount: directChildren.length,
    );
  }
}
