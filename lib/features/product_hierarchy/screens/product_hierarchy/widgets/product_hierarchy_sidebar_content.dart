import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_children_summary_card.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_node_details_card.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_packaging_path_card.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_parent_card.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_selected_item_card.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_actions.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_stats_section.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_display_utils.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';





class ProductHierarchySidebarContent extends StatelessWidget {
  const ProductHierarchySidebarContent({
    super.key,
    required this.root,
    required this.selectedEpc,
    required this.journey,
  });

  final HierarchyTreeNodeState root;
  final String selectedEpc;
  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    final selected =
        ProductHierarchyTreeUtils.findNode(root, selectedEpc) ?? root;
    final parent = ProductHierarchyTreeUtils.findParent(root, selected.node.epc);
    final path = ProductHierarchyTreeUtils.pathTo(root, selected.node.epc);
    final info = journey.productInfo;
    final depth = ProductHierarchyTreeUtils.depthOf(root, selected.node.epc);
    final loadedStats =
        ProductHierarchyTreeUtils.loadedDescendantStats(selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductHierarchySelectedItemCard(
          node: selected.node,
          journey: journey,
          info: info,
        ),
        const SizedBox(height: TraqSpacing.lg),
        ProductHierarchySidebarActions(
          identifier: journey.identifier.isNotEmpty
              ? journey.identifier
              : selected.node.epc,
        ),
        const SizedBox(height: TraqSpacing.lg),
        ProductHierarchyStatsSection(
          node: selected.node,
          info: info,
          depth: depth,
          loadedStats: loadedStats,
        ),
        const SizedBox(height: TraqSpacing.lg),
        ProductHierarchyParentCard(
          parent: parent,
          info: info,
          isRoot: parent == null,
        ),
        const SizedBox(height: TraqSpacing.lg),
        ProductHierarchyNodeDetailsCard(
          node: selected.node,
          journey: journey,
          info: info,
        ),
        const SizedBox(height: TraqSpacing.lg),
        ProductHierarchyChildrenSummaryCard(
          node: selected.node,
          info: info,
          loadedStats: loadedStats,
        ),
        if (path.isNotEmpty) ...[
          const SizedBox(height: TraqSpacing.lg),
          ProductHierarchyPackagingPathCard(
            path: path,
            selectedEpc: selected.node.epc,
          ),
        ],
        const SizedBox(height: TraqSpacing.lg),

        const SizedBox(height: TraqSpacing.xl),
      ],
    );
  }
}
