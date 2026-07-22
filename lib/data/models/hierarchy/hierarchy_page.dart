import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';

class HierarchyPage {
  final List<HierarchyNode> children;
  final int page;
  final int size;
  final int total;
  final int totalPages;
  final bool hasMore;

  const HierarchyPage({
    required this.children,
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory HierarchyPage.fromJson(Map<String, dynamic> json) {
    return HierarchyPage(
      children: (json['children'] as List<dynamic>)
          .map((e) => HierarchyNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
