import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/utils/product_hierarchy_tree_flatten.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_group_chrome.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_node_tile.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';


class ProductHierarchyFlatRow extends StatelessWidget {
  const ProductHierarchyFlatRow({
    super.key,
    required this.item,
    required this.selectedEpc,
    required this.onSelect,
    required this.onExpand,
    required this.onCollapse,
    required this.onLoadMore,
  });

  final ProductHierarchyFlatItem item;
  final String? selectedEpc;
  final ValueChanged<HierarchyTreeNodeState> onSelect;
  final ValueChanged<HierarchyTreeNodeState> onExpand;
  final ValueChanged<HierarchyTreeNodeState> onCollapse;
  final ValueChanged<HierarchyTreeNodeState> onLoadMore;

  bool _selected(HierarchyTreeNodeState n) {
    if (selectedEpc == null) return false;
    return normalizeHierarchyEpc(n.node.epc) ==
        normalizeHierarchyEpc(selectedEpc!);
  }

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      ProductHierarchyNodeItem(
        :final nodeState,
        :final depth,
        :final inGroupBody,
        :final isFirstInGroupBody,
        :final isLastInGroupBody,
        :final isExpandedHeader,
      ) =>
        ProductHierarchyGroupChrome(
          depth: depth,
          inGroupBody: inGroupBody,
          isExpandedHeader: isExpandedHeader,
          isFirst: isFirstInGroupBody,
          isLast: isLastInGroupBody && !isExpandedHeader,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: (!inGroupBody && !isExpandedHeader) ||
                      (isLastInGroupBody && !isExpandedHeader)
                  ? TraqSpacing.sm
                  : 0,
            ),
            child: ProductHierarchyNodeTile(
              key: ValueKey(nodeState.node.epc),
              nodeState: nodeState,
              isHighlighted: _selected(nodeState),
              isGroupHeader: isExpandedHeader,
              showBorder: !isExpandedHeader && !inGroupBody,
              onSelect: onSelect,
              onExpand: onExpand,
              onCollapse: onCollapse,
            ),
          ),
        ),
      ProductHierarchySentinelItem(
        :final parent,
        :final depth,
        :final inGroupBody,
        :final isFirstInGroupBody,
        :final isLastInGroupBody,
      ) =>
        ProductHierarchyGroupChrome(
          depth: depth,
          inGroupBody: inGroupBody,
          isExpandedHeader: false,
          isFirst: isFirstInGroupBody,
          isLast: isLastInGroupBody,
          child: ProductHierarchyLoadMoreSentinel(
            key: ValueKey('${parent.node.epc}-more-${parent.loadedPage}'),
            isLoading: parent.isLoading,
            onVisible: () => onLoadMore(parent),
          ),
        ),
    };
  }
}



class ProductHierarchyLoadMoreSentinel extends StatefulWidget {
  const ProductHierarchyLoadMoreSentinel({
    super.key,
    required this.isLoading,
    required this.onVisible,
  });

  final bool isLoading;
  final VoidCallback onVisible;

  @override
  State<ProductHierarchyLoadMoreSentinel> createState() =>
      _ProductHierarchyLoadMoreSentinelState();
}

class _ProductHierarchyLoadMoreSentinelState
    extends State<ProductHierarchyLoadMoreSentinel> {
  @override
  void initState() {
    super.initState();
    _scheduleIfIdle();
  }

  @override
  void didUpdateWidget(covariant ProductHierarchyLoadMoreSentinel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading && !widget.isLoading) {
      _scheduleIfIdle();
    }
  }

  void _scheduleIfIdle() {
    if (widget.isLoading) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.isLoading) widget.onVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: TraqSpacing.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
