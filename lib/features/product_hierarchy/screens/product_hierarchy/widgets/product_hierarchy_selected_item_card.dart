import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_chrome.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_display_utils.dart';


class ProductHierarchySelectedItemCard extends StatelessWidget {
  const ProductHierarchySelectedItemCard({
    super.key,
    required this.node,
    required this.journey,
    required this.info,
  });

  final HierarchyNode node;
  final ProductJourney journey;
  final ProductInfo? info;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    final title = ProductHierarchyDisplayUtils.packagingTitle(
      node: node,
      info: info,
    );
    final shortId = ProductHierarchyDisplayUtils.shortIdentifier(
      node: node,
      info: info,
      journeyIdentifier: journey.identifier,
    );
    final level = ProductHierarchyDisplayUtils.packagingLevelLabel(
      node: node,
      info: info,
    );
    final isSscc = node.isSscc || info?.isSscc == true;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  isSscc ? NavIcons.sscc : NavIcons.sgtin,
                  size: 22,
                  color: c.primary,
                ),
                const Spacer(),
                ProductHierarchyTypeBadge(node.type),
              ],
            ),
            const SizedBox(height: TraqSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: TraqSpacing.xs),
            SelectableText(
              shortId,
              style: theme.textTheme.titleSmall?.copyWith(
                color: c.textSecondary,
                fontFamily: 'monospace',
                letterSpacing: 0.2,
              ),
            ),
            if (level != null) ...[
              const SizedBox(height: TraqSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: c.surfaceMuted,
                  borderRadius: TraqRadius.chip,
                ),
                child: Text(
                  level,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
