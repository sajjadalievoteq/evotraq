import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_left_panel.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_content.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_skeleton.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_tree_panel.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_mobile_bottom_sheet.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

bool productHierarchyShowsCompactDetail(ProductHierarchyState state) {
  return state.isResolvingRoot ||
      state.hasHierarchy ||
      (state.hierarchyError ?? '').isNotEmpty;
}

/// Phone and tablet: recent/search list first, then the tree after a selection.
class ProductHierarchyCompactBody extends StatelessWidget {
  const ProductHierarchyCompactBody({
    super.key,
    required this.searchController,
  });

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductHierarchyCubit, ProductHierarchyState>(
      buildWhen: (previous, current) =>
          previous.root != current.root ||
          previous.selectedEpc != current.selectedEpc ||
          previous.selectedJourney != current.selectedJourney ||
          previous.isResolvingRoot != current.isResolvingRoot ||
          previous.isLoadingDetails != current.isLoadingDetails ||
          previous.isClimbing != current.isClimbing ||
          previous.hierarchyError != current.hierarchyError ||
          previous.detailsError != current.detailsError,
      builder: (context, state) {
        if (productHierarchyShowsCompactDetail(state)) {
          return _CompactHierarchyDetail(state: state);
        }
        return ProductHierarchyLeftPanel(searchController: searchController);
      },
    );
  }
}

class _CompactHierarchyDetail extends StatelessWidget {
  const _CompactHierarchyDetail({required this.state});

  final ProductHierarchyState state;

  static const _snapSizes = [0.28, 0.55, 0.90];

  @override
  Widget build(BuildContext context) {
    final root = state.root;
    final journey = state.selectedJourney;
    final loadingSheet =
        root == null &&
        (state.isResolvingRoot ||
            state.isLoadingDetails ||
            state.isClimbing);
    final showDetailsSheet = root != null;

    return Stack(
      children: [
        const Positioned.fill(child: ProductHierarchyTreePanel()),

        if (showDetailsSheet)
          DraggableScrollableSheet(
            initialChildSize: 0.05,
            minChildSize: 0.05,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: _snapSizes,
            builder: (context, scrollController) => JourneyMobileBottomSheet(
              scrollController: scrollController,
              child: _sheetBody(root!, journey),
            ),
          ),
      ],
    );
  }

  Widget _sheetBody(HierarchyTreeNodeState root, ProductJourney? journey) {
    if (state.isLoadingDetails && journey == null) {
      return const ProductHierarchySidebarSkeleton();
    }
    if (journey != null) {
      return ProductHierarchySidebarContent(
        root: root,
        selectedEpc: state.selectedEpc ?? root.node.epc,
        journey: journey,
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
