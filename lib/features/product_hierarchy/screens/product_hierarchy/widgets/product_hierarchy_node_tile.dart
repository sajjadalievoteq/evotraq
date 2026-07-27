import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class ProductHierarchyNodeTile extends StatelessWidget {
  const ProductHierarchyNodeTile({
    super.key,
    required this.nodeState,
    this.isHighlighted = false,
    this.isFlashing = false,
    this.isSearchMatch = false,
    this.isGroupHeader = false,
    this.showBorder = true,
    this.canClimb = false,
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
    if (nodeState.node.hasChildren) {
      return _ExpandableNodeTile(
        nodeState: nodeState,
        isHighlighted: isHighlighted,
        isFlashing: isFlashing,
        isSearchMatch: isSearchMatch,
        isGroupHeader: isGroupHeader,
        showBorder: showBorder,
        canClimb: canClimb,
        onSelect: onSelect,
        onExpand: onExpand,
        onCollapse: onCollapse,
        onClimb: onClimb,
      );
    }
    return _LeafNodeTile(
      nodeState: nodeState,
      isHighlighted: isHighlighted,
      isFlashing: isFlashing,
      isSearchMatch: isSearchMatch,
      canClimb: canClimb,
      onSelect: onSelect,
      onClimb: onClimb,
    );
  }
}

class _ExpandableNodeTile extends StatelessWidget {
  const _ExpandableNodeTile({
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
                  _LeadingChevron(
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
                    _ChildCountBadge(
                      count: node.childCount!,
                      onPrimary: isSearchMatch,
                    ),
                  ],
                  if (canClimb)
                    _ClimbButton(
                      onPressed: () => onClimb?.call(nodeState),
                      iconColor: isSearchMatch ? onPrimary : c.primary,
                    ),
                  _CopyButton(
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

class _LeafNodeTile extends StatelessWidget {
  const _LeafNodeTile({
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
                        color: c.primary
                            .withValues(alpha: isFlashing ? 0.65 : 0.3),
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
                _ClimbButton(
                  onPressed: () => onClimb?.call(nodeState),
                  iconColor: isSearchMatch ? onPrimary : c.primary,
                ),
              _CopyButton(
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

class _ClimbButton extends StatelessWidget {
  const _ClimbButton({
    required this.onPressed,
    required this.iconColor,
  });

  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: TraqIcon(AppAssets.iconChevronU, size: 18, color: iconColor),
      tooltip: 'Show parent',
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onPressed,
    );
  }
}

class _LeadingChevron extends StatelessWidget {
  const _LeadingChevron({
    required this.isExpanded,
    required this.isLoading,
    required this.color,
  });

  final bool isExpanded;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.all(3),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          : AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: TraqDuration.normal,
              curve: TraqDuration.ease,
              child: TraqIcon(
                AppAssets.iconChevronR,
                size: 18,
                color: color,
              ),
            ),
    );
  }
}

class _ChildCountBadge extends StatelessWidget {
  const _ChildCountBadge({
    required this.count,
    this.onPrimary = false,
  });

  final int count;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: onPrimary
            ? c.onPrimary.withValues(alpha: 0.2)
            : c.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: onPrimary
              ? c.onPrimary.withValues(alpha: 0.35)
              : c.border,
        ),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: onPrimary ? c.onPrimary : c.textPrimary,
        ),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({
    required this.epc,
    required this.iconColor,
  });

  final String epc;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: TraqIcon(AppAssets.iconCopy, size: 16, color: iconColor),
      tooltip: 'Copy EPC',
      visualDensity: VisualDensity.compact,
      onPressed: () {
        Clipboard.setData(ClipboardData(text: epc));
        context.showSuccess(
          'EPC copied',
          duration: const Duration(seconds: 1),
        );
      },
    );
  }
}
