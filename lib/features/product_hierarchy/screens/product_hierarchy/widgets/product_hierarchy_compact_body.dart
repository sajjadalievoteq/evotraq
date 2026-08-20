import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_compact_detail.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_left_panel.dart';

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
          return ProductHierarchyCompactDetail(state: state);
        }
        return ProductHierarchyLeftPanel(searchController: searchController);
      },
    );
  }
}
