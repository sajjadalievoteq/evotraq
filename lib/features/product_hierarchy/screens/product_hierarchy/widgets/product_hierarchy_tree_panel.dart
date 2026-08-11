import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/utils/product_hierarchy_tree_flatten.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_flat_row.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_tree_empty_views.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_tree_skeleton.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';

class ProductHierarchyTreePanel extends StatefulWidget {
  const ProductHierarchyTreePanel({super.key});

  @override
  State<ProductHierarchyTreePanel> createState() =>
      _ProductHierarchyTreePanelState();
}

class _ProductHierarchyTreePanelState extends State<ProductHierarchyTreePanel> {
  final ScrollController _scrollController = ScrollController();
  String? _pendingFlashClear;
  int? _scrollToken;
  bool _loadingPrevious = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Load the view-root's earlier sibling page when the user scrolls up to the
  /// very top. Gated on an active upward drag so it never fires on the
  /// programmatic settle right after a climb (which lands pinned at the top).
  void _onScroll() {
    if (!mounted || _loadingPrevious || !_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // ScrollDirection.forward == the user is dragging content down (toward the
    // top / revealing earlier rows).
    if (pos.userScrollDirection != ScrollDirection.forward) return;
    if (pos.pixels > pos.minScrollExtent + 120) return;

    final cubit = context.read<ProductHierarchyCubit>();
    final root = cubit.state.root;
    if (root == null || !root.hasPrevious || root.isLoading) return;
    _handleLoadPrevious();
  }

  /// Fetch the previous page and preserve the visual scroll position: the list
  /// grows above the viewport, so we advance the offset by the measured extent
  /// growth to keep the row the user was looking at stable (and push the
  /// spinner off the top so it can't cascade).
  Future<void> _handleLoadPrevious() async {
    if (_loadingPrevious || !_scrollController.hasClients) return;
    final cubit = context.read<ProductHierarchyCubit>();
    final root = cubit.state.root;
    if (root == null) return;

    _loadingPrevious = true;
    final before = _scrollController.position.pixels;
    final beforeMax = _scrollController.position.maxScrollExtent;
    try {
      final inserted = await cubit.loadPreviousChildren(root);
      if (!mounted || inserted <= 0 || !_scrollController.hasClients) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        final pos = _scrollController.position;
        final delta = pos.maxScrollExtent - beforeMax;
        if (delta > 0) {
          final target = (before + delta).clamp(
            pos.minScrollExtent,
            pos.maxScrollExtent,
          );
          _scrollController.jumpTo(target);
        }
      });
    } finally {
      _loadingPrevious = false;
    }
  }

  /// Animate to [scrollToEpc]. Parent/root (index 0) scrolls to the top;
  /// nested search hits center in the viewport. Cheap: one post-frame pass,
  /// no layout measurement loops.
  void _scheduleScrollToEpc(
    List<ProductHierarchyFlatItem> items,
    String? scrollToEpc,
  ) {
    if (scrollToEpc == null || scrollToEpc.isEmpty) return;
    final target = normalizeHierarchyEpc(scrollToEpc);
    final index = items.indexWhere((item) {
      if (item is! ProductHierarchyNodeItem) return false;
      return normalizeHierarchyEpc(item.nodeState.node.epc) == target;
    });
    if (index < 0) return;

    final token = (_scrollToken ?? 0) + 1;
    _scrollToken = token;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _scrollToken != token || !_scrollController.hasClients) {
        return;
      }
      final position = _scrollController.position;
      const estimatedRowExtent = 64.0;
      final double targetOffset;
      if (index == 0) {
        // Climb lands on the new view-root — pin it to the top.
        targetOffset = position.minScrollExtent;
      } else {
        targetOffset =
            (index * estimatedRowExtent) -
            (position.viewportDimension / 2) +
            (estimatedRowExtent / 2);
      }
      final clamped = targetOffset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );

      // Already in place — skip animation work.
      if ((position.pixels - clamped).abs() < 1.0) {
        context.read<ProductHierarchyCubit>().clearScrollToEpc();
        return;
      }

      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (reduceMotion) {
        _scrollController.jumpTo(clamped);
        context.read<ProductHierarchyCubit>().clearScrollToEpc();
        return;
      }

      _scrollController
          .animateTo(
            clamped,
            duration: TraqDuration.slow,
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() {
            if (!mounted || _scrollToken != token) return;
            context.read<ProductHierarchyCubit>().clearScrollToEpc();
          });
    });
  }

  void _scheduleFlashClear(String? flashEpc) {
    if (flashEpc == null || flashEpc == _pendingFlashClear) return;
    _pendingFlashClear = flashEpc;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final delay = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 1500);
    Future<void>.delayed(delay, () {
      if (!mounted) return;
      if (_pendingFlashClear == flashEpc) {
        _pendingFlashClear = null;
        context.read<ProductHierarchyCubit>().clearFlashFocusEpc();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductHierarchyCubit, ProductHierarchyState>(
      listenWhen: (prev, next) =>
          prev.scrollToEpc != next.scrollToEpc ||
          prev.flashFocusEpc != next.flashFocusEpc ||
          prev.climbToast != next.climbToast,
      listener: (context, state) {
        if ((state.climbToast ?? '').isNotEmpty) {
          context.showInfo(state.climbToast!);
          context.read<ProductHierarchyCubit>().clearClimbToast();
        }
        if (state.flashFocusEpc != null) {
          _scheduleFlashClear(state.flashFocusEpc);
        }
        if (state.scrollToEpc != null && state.root != null) {
          final items = flattenProductHierarchy(state.root!);
          _scheduleScrollToEpc(items, state.scrollToEpc);
        }
      },
      builder: (context, state) {
        final cubit = context.read<ProductHierarchyCubit>();

        // Keep both panels in sync: show skeleton if we are resolving the root,
        // climbing levels, loading node details for the first time,
        // or if the initial "recent parents" list is still loading on the left.
        final showSkeleton =
            state.isResolvingRoot ||
            state.isClimbing ||
            state.recentParentsLoading ||
            (state.isLoadingDetails && state.root == null);

        if (showSkeleton) {
          return const ProductHierarchyTreeSkeleton();
        }

        if ((state.hierarchyError ?? '').isNotEmpty) {
          return ProductHierarchyTreeErrorView(message: state.hierarchyError!);
        }

        final root = state.root;
        if (root == null) {
          return ProductHierarchyTreeIdleView(
            hasRecentParents: state.recentParents.isNotEmpty,
          );
        }

        final items = flattenProductHierarchy(root);

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            context.padding.top,
            context.padding.top,
            context.padding.top,
            TraqSpacing.lg,
          ),
          itemCount: items.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemBuilder: (context, index) {
            return ProductHierarchyFlatRow(
              item: items[index],
              selectedEpc: state.selectedEpc,
              searchedEpc: state.searchedEpc,
              focusEpc: state.focusEpc,
              flashFocusEpc: state.flashFocusEpc,
              parentHasParent: state.parentHasParent,
              rootEpc: root.node.epc,
              onSelect: (n) => cubit.selectEpc(n.node.epc),
              onExpand: cubit.expand,
              onCollapse: cubit.collapse,
              onLoadMore: cubit.loadMoreChildren,
              onClimb: (n) => cubit.climbToParent(n.node.epc),
            );
          },
        );
      },
    );
  }
}
