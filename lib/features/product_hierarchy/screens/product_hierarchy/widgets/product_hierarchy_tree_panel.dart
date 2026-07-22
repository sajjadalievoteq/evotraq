import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/utils/product_hierarchy_tree_flatten.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_flat_row.dart';





class ProductHierarchyTreePanel extends StatelessWidget {
  const ProductHierarchyTreePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductHierarchyCubit, ProductHierarchyState>(
      builder: (context, state) {
        final cubit = context.read<ProductHierarchyCubit>();
        if (state.isResolvingRoot) {
          return const Center(child: CircularProgressIndicator());
        }
        if ((state.hierarchyError ?? '').isNotEmpty) {
          return AppEmptyState(
            iconAsset: NavIcons.aggregationHierarchy,
            title: 'Unable to load hierarchy',
            subtitle: state.hierarchyError!,
          );
        }

        final root = state.root;
        if (root == null) {
          return const AppEmptyState(
            iconAsset: NavIcons.aggregationHierarchy,
            title: 'No hierarchy to display',
            subtitle: 'Search an SSCC or SGTIN to render its packaging tree.',
          );
        }

        
        final items = flattenProductHierarchy(root);

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            context.padding.top,
            context.padding.top,
            context.padding.top,
            TraqSpacing.lg,
          ),
          itemCount: items.length,
          
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemBuilder: (context, index) {
            return ProductHierarchyFlatRow(
              item: items[index],
              selectedEpc: state.selectedEpc,
              onSelect: (n) => cubit.selectEpc(n.node.epc),
              onExpand: cubit.expand,
              onCollapse: cubit.collapse,
              onLoadMore: cubit.loadMoreChildren,
            );
          },
        );
      },
    );
  }
}
