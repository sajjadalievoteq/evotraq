import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_display_utils.dart';
import 'package:traqtrace_app/features/product_hierarchy/widgets/product_hierarchy_type_badge.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class ProductHierarchyPackagingPathRow extends StatelessWidget {
  const ProductHierarchyPackagingPathRow({
    super.key,
    required this.item,
    required this.selectedEpc,
  });

  final HierarchyTreeNodeState item;
  final String selectedEpc;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    final n = item.node;
    final selected = n.epc == selectedEpc;
    final label = ProductHierarchyDisplayUtils.packagingTitle(node: n);

    return AnimatedContainer(
      duration: TraqDuration.normal,
      curve: TraqDuration.ease,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.md,
        vertical: TraqSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: selected
            ? c.primary.withValues(alpha: 0.1)
            : c.surfaceMuted.withValues(alpha: 0.45),
        borderRadius: TraqRadius.card,
        border: Border.all(
          color: selected
              ? c.primary.withValues(alpha: 0.45)
              : c.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          TraqIcon(
            n.isSscc ? NavIcons.sscc : NavIcons.sgtin,
            size: 16,
            color: selected ? c.primary : c.textMuted,
          ),
          const SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? c.primary : c.textSecondary,
              ),
            ),
          ),
          ProductHierarchyTypeBadge(n.type),
        ],
      ),
    );
  }
}
