import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_left_panel.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_stacked_body.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_tree_panel.dart';

class ProductHierarchyScreen extends StatefulWidget {
  const ProductHierarchyScreen({super.key, this.initialEpc});

  final String? initialEpc;

  @override
  State<ProductHierarchyScreen> createState() => _ProductHierarchyScreenState();
}

class _ProductHierarchyScreenState extends State<ProductHierarchyScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final epc = widget.initialEpc;
    if (epc != null && epc.isNotEmpty) {
      _searchController.text = epc;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = ProductHierarchyCubit();
        final epc = widget.initialEpc;
        if (epc != null && epc.isNotEmpty) {
          cubit.openHierarchy(epc);
        }
        return cubit;
      },
      child: Scaffold(
        appBar: TraqAppBar(context, title: const Text('Product Hierarchy')),
        drawer: const AppDrawer(),
        body: SplitOrListIndexedStack(
          split: MasterDetailSplitLayout(
            narrowListFlex: 22,
            wideListFlex: 30,
            list: ProductHierarchyLeftPanel(
              searchController: _searchController,
            ),
            detail: const ProductHierarchyTreePanel(),
          ),
          fallback: ProductHierarchyStackedBody(
            searchController: _searchController,
          ),
        ),
      ),
    );
  }
}
