import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_expandable_node_tile.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_leaf_node_tile.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class ProductHierarchyNodeTile extends StatelessWidget {
  const ProductHierarchyNodeTile({
    super.key,
    required this.nodeState,
    this.isHighlighted = false,
    this.isFlashing = false,
    this.isSearchMatch = false,
    this.isGroupHeader = false,
    this.showBorder = true,
    this.canClimb = false,
    this.onSelect,
    this.onExpand,
    this.onCollapse,
    this.onClimb,
  });

  final HierarchyTreeNodeState nodeState;
  final bool isHighlighted;
  final bool isFlashing;
  final bool isSearchMatch;
  final bool isGroupHeader;
  final bool showBorder;
  final bool canClimb;
  final ValueChanged<HierarchyTreeNodeState>? onSelect;
  final ValueChanged<HierarchyTreeNodeState>? onExpand;
  final ValueChanged<HierarchyTreeNodeState>? onCollapse;
  final ValueChanged<HierarchyTreeNodeState>? onClimb;

  @override
  Widget build(BuildContext context) {
    if (nodeState.node.hasChildren) {
      return ProductHierarchyExpandableNodeTile(
        nodeState: nodeState,
        isHighlighted: isHighlighted,
        isFlashing: isFlashing,
        isSearchMatch: isSearchMatch,
        isGroupHeader: isGroupHeader,
        showBorder: showBorder,
        canClimb: canClimb,
        onSelect: onSelect,
        onExpand: onExpand,
        onCollapse: onCollapse,
        onClimb: onClimb,
      );
    }
    return ProductHierarchyLeafNodeTile(
      nodeState: nodeState,
      isHighlighted: isHighlighted,
      isFlashing: isFlashing,
      isSearchMatch: isSearchMatch,
      canClimb: canClimb,
      onSelect: onSelect,
      onClimb: onClimb,
    );
  }
}
