import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_content.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_skeleton.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class ProductHierarchyCompactDetailContent extends StatelessWidget {
  const ProductHierarchyCompactDetailContent({
    super.key,
    required this.state,
    required this.root,
  });

  final ProductHierarchyState state;
  final HierarchyTreeNodeState root;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingDetails && state.selectedJourney == null) {
      return const ProductHierarchySidebarSkeleton();
    }
    if (state.selectedJourney != null) {
      return ProductHierarchySidebarContent(
        root: root,
        selectedEpc: state.selectedEpc ?? root.node.epc,
        journey: state.selectedJourney!,
      );
    }
    if ((state.detailsError ?? '').isNotEmpty) {
      return AppEmptyDetail(
        iconAsset: NavIcons.productHierarchy,
        title: 'Unable to load node details',
        subtitle: state.detailsError!,
      );
    }
    return const ProductHierarchySidebarSkeleton();
  }
}
