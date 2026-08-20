import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_compact_detail_content.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_tree_panel.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey_dashboard/widgets/journey_mobile_bottom_sheet.dart';

class ProductHierarchyCompactDetail extends StatelessWidget {
  const ProductHierarchyCompactDetail({super.key, required this.state});

  final ProductHierarchyState state;

  static const _snapSizes = [0.28, 0.55, 0.90];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ProductHierarchyTreePanel()),
        if (state.root != null)
          DraggableScrollableSheet(
            initialChildSize: 0.05,
            minChildSize: 0.05,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: _snapSizes,
            builder: (context, scrollController) => JourneyMobileBottomSheet(
              scrollController: scrollController,
              child: ProductHierarchyCompactDetailContent(
                state: state,
                root: state.root!,
              ),
            ),
          ),
      ],
    );
  }
}
