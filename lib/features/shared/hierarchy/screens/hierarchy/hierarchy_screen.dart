import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_summary.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/cubit/hierarchy_cubit.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/widgets/hierarchy_node_tile.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

sealed class _HierarchyItem {
  const _HierarchyItem();
}

class _NodeItem extends _HierarchyItem {
  const _NodeItem(this.nodeState, this.depth);
  final HierarchyTreeNodeState nodeState;
  final int depth;
}

class _SentinelItem extends _HierarchyItem {
  const _SentinelItem(this.parent, this.depth);
  final HierarchyTreeNodeState parent;
  final int depth;
}

List<_HierarchyItem> _flatten(HierarchyTreeNodeState node, int depth) {
  final items = <_HierarchyItem>[_NodeItem(node, depth)];
  if (node.isExpanded) {
    for (final child in node.loadedChildren) {
      items.addAll(_flatten(child, depth + 1));
    }
    if (node.hasMore) {
      items.add(_SentinelItem(node, depth + 1));
    }
  }
  return items;
}

class HierarchyScreen extends StatelessWidget {
  const HierarchyScreen({
    super.key,
    required this.rootEpc,
    required this.title,
  });

  final String rootEpc;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HierarchyCubit()..loadRoot(normalizeHierarchyEpc(rootEpc)),
      child: _HierarchyView(rootEpc: rootEpc, title: title),
    );
  }
}

class _HierarchyView extends StatelessWidget {
  const _HierarchyView({required this.rootEpc, required this.title});

  final String rootEpc;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(context, title: Text(title)),
      drawer: const AppDrawer(),
      body: BlocBuilder<HierarchyCubit, HierarchyState>(
        builder: (context, state) {
          return switch (state) {
            HierarchyLoading() => const Center(
              child: CircularProgressIndicator(),
            ),

            HierarchyResolvingRoot() => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Finding root container…',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            HierarchyError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<HierarchyCubit>().loadRoot(
                      normalizeHierarchyEpc(rootEpc),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

            HierarchyLoaded(:final root, :final summary, :final highlightEpc) =>
              _buildList(context, root, summary, highlightEpc),
          };
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    HierarchyTreeNodeState root,
    HierarchySummary? summary,
    String? highlightEpc,
  ) {
    final items = _flatten(root, 0);
    final cubit = context.read<HierarchyCubit>();
    final hPad = context.padding.top;

    return Column(
      children: [
        if (summary != null)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 0),
            child: _HierarchySummaryBanner(summary: summary),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Column(
                children: [
                  switch (item) {
                    _NodeItem(:final nodeState, :final depth) =>
                      HierarchyNodeTile(
                        key: ValueKey(nodeState.node.epc),
                        nodeState: nodeState,
                        depth: depth,
                        onExpand: cubit.expand,
                        onCollapse: cubit.collapse,
                        isHighlighted: () {
                          final selected = highlightEpc;
                          if (selected == null) return false;
                          return normalizeHierarchyEpc(nodeState.node.epc) ==
                              normalizeHierarchyEpc(selected);
                        }(),
                      ),
                    _SentinelItem(:final parent, :final depth) =>
                      _AutoLoadSentinel(
                        key: ValueKey('sentinel_${parent.node.epc}'),
                        depth: depth,
                        isLoading: parent.isLoading,
                        onVisible: () => cubit.loadMoreChildren(parent),
                      ),
                  },
                  if (index == items.length - 1)
                    SizedBox(height: context.padding.top),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HierarchySummaryBanner extends StatelessWidget {
  const _HierarchySummaryBanner({required this.summary});

  final HierarchySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = summary.totalItemCount;
    final direct = summary.directChildCount;

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            TraqIcon(
              NavIcons.aggregationEvents,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: theme.textTheme.bodySmall,
                  children: [
                    TextSpan(
                      text: '$total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' item${total == 1 ? '' : 's'} total'),
                    const TextSpan(text: '  ·  '),
                    TextSpan(
                      text: '$direct',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ' direct'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoLoadSentinel extends StatefulWidget {
  const _AutoLoadSentinel({
    super.key,
    required this.depth,
    required this.isLoading,
    required this.onVisible,
  });
  final int depth;
  final bool isLoading;
  final VoidCallback onVisible;

  @override
  State<_AutoLoadSentinel> createState() => _AutoLoadSentinelState();
}

class _AutoLoadSentinelState extends State<_AutoLoadSentinel> {
  @override
  void initState() {
    super.initState();
    if (!widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onVisible();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.depth * HierarchyNodeTile.indentWidth + 32,
        top: 4,
        bottom: 4,
      ),
      child: widget.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const SizedBox.shrink(),
    );
  }
}
