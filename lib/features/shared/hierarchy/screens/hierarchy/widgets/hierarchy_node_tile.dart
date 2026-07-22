import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class HierarchyNodeTile extends StatelessWidget {
  const HierarchyNodeTile({
    super.key,
    required this.nodeState,
    required this.depth,
    this.isHighlighted = false,
    this.onSelect,
    this.onExpand,
    this.onCollapse,
  });

  final HierarchyTreeNodeState nodeState;
  final int depth;
  final bool isHighlighted;
  final ValueChanged<HierarchyTreeNodeState>? onSelect;
  final ValueChanged<HierarchyTreeNodeState>? onExpand;
  final ValueChanged<HierarchyTreeNodeState>? onCollapse;

  static const double indentWidth = 28.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final node = nodeState.node;

    final isSSCC = node.isSscc;
    final chipColor = isSSCC
        ? c.primary.withValues(alpha: 0.12)
        : c.secondary.withValues(alpha: 0.12);
    final chipLabelColor = isSSCC ? c.primary : c.secondary;

    final rowColor = isHighlighted
        ? c.primary.withValues(alpha: 0.12)
        : Colors.transparent;

    final canExpand = node.hasChildren;
    final guideLeft = depth * indentWidth + 18;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (depth > 0)
          Padding(
            padding: EdgeInsets.only(left: guideLeft),
            child: Container(
              width: 1,
              height: 6,
              color: c.border.withValues(alpha: 0.7),
            ),
          ),
        Material(
          color: rowColor,
          borderRadius: TraqRadius.card,
          child: InkWell(
            borderRadius: TraqRadius.card,
            hoverColor: c.primary.withValues(alpha: 0.06),
            onTap: () {
              onSelect?.call(nodeState);
              if (canExpand) {
                if (nodeState.isExpanded) {
                  onCollapse?.call(nodeState);
                } else {
                  onExpand?.call(nodeState);
                }
              }
            },
            child: AnimatedContainer(
              duration: TraqDuration.normal,
              curve: TraqDuration.ease,
              decoration: BoxDecoration(
                borderRadius: TraqRadius.card,
                border: isHighlighted
                    ? Border.all(color: c.primary.withValues(alpha: 0.35))
                    : null,
              ),
              padding: EdgeInsets.only(
                left: depth * indentWidth + 8,
                right: 8,
                top: 8,
                bottom: 8,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: canExpand
                        ? nodeState.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(3),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : AnimatedRotation(
                                turns: nodeState.isExpanded ? 0.25 : 0,
                                duration: TraqDuration.normal,
                                curve: TraqDuration.ease,
                                child: TraqIcon(
                                  AppAssets.iconChevronR,
                                  size: 18,
                                  color: c.textSecondary,
                                ),
                              )
                        : Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.borderStrong,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  TraqIcon(
                    isSSCC ? NavIcons.sscc : NavIcons.sgtin,
                    size: 18,
                    color: isHighlighted ? c.primary : c.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: TraqRadius.chip,
                      border: Border.all(
                        color: chipLabelColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      node.type,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: chipLabelColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (node.childCount != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${node.childCount}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          node.epc,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isHighlighted
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: c.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((node.status ?? '').isNotEmpty ||
                            (node.disposition ?? '').isNotEmpty)
                          Text(
                            [
                              if ((node.status ?? '').isNotEmpty) node.status!,
                              if ((node.disposition ?? '').isNotEmpty)
                                _shortDisposition(node.disposition!),
                            ].join(' • '),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: c.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: TraqIcon(
                      AppAssets.iconCopy,
                      size: 16,
                      color: c.textMuted,
                    ),
                    tooltip: 'Copy EPC',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: node.epc));
                      context.showSuccess(
                        'EPC copied',
                        duration: const Duration(seconds: 1),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (nodeState.error != null)
          Padding(
            padding: EdgeInsets.only(left: depth * indentWidth + 32),
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

  String _shortDisposition(String raw) {
    if (raw.length <= 28) return raw;
    return '${raw.substring(0, 25)}…';
  }
}
