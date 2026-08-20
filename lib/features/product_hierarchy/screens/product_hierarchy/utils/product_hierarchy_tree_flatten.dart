import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_colors.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';


sealed class ProductHierarchyFlatItem {
  const ProductHierarchyFlatItem();
}

final class ProductHierarchyNodeItem extends ProductHierarchyFlatItem {
  const ProductHierarchyNodeItem({
    required this.nodeState,
    required this.depth,
    required this.inGroupBody,
    required this.isFirstInGroupBody,
    required this.isLastInGroupBody,
  });

  final HierarchyTreeNodeState nodeState;
  
  final int depth;
  
  final bool inGroupBody;
  final bool isFirstInGroupBody;
  final bool isLastInGroupBody;

  bool get isExpandable => nodeState.node.hasChildren;
  bool get isExpandedHeader => isExpandable && nodeState.isExpanded;
}

final class ProductHierarchySentinelItem extends ProductHierarchyFlatItem {
  const ProductHierarchySentinelItem({
    required this.parent,
    required this.depth,
    required this.inGroupBody,
    required this.isFirstInGroupBody,
    required this.isLastInGroupBody,
    this.isPrevious = false,
  });

  final HierarchyTreeNodeState parent;
  final int depth;
  final bool inGroupBody;
  final bool isFirstInGroupBody;
  final bool isLastInGroupBody;

  /// True for the leading "load earlier siblings" indicator (scroll-up), false
  /// for the trailing "load more" indicator (scroll-down).
  final bool isPrevious;
}


List<ProductHierarchyFlatItem> flattenProductHierarchy(
  HierarchyTreeNodeState root,
) {
  final items = <ProductHierarchyFlatItem>[];

  void walk(
    HierarchyTreeNodeState node,
    int depth, {
    required bool inGroupBody,
    required bool isFirst,
    required bool isLast,
  }) {
    final canExpand = node.node.hasChildren;
    final expanded = canExpand && node.isExpanded;

    items.add(
      ProductHierarchyNodeItem(
        nodeState: node,
        depth: depth,
        inGroupBody: inGroupBody,
        isFirstInGroupBody: isFirst,
        
        
        isLastInGroupBody: isLast && !expanded,
      ),
    );

    if (!expanded) return;

    final kids = node.loadedChildren;
    // Only the view-root (depth 0) can page backwards after a climb.
    final showPrevious = depth == 0 && node.hasPrevious;
    final showMore = node.hasMore;

    if (showPrevious) {
      items.add(
        ProductHierarchySentinelItem(
          parent: node,
          depth: depth + 1,
          inGroupBody: true,
          isFirstInGroupBody: true,
          isLastInGroupBody: kids.isEmpty && !showMore,
          isPrevious: true,
        ),
      );
    }
    for (var i = 0; i < kids.length; i++) {
      final first = i == 0 && !showPrevious;
      final last = i == kids.length - 1 && !showMore;
      walk(
        kids[i],
        depth + 1,
        inGroupBody: true,
        isFirst: first,
        isLast: last,
      );
    }
    if (showMore) {
      items.add(
        ProductHierarchySentinelItem(
          parent: node,
          depth: depth + 1,
          inGroupBody: true,
          isFirstInGroupBody: kids.isEmpty && !showPrevious,
          isLastInGroupBody: true,
        ),
      );
    }
  }

  walk(root, 0, inGroupBody: false, isFirst: true, isLast: true);
  return items;
}

Color productHierarchyAccentForDepth(TraqColors c, int depth) {
  switch (depth % 4) {
    case 0:
      return c.primary;
    case 1:
      return c.secondary;
    case 2:
      return c.identifierSscc;
    default:
      return c.identifierSgtin;
  }
}
