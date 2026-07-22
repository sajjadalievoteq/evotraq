import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_chrome.dart';


class ProductHierarchyChildrenSummaryCard extends StatelessWidget {
  const ProductHierarchyChildrenSummaryCard({
    super.key,
    required this.node,
    required this.info,
    required this.loadedStats,
  });

  final HierarchyNode node;
  final ProductInfo? info;
  final ({int total, int leaves, int sscc, int sgtin}) loadedStats;

  @override
  Widget build(BuildContext context) {
    final ssccCount = info?.childSsccs?.length ??
        (loadedStats.sscc > 0 ? loadedStats.sscc : null);
    final sgtinCount = info?.childSgtins?.length ??
        (loadedStats.sgtin > 0 ? loadedStats.sgtin : null);
    final direct = node.childCount;

    if ((ssccCount == null || ssccCount == 0) &&
        (sgtinCount == null || sgtinCount == 0) &&
        (direct == null || direct == 0)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProductHierarchySectionLabel('Children'),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(TraqSpacing.lg),
            child: Column(
              children: [
                if (ssccCount != null && ssccCount > 0)
                  ProductHierarchyChildCountRow(
                    icon: NavIcons.sscc,
                    label: ssccCount == 1 ? 'Container' : 'Containers',
                    count: ssccCount,
                  ),
                if (sgtinCount != null && sgtinCount > 0)
                  ProductHierarchyChildCountRow(
                    icon: NavIcons.sgtin,
                    label: sgtinCount == 1
                        ? 'Serialized Product'
                        : 'Serialized Products',
                    count: sgtinCount,
                  ),
                if ((ssccCount == null || ssccCount == 0) &&
                    (sgtinCount == null || sgtinCount == 0) &&
                    direct != null &&
                    direct > 0)
                  ProductHierarchyChildCountRow(
                    icon: NavIcons.packaging,
                    label: direct == 1 ? 'Child' : 'Children',
                    count: direct,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProductHierarchyChildCountRow extends StatelessWidget {
  const ProductHierarchyChildCountRow({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
  });

  final String icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
      child: Row(
        children: [
          TraqIcon(icon, size: 16, color: c.primary),
          const SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ),
          Text(
            '$count',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
