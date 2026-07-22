import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
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
  });

  final HierarchyTreeNodeState parent;
  final int depth;
  final bool inGroupBody;
  final bool isFirstInGroupBody;
  final bool isLastInGroupBody;
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
    final slotCount = kids.length + (node.hasMore ? 1 : 0);
    for (var i = 0; i < kids.length; i++) {
      final first = i == 0;
      final last = i == slotCount - 1;
      walk(
        kids[i],
        depth + 1,
        inGroupBody: true,
        isFirst: first,
        isLast: last,
      );
    }
    if (node.hasMore) {
      items.add(
        ProductHierarchySentinelItem(
          parent: node,
          depth: depth + 1,
          inGroupBody: true,
          isFirstInGroupBody: kids.isEmpty,
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
