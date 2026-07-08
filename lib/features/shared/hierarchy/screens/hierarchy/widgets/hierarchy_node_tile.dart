import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/cubit/hierarchy_cubit.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class HierarchyNodeTile extends StatelessWidget {
  const HierarchyNodeTile({
    super.key,
    required this.nodeState,
    required this.depth,
    this.isHighlighted = false,
  });

  final HierarchyTreeNodeState nodeState;
  final int depth;
  final bool isHighlighted;

  static const double indentWidth = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<HierarchyCubit>();
    final node = nodeState.node;

    final isSSCC = node.isSscc;
    final chipColor = isSSCC
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.secondaryContainer;
    final chipLabelColor = isSSCC
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSecondaryContainer;

    final rowColor = isHighlighted
        ? theme.colorScheme.tertiaryContainer.withOpacity(0.35)
        : Colors.transparent;

    final canExpand = node.hasChildren;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: rowColor,
          child: InkWell(
            onTap: canExpand
                ? () => nodeState.isExpanded
                      ? cubit.collapse(nodeState)
                      : cubit.expand(nodeState)
                : null,
            child: Padding(
              padding: EdgeInsets.only(
                left: depth * indentWidth + 8,
                right: 8,
                top: 6,
                bottom: 6,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: canExpand
                        ? nodeState.isLoading
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : TraqIcon(
                                nodeState.isExpanded
                                    ? AppAssets.iconChevronD
                                    : AppAssets.iconChevronR,
                                size: 20,
                              )
                        : null,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      node.type,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: chipLabelColor,
                      ),
                    ),
                  ),
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
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isHighlighted)
                          Text(
                            '← selected',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const TraqIcon(AppAssets.iconCopy, size: 16),
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
}
