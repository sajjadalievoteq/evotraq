import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_chrome.dart';


class ProductHierarchyStatTileData {
  const ProductHierarchyStatTileData({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final String icon;
}



class ProductHierarchyStatsSection extends StatelessWidget {
  const ProductHierarchyStatsSection({
    super.key,
    required this.node,
    required this.info,
    required this.depth,
    required this.loadedStats,
  });

  final HierarchyNode node;
  final ProductInfo? info;
  final int? depth;
  final ({int total, int leaves, int sscc, int sgtin}) loadedStats;

  @override
  Widget build(BuildContext context) {
    final direct = node.childCount ??
        ((info?.childSsccs?.length ?? 0) + (info?.childSgtins?.length ?? 0));
    final totalFromInfo = info?.itemCount;
    final serialized = info?.childSgtins?.length ??
        (loadedStats.sgtin > 0 ? loadedStats.sgtin : null);
    final total = totalFromInfo ??
        (loadedStats.total > 0 ? loadedStats.total : null) ??
        (direct > 0 ? direct : null);

    final tiles = <ProductHierarchyStatTileData>[
      if (total != null && total > 0)
        ProductHierarchyStatTileData(
          label: 'Total Children',
          value: '$total',
          icon: NavIcons.aggregationHierarchy,
        ),
      if (direct > 0)
        ProductHierarchyStatTileData(
          label: 'Direct Children',
          value: '$direct',
          icon: NavIcons.packaging,
        ),
      if (serialized != null && serialized > 0)
        ProductHierarchyStatTileData(
          label: 'Serialized Items',
          value: '$serialized',
          icon: NavIcons.sgtin,
        ),
      if (depth != null)
        ProductHierarchyStatTileData(
          label: 'Depth',
          value: depth == 0 ? 'Root' : '$depth',
          icon: NavIcons.productHierarchy,
        ),
    ];

    if (tiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProductHierarchySectionLabel('Hierarchy Statistics'),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 280 ? 1 : 2;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: TraqSpacing.sm,
              crossAxisSpacing: TraqSpacing.sm,
              childAspectRatio: crossAxisCount == 1 ? 3.2 : 1.55,
              children: [
                for (final t in tiles) ProductHierarchyStatTile(data: t),
              ],
            );
          },
        ),
      ],
    );
  }
}

class ProductHierarchyStatTile extends StatelessWidget {
  const ProductHierarchyStatTile({super.key, required this.data});
  final ProductHierarchyStatTileData data;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TraqSpacing.md,
          vertical: TraqSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TraqIcon(data.icon, size: 16, color: c.primary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  data.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
