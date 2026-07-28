import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_recent_parents_section.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_content.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_skeleton.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_identifier_utils.dart';

/// Body of the left panel below the search header (loading / details / idle).
class ProductHierarchyLeftPanelBody extends StatelessWidget {
  const ProductHierarchyLeftPanelBody({
    super.key,
    required this.state,
    required this.searchController,
  });

  final ProductHierarchyState state;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductHierarchyCubit>();

    if (state.isLoadingDetails ||
        state.isResolvingRoot ||
        state.isClimbing) {
      return const ProductHierarchySidebarSkeleton();
    }

    final journey = state.selectedJourney;
    final root = state.root;
    if (journey != null && root != null) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          15,
          context.padding.top,
          0,
        ),
        child: ProductHierarchySidebarContent(
          root: root,
          selectedEpc: state.selectedEpc ?? root.node.epc,
          journey: journey,
        ),
      );
    }
    if ((state.detailsError ?? '').isNotEmpty) {
      return AppEmptyDetail(
        iconAsset: NavIcons.productHierarchy,
        title: 'Unable to load node details',
        subtitle: state.detailsError!,
      );
    }
    if (state.searchResults.isEmpty) {
      return ProductHierarchyRecentParentsSection(
        parents: state.recentParents,
        isLoading: state.recentParentsLoading,
        onTap: (op) {
          final epc = normalizeProductHierarchyInput(
            op.parentContainerId ?? '',
          );
          if (epc.isEmpty) return;
          searchController.text = epc;
          cubit.openHierarchy(epc);
        },
      );
    }
    return const SizedBox.shrink();
  }
}
