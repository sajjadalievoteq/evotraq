import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_climb_button.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_copy_epc_button.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class ProductHierarchyLeafNodeTile extends StatelessWidget {
  const ProductHierarchyLeafNodeTile({
    super.key,
    required this.nodeState,
    required this.isHighlighted,
    required this.isFlashing,
    required this.isSearchMatch,
    required this.canClimb,
    this.onSelect,
    this.onClimb,
  });

  final HierarchyTreeNodeState nodeState;
  final bool isHighlighted;
  final bool isFlashing;
  final bool isSearchMatch;
  final bool canClimb;
  final ValueChanged<HierarchyTreeNodeState>? onSelect;
  final ValueChanged<HierarchyTreeNodeState>? onClimb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final node = nodeState.node;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final onPrimary = c.onPrimary;
    final softHighlight = !isSearchMatch && (isHighlighted || isFlashing);

    final Color bg;
    if (isSearchMatch) {
      bg = c.primary;
    } else if (softHighlight) {
      bg = c.primary.withValues(alpha: isFlashing ? 0.18 : 0.1);
    } else {
      bg = Colors.transparent;
    }

    final fg = isSearchMatch ? onPrimary : c.textPrimary;
    final mutedFg = isSearchMatch
        ? onPrimary.withValues(alpha: 0.85)
        : c.textMuted;
    final iconFg = isSearchMatch
        ? onPrimary
        : (softHighlight ? c.primary : c.textMuted);

    return Material(
      color: bg,
      borderRadius: TraqRadius.card,
      child: InkWell(
        borderRadius: TraqRadius.card,
        hoverColor: isSearchMatch
            ? onPrimary.withValues(alpha: 0.08)
            : c.primary.withValues(alpha: 0.04),
        onTap: () => onSelect?.call(nodeState),
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : TraqDuration.normal,
          curve: TraqDuration.ease,
          decoration: BoxDecoration(
            borderRadius: TraqRadius.card,
            border: isSearchMatch
                ? Border.all(color: c.primary)
                : softHighlight
                ? Border.all(
                    color: c.primary.withValues(alpha: isFlashing ? 0.65 : 0.3),
                    width: isFlashing ? 2 : 1,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: TraqSpacing.sm,
            vertical: TraqSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                node.isSgtin ? 'Sgtin' : 'SSCC',
                style: theme.textTheme.bodyMedium?.copyWith(color: fg),
              ),
              const SizedBox(width: TraqSpacing.sm),
              TraqIcon(
                node.isSgtin ? NavIcons.sgtin : NavIcons.sscc,
                size: 18,
                color: iconFg,
              ),
              const SizedBox(width: TraqSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      node.epc,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: (isSearchMatch || softHighlight)
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: fg,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_statusLine(node.status, node.disposition) != null)
                      Text(
                        _statusLine(node.status, node.disposition)!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: mutedFg,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
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
    );
  }

  /// Renders `status:<status>`; appends the disposition only when it carries
  /// information different from the status (avoids "ACTIVE • active").
  String? _statusLine(String? statusRaw, String? dispositionRaw) {
    final status = (statusRaw ?? '').trim();
    final disp = (dispositionRaw ?? '').trim();
    if (status.isEmpty && disp.isEmpty) return null;
    if (status.isEmpty) return _shortDisposition(disp);
    final line = 'status:${status.toLowerCase()}';
    if (disp.isNotEmpty && disp.toLowerCase() != status.toLowerCase()) {
      return '$line • ${_shortDisposition(disp)}';
    }
    return line;
  }

  String _shortDisposition(String raw) {
    if (raw.length <= 28) return raw;
    return '${raw.substring(0, 25)}…';
  }
}
