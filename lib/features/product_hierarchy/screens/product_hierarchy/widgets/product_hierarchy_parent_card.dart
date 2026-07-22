import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_chrome.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_display_utils.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';


class ProductHierarchyParentCard extends StatelessWidget {
  const ProductHierarchyParentCard({
    super.key,
    required this.parent,
    required this.info,
    required this.isRoot,
  });

  final HierarchyTreeNodeState? parent;
  final ProductInfo? info;
  final bool isRoot;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    final parentSscc = info?.parentSSCC;
    final parentNode = parent?.node;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProductHierarchySectionLabel('Parent Relationship'),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(TraqSpacing.lg),
            child: Row(
              children: [
                TraqIcon(
                  isRoot && parentSscc == null && parentNode == null
                      ? NavIcons.productHierarchy
                      : NavIcons.sscc,
                  size: 18,
                  color: c.primary,
                ),
                const SizedBox(width: TraqSpacing.sm),
                Expanded(
                  child: isRoot && parentSscc == null && parentNode == null
                      ? Text(
                          'This is the Root Container',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Parent Container',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (parentNode != null) ...[
                              Text(
                                parentNode.type,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: c.primary,
                                ),
                              ),
                              Text(
                                ProductHierarchyDisplayUtils.shortIdentifier(
                                  node: parentNode,
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ] else if (parentSscc != null)
                              Text(
                                parentSscc,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
