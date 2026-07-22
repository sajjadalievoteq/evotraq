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
    this.isGroupHeader = false,
    this.showBorder = true,
    this.onSelect,
    this.onExpand,
    this.onCollapse,
  });

  final HierarchyTreeNodeState nodeState;
  final bool isHighlighted;
  
  final bool isGroupHeader;
  
  final bool showBorder;
  final ValueChanged<HierarchyTreeNodeState>? onSelect;
  final ValueChanged<HierarchyTreeNodeState>? onExpand;
  final ValueChanged<HierarchyTreeNodeState>? onCollapse;

  @override
  Widget build(BuildContext context) {
    if (nodeState.node.hasChildren) {
      return _ExpandableNodeTile(
        nodeState: nodeState,
        isHighlighted: isHighlighted,
        isGroupHeader: isGroupHeader,
        showBorder: showBorder,
        onSelect: onSelect,
        onExpand: onExpand,
        onCollapse: onCollapse,
      );
    }
    return _LeafNodeTile(
      nodeState: nodeState,
      isHighlighted: isHighlighted,
      onSelect: onSelect,
    );
  }
}

class _ExpandableNodeTile extends StatelessWidget {
  const _ExpandableNodeTile({
    required this.nodeState,
    required this.isHighlighted,
    required this.isGroupHeader,
    required this.showBorder,
    this.onSelect,
    this.onExpand,
    this.onCollapse,
  });

  final HierarchyTreeNodeState nodeState;
  final bool isHighlighted;
  final bool isGroupHeader;
  final bool showBorder;
  final ValueChanged<HierarchyTreeNodeState>? onSelect;
  final ValueChanged<HierarchyTreeNodeState>? onExpand;
  final ValueChanged<HierarchyTreeNodeState>? onCollapse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final node = nodeState.node;
    final radius = isGroupHeader ? BorderRadius.zero : TraqRadius.card;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isHighlighted
              ? c.primary.withValues(alpha: 0.14)
              : c.surface,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            hoverColor: c.primary.withValues(alpha: 0.06),
            onTap: () {
              onSelect?.call(nodeState);
              if (nodeState.isExpanded) {
                onCollapse?.call(nodeState);
              } else {
                onExpand?.call(nodeState);
              }
            },
            child: AnimatedContainer(
              duration: TraqDuration.normal,
              curve: TraqDuration.ease,
              decoration: BoxDecoration(
                borderRadius: radius,
                border: showBorder
                    ? Border.all(
                        color: isHighlighted
                            ? c.primary.withValues(alpha: 0.4)
                            : c.border,
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
                  ),
                  const SizedBox(width: 5),
                  Text(node.isSgtin ? 'Sgtin' : 'SSCC'),
                  const SizedBox(width: 5),
                  TraqIcon(
                    node.isSscc
                        ? NavIcons.sscc
                        : NavIcons.aggregationHierarchy,
                    size: 20,
                    color: isHighlighted ? c.primary : c.textSecondary,
                  ),
                  const SizedBox(width: TraqSpacing.sm),
                  Expanded(
                    child: Text(
                      node.epc,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (node.childCount != null) ...[
                    const SizedBox(width: TraqSpacing.sm),
                    _ChildCountBadge(count: node.childCount!),
                  ],
                  _CopyButton(epc: node.epc),
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
    this.onSelect,
  });

  final HierarchyTreeNodeState nodeState;
  final bool isHighlighted;
  final ValueChanged<HierarchyTreeNodeState>? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final node = nodeState.node;

    return Material(
      color: isHighlighted
          ? c.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: TraqRadius.card,
      child: InkWell(
        borderRadius: TraqRadius.card,
        hoverColor: c.primary.withValues(alpha: 0.04),
        onTap: () => onSelect?.call(nodeState),
        child: AnimatedContainer(
          duration: TraqDuration.normal,
          curve: TraqDuration.ease,
          decoration: BoxDecoration(
            borderRadius: TraqRadius.card,
            border: isHighlighted
                ? Border.all(color: c.primary.withValues(alpha: 0.3))
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: TraqSpacing.sm,
            vertical: TraqSpacing.sm,
          ),
          child: Row(
            children: [
              Text(node.isSgtin ? 'Sgtin' : 'SSCC'),
              const SizedBox(width: TraqSpacing.sm),
              TraqIcon(
                node.isSgtin ? NavIcons.sgtin : NavIcons.sscc,
                size: 18,
                color: isHighlighted ? c.primary : c.textMuted,
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
                        fontWeight: isHighlighted
                            ? FontWeight.w600
                            : FontWeight.w400,
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
              _CopyButton(epc: node.epc),
            ],
          ),
        ),
      ),
    );
  }

  String _shortDisposition(String raw) {
    if (raw.length <= 28) return raw;
    return '${raw.substring(0, 25)}…';
  }
}

class _LeadingChevron extends StatelessWidget {
  const _LeadingChevron({
    required this.isExpanded,
    required this.isLoading,
  });

  final bool isExpanded;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: 22,
      height: 22,
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(3),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : AnimatedRotation(
              
              turns: isExpanded ? 0.25 : 0,
              duration: TraqDuration.normal,
              curve: TraqDuration.ease,
              child: TraqIcon(
                AppAssets.iconChevronR,
                size: 18,
                color: c.textSecondary,
              ),
            ),
    );
  }
}

class _ChildCountBadge extends StatelessWidget {
  const _ChildCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.epc});

  final String epc;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IconButton(
      icon: TraqIcon(AppAssets.iconCopy, size: 16, color: c.textMuted),
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
