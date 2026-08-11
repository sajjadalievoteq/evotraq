import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_summary.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/cubit/hierarchy_cubit.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_list_item.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/utils/hierarchy_tree_flatten.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/widgets/hierarchy_auto_load_sentinel.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/widgets/hierarchy_node_tile.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/widgets/hierarchy_summary_banner.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';

class HierarchyList extends StatelessWidget {
  const HierarchyList({
    super.key,
    required this.root,
    required this.summary,
    required this.highlightEpc,
  });

  final HierarchyTreeNodeState root;
  final HierarchySummary? summary;
  final String? highlightEpc;

  @override
  Widget build(BuildContext context) {
    final items = flattenHierarchyTree(root, 0);
    final cubit = context.read<HierarchyCubit>();
    final horizontalPadding = context.padding.top;

    return Column(
      children: [
        if (summary != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              horizontalPadding,
              horizontalPadding,
              0,
            ),
            child: HierarchySummaryBanner(summary: summary!),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              horizontalPadding,
              horizontalPadding,
              0,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Column(
                children: [
                  switch (item) {
                    HierarchyNodeListItem(:final nodeState, :final depth) =>
                      HierarchyNodeTile(
                        key: ValueKey(nodeState.node.epc),
                        nodeState: nodeState,
                        depth: depth,
                        onExpand: cubit.expand,
                        onCollapse: cubit.collapse,
                        isHighlighted:
                            highlightEpc != null &&
                            normalizeHierarchyEpc(nodeState.node.epc) ==
                                normalizeHierarchyEpc(highlightEpc!),
                      ),
                    HierarchySentinelListItem(:final parent, :final depth) =>
                      HierarchyAutoLoadSentinel(
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
