import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/operations/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/operations/hierarchy/hierarchy_summary.dart';
import 'package:traqtrace_app/data/services/operations/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';

part 'hierarchy_state.dart';

class HierarchyCubit extends Cubit<HierarchyState> {
  HierarchyCubit() : super(const HierarchyLoading());

  final _service = getIt<HierarchyService>();
  static const int _pageSize = 20;

  // ─────────────────────────────────────────────────────────────────────────
  // Public entry point — universal bidirectional traversal.
  //
  // Works for any EPC type (SSCC, SGTIN, or future types).
  // No type checks. No SSCC/SGTIN branches. No heuristics.
  //
  // Algorithm:
  //   1. Ask the backend to walk upward and return the root ancestor.
  //      (GET /events/aggregation/child/{epc}/root-container)
  //      If [inputEpc] has no parent the backend returns it unchanged.
  //   2. Load the root's direct children via the existing paginated endpoint.
  //   3. Fire the traversal summary in the background for the banner.
  //   4. Emit [HierarchyLoaded] with [highlightEpc] = inputEpc when it
  //      differs from the root (so the screen can mark the selected node).
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> openHierarchy(String inputEpc) async {
    emit(const HierarchyResolvingRoot());

    final normalizedInput = normalizeHierarchyEpc(inputEpc);

    try {
      final rootEpc = await _service.getRootContainer(normalizedInput);

      // Step 2 — load root's children + fire summary in parallel
      final pageFuture    = _service.getHierarchyChildren(rootEpc, page: 0, size: _pageSize);
      final summaryFuture = _service.getHierarchySummary(rootEpc);

      final page = await pageFuture;

      final rootNode = HierarchyNode(
        epc: rootEpc,
        type: 'EPC',
        hasChildren: page.children.isNotEmpty,
      );
      final rootState = HierarchyTreeNodeState(
        node: rootNode,
        isExpanded: true,
        loadedChildren: page.children
            .map((n) => HierarchyTreeNodeState(node: n))
            .toList(),
        loadedPage: 0,
        totalPages: page.totalPages,
        hasMore: page.hasMore,
      );

      // Only set highlightEpc when the user's EPC differs from the root
      final highlight = (normalizedInput != rootEpc) ? normalizedInput : null;
      emit(HierarchyLoaded(rootState, highlightEpc: highlight));

      // Step 3 — attach summary when it arrives (best-effort, never crashes)
      final summary = await summaryFuture;
      if (summary != null && !isClosed) {
        final current = state;
        if (current is HierarchyLoaded) {
          emit(HierarchyLoaded(
            current.root,
            summary: summary,
            highlightEpc: current.highlightEpc,
          ));
        }
      }
    } catch (e) {
      emit(HierarchyError(e.toString()));
    }
  }

  /// Backward-compatible alias so existing `loadRoot(epc)` call-sites keep compiling.
  Future<void> loadRoot(String epc) => openHierarchy(epc);

  Future<void> expand(HierarchyTreeNodeState target) async {
    if (target.isExpanded || target.isLoading) return;
    _mutate(target, (n) {
      n.isLoading = true;
      n.error = null;
    });
    try {
      final page = await _service.getHierarchyChildren(
        target.node.epc,
        page: 0,
        size: _pageSize,
      );
      _mutate(target, (n) {
        n.isLoading = false;
        n.isExpanded = true;
        n.loadedChildren = page.children
            .map((c) => HierarchyTreeNodeState(node: c))
            .toList();
        n.loadedPage = 0;
        n.totalPages = page.totalPages;
        n.hasMore = page.hasMore;
      });
    } catch (e) {
      _mutate(target, (n) {
        n.isLoading = false;
        n.error = e.toString();
      });
    }
  }

  void collapse(HierarchyTreeNodeState target) {
    _mutate(target, (n) => n.isExpanded = false);
  }

  Future<void> loadMoreChildren(HierarchyTreeNodeState target) async {
    if (!target.hasMore || target.isLoading) return;
    final nextPage = target.loadedPage + 1;
    _mutate(target, (n) => n.isLoading = true);
    try {
      final page = await _service.getHierarchyChildren(
        target.node.epc,
        page: nextPage,
        size: _pageSize,
      );
      _mutate(target, (n) {
        n.isLoading = false;
        n.loadedChildren.addAll(
          page.children.map((c) => HierarchyTreeNodeState(node: c)),
        );
        n.loadedPage = nextPage;
        n.totalPages = page.totalPages;
        n.hasMore = page.hasMore;
      });
    } catch (e) {
      _mutate(target, (n) {
        n.isLoading = false;
        n.error = 'Failed to load more: ${e.toString()}';
      });
    }
  }

  void _mutate(
    HierarchyTreeNodeState target,
    void Function(HierarchyTreeNodeState) fn,
  ) {
    final current = state;
    if (current is HierarchyLoaded) {
      fn(target);
      emit(HierarchyLoaded(
        current.root,
        summary: current.summary,
        highlightEpc: current.highlightEpc,
      ));
    }
  }
}
