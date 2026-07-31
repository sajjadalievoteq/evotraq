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
    this.focusEpc,
    this.searchedEpc,
    this.flashFocusEpc,
    this.parentHasParent = false,
    this.rootEpc,
    this.onClimb,
  });

  final ProductHierarchyFlatItem item;
  final String? selectedEpc;
  final String? focusEpc;
  final String? searchedEpc;
  final String? flashFocusEpc;
  final bool parentHasParent;
  final String? rootEpc;
  final ValueChanged<HierarchyTreeNodeState> onSelect;
  final ValueChanged<HierarchyTreeNodeState> onExpand;
  final ValueChanged<HierarchyTreeNodeState> onCollapse;
  final ValueChanged<HierarchyTreeNodeState> onLoadMore;
  final ValueChanged<HierarchyTreeNodeState>? onClimb;

  bool _same(String? a, String? b) {
    if (a == null || b == null) return false;
    return normalizeHierarchyEpc(a) == normalizeHierarchyEpc(b);
  }

  bool _canClimb(HierarchyTreeNodeState n) {
    // Leaves never climb.
    if (!n.node.hasChildren) return false;
    // Only the current view-root can climb — and only if it sits under a parent
    // that isn't already shown in this view. Every other node's parent is
    // already visible one row up, so no arrow.
    if (rootEpc != null && _same(n.node.epc, rootEpc)) {
      return parentHasParent;
    }
    return false;
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
              isHighlighted: _same(nodeState.node.epc, selectedEpc) ||
                  nodeState.node.isFocused,
              isFlashing: _same(nodeState.node.epc, flashFocusEpc),
              isSearchMatch: _same(nodeState.node.epc, searchedEpc),
              isGroupHeader: isExpandedHeader,
              showBorder: !isExpandedHeader && !inGroupBody,
              canClimb: _canClimb(nodeState),
              onSelect: onSelect,
              onExpand: onExpand,
              onCollapse: onCollapse,
              onClimb: onClimb,
            ),
          ),
        ),
      ProductHierarchySentinelItem(
        :final parent,
        :final depth,
        :final inGroupBody,
        :final isFirstInGroupBody,
        :final isLastInGroupBody,
        :final isPrevious,
      ) =>
        ProductHierarchyGroupChrome(
          depth: depth,
          inGroupBody: inGroupBody,
          isExpandedHeader: false,
          isFirst: isFirstInGroupBody,
          isLast: isLastInGroupBody,
          // The "load earlier" (scroll-up) indicator is driven by the panel's
          // near-top scroll handler, so it only shows a spinner. The trailing
          // "load more" sentinel self-triggers when scrolled into view.
          child: isPrevious
              ? ProductHierarchyLoadIndicator(isLoading: parent.isLoading)
              : ProductHierarchyLoadMoreSentinel(
                  key: ValueKey('${parent.node.epc}-more-${parent.loadedPage}'),
                  isLoading: parent.isLoading,
                  onVisible: () => onLoadMore(parent),
                ),
        ),
    };
  }
}

/// Passive scroll-up load indicator. Shows a spinner while [isLoading] and
/// nothing otherwise; the enclosing panel decides when to fetch the previous
/// page (near-top scroll), so this widget never triggers a load itself.
class ProductHierarchyLoadIndicator extends StatelessWidget {
  const ProductHierarchyLoadIndicator({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();
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
