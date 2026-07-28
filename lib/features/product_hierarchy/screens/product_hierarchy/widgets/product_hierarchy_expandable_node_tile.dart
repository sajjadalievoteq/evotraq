import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_node_tile_actions.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class ProductHierarchyExpandableNodeTile extends StatelessWidget {
  const ProductHierarchyExpandableNodeTile({
    super.key,
    required this.nodeState,
    required this.isHighlighted,
    required this.isFlashing,
    required this.isSearchMatch,
    required this.isGroupHeader,
    required this.showBorder,
    required this.canClimb,
    this.onSelect,
    this.onExpand,
    this.onCollapse,
    this.onClimb,
  });

  final HierarchyTreeNodeState nodeState;
  final bool isHighlighted;
  final bool isFlashing;
  final bool isSearchMatch;
  final bool isGroupHeader;
  final bool showBorder;
  final bool canClimb;
  final ValueChanged<HierarchyTreeNodeState>? onSelect;
  final ValueChanged<HierarchyTreeNodeState>? onExpand;
  final ValueChanged<HierarchyTreeNodeState>? onCollapse;
  final ValueChanged<HierarchyTreeNodeState>? onClimb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final node = nodeState.node;
    final radius = isGroupHeader ? BorderRadius.zero : TraqRadius.card;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final onPrimary = c.onPrimary;
    final softHighlight = !isSearchMatch && (isHighlighted || isFlashing);

    final Color bg;
    if (isSearchMatch) {
      bg = c.primary;
    } else if (softHighlight) {
      bg = c.primary.withValues(alpha: isFlashing ? 0.22 : 0.14);
    } else {
      bg = c.surface;
    }

    final Color? borderColor;
    if (!showBorder) {
      borderColor = null;
    } else if (isSearchMatch) {
      borderColor = c.primary;
    } else if (softHighlight) {
      borderColor = c.primary.withValues(alpha: isFlashing ? 0.7 : 0.4);
    } else {
      borderColor = c.border;
    }

    final fg = isSearchMatch ? onPrimary : c.textPrimary;
    final iconFg = isSearchMatch
        ? onPrimary
        : (softHighlight ? c.primary : c.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bg,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            hoverColor: isSearchMatch
                ? onPrimary.withValues(alpha: 0.08)
                : c.primary.withValues(alpha: 0.06),
            onTap: () {
              onSelect?.call(nodeState);
              if (nodeState.isExpanded) {
                onCollapse?.call(nodeState);
              } else {
                onExpand?.call(nodeState);
              }
            },
            child: AnimatedContainer(
              duration: reduceMotion ? Duration.zero : TraqDuration.normal,
              curve: TraqDuration.ease,
              decoration: BoxDecoration(
                borderRadius: radius,
                border: borderColor != null
                    ? Border.all(
                        color: borderColor,
                        width: !isSearchMatch && isFlashing ? 2 : 1,
                      )
                    : null,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: TraqSpacing.sm,
                vertical: TraqSpacing.sm + 2,
              ),
              child: Row(
                children: [
                  ProductHierarchyLeadingChevron(
                    isExpanded: nodeState.isExpanded,
                    isLoading: nodeState.isLoading,
                    color: isSearchMatch ? onPrimary : c.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    node.isSgtin ? 'Sgtin' : 'SSCC',
                    style: theme.textTheme.bodyMedium?.copyWith(color: fg),
                  ),
                  const SizedBox(width: 5),
                  TraqIcon(
                    node.isSscc
                        ? NavIcons.sscc
                        : NavIcons.aggregationHierarchy,
                    size: 20,
                    color: iconFg,
                  ),
                  const SizedBox(width: TraqSpacing.sm),
                  Expanded(
                    child: Text(
                      node.epc,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (node.childCount != null) ...[
                    const SizedBox(width: TraqSpacing.sm),
                    ProductHierarchyChildCountBadge(
                      count: node.childCount!,
                      onPrimary: isSearchMatch,
                    ),
                  ],
                  if (canClimb)
                    ProductHierarchyClimbButton(
                      onPressed: () => onClimb?.call(nodeState),
                      iconColor: isSearchMatch ? onPrimary : c.primary,
                    ),
                  ProductHierarchyCopyEpcButton(
                    epc: node.epc,
                    iconColor: isSearchMatch ? onPrimary : c.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (nodeState.error != null)
          Padding(
            padding: const EdgeInsets.only(
              top: TraqSpacing.xs,
              left: TraqSpacing.sm,
            ),
            child: Text(
              nodeState.error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
