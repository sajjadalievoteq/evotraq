import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_packaging_path_row.dart';
import 'package:traqtrace_app/features/product_hierarchy/widgets/product_hierarchy_section_label.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class ProductHierarchyPackagingPathCard extends StatelessWidget {
  const ProductHierarchyPackagingPathCard({
    super.key,
    required this.path,
    required this.selectedEpc,
  });

  final List<HierarchyTreeNodeState> path;
  final String selectedEpc;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProductHierarchySectionLabel('Packaging Path'),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(TraqSpacing.lg),
            child: Column(
              children: [
                for (var i = 0; i < path.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TraqIcon(
                        AppAssets.iconChevronD,
                        size: 14,
                        color: c.textMuted,
                      ),
                    ),
                  ProductHierarchyPackagingPathRow(
                    item: path[i],
                    selectedEpc: selectedEpc,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
