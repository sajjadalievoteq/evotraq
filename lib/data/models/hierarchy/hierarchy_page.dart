import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';

class HierarchyPage {
  final List<HierarchyNode> children;
  final int page;
  final int size;
  final int total;
  final int totalPages;
  final bool hasMore;
  final int? cycleCount;

  /// Parent-context / climb-up fields (only set when [focusEpc] mode is used).
  final String? focusEpc;
  final int? focusPage;
  final int? focusIndexInPage;
  final String? parentEpc;
  final HierarchyNode? parent;
  final bool? hasParent;
  final bool? parentHasParent;

  const HierarchyPage({
    required this.children,
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
    required this.hasMore,
    this.cycleCount,
    this.focusEpc,
    this.focusPage,
    this.focusIndexInPage,
    this.parentEpc,
    this.parent,
    this.hasParent,
    this.parentHasParent,
  });

  factory HierarchyPage.fromJson(Map<String, dynamic> json) {
    return HierarchyPage(
      children: (json['children'] as List<dynamic>? ?? const [])
          .map((e) => HierarchyNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
      cycleCount: (json['cycleCount'] as num?)?.toInt(),
      focusEpc: json['focusEpc'] as String?,
      focusPage: (json['focusPage'] as num?)?.toInt(),
      focusIndexInPage: (json['focusIndexInPage'] as num?)?.toInt(),
      parentEpc: json['parentEpc'] as String?,
      parent: json['parent'] is Map<String, dynamic>
          ? HierarchyNode.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      hasParent: json['hasParent'] as bool?,
      parentHasParent: json['parentHasParent'] as bool?,
    );
  }
}
