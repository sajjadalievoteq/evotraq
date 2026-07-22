import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_left_panel.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_tree_panel.dart';





class ProductHierarchyStackedBody extends StatelessWidget {
  const ProductHierarchyStackedBody({
    super.key,
    required this.searchController,
  });

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ProductHierarchyLeftPanel(
            searchController: searchController,
          ),
        ),
        const Divider(height: 1),
        const Expanded(child: ProductHierarchyTreePanel()),
      ],
    );
  }
}
