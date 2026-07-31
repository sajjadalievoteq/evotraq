import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/data/services/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/data/services/operations/packing/packing_operation_service.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_identifier_utils.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class ProductHierarchyCubit extends Cubit<ProductHierarchyState> {
  ProductHierarchyCubit({
    HierarchyService? hierarchyService,
    ProductJourneyService? journeyService,
    PackingOperationService? packingService,
  }) : _hierarchyService = hierarchyService ?? getIt<HierarchyService>(),
       _journeyService = journeyService ?? getIt<ProductJourneyService>(),
       _packingService = packingService ?? getIt<PackingOperationService>(),
       super(const ProductHierarchyState());

  final HierarchyService _hierarchyService;
  final ProductJourneyService _journeyService;
  final PackingOperationService _packingService;
  static const int _pageSize = 20;
  bool _recentParentsRequested = false;
  final Map<String, ProductJourney?> _journeyCache = {};

  /// Idle left panel: recent packing ops from [PackingOperationService],
  /// de-duped by parent container (newest first). Does not clear on
  /// [openHierarchy] so returning to idle is instant.
  Future<void> loadRecentParents() async {
    if (_recentParentsRequested) return;
    if (state.root != null || state.isResolvingRoot) return;
    if (state.recentParents.isNotEmpty) return;

    _recentParentsRequested = true;
    emit(state.copyWith(recentParentsLoading: true));
    try {
      // Fetch a bit more than 10 so de-dupe by parent still yields ~10 rows.
      final operations = await _packingService.getAllPackingOperations(
        page: 0,
        size: 30,
      );
      if (isClosed) return;
      if (state.root != null || state.isResolvingRoot) {
        emit(state.copyWith(recentParentsLoading: false));
        return;
      }
      emit(
        state.copyWith(
          recentParents: _distinctRecentParents(operations),
          recentParentsLoading: false,
        ),
      );
    } catch (e, st) {
      debugPrint('[ProductHierarchyCubit] loadRecentParents failed: $e\n$st');
      if (isClosed) return;
      emit(
        state.copyWith(
          recentParents: const [],
          recentParentsLoading: false,
        ),
      );
    }
  }

  static List<PackingResponse> _distinctRecentParents(
    List<PackingResponse> operations,
  ) {
    final seen = <String>{};
    final out = <PackingResponse>[];
    for (final op in operations) {
      final parent = normalizeProductHierarchyInput(
        op.parentContainerId ?? '',
      );
      if (parent.isEmpty || !seen.add(parent)) continue;
      out.add(op);
      if (out.length >= 10) break;
    }
    return List<PackingResponse>.unmodifiable(out);
  }

  Future<void> openHierarchy(String rawInput) async {
    final input = normalizeProductHierarchyInput(rawInput);
    if (input.isEmpty) return;
    emit(
      state.copyWith(
        isResolvingRoot: true,
        isLoadingDetails: true,
        clearHierarchyError: true,
        clearDetailsError: true,
        clearJourney: true,
        clearScrollToEpc: true,
        clearFlashFocusEpc: true,
        clearClimbToast: true,
        clearSearchedEpc: true,
        searchResults: const [],
        parentHasParent: false,
      ),
    );
    try {
      // Details (journey) are independent of the tree and the focused EPC is
      // known up front (== normalized input), so start the details fetch NOW —
      // in parallel with the parent-container lookup, tree page, and probe.
      final journeyFuture = _getJourneyCached(input);

      // Containers open as the view root so a mid-level SSCC keeps its climb arrow.
      // Leaf SGTINs open from their IMMEDIATE parent container (not the whole-tree
      // root), with the leaf as focus; climb-up then reaches higher parents.
      final inputType = _inferType(input);
      final String viewRootEpc;
      if (inputType == 'SSCC') {
        viewRootEpc = input;
      } else {
        final immediateParent =
            await _hierarchyService.getParentContainer(input);
        viewRootEpc = (immediateParent != null && immediateParent.isNotEmpty)
            ? immediateParent
            : input;
      }

      final normalizedRoot = normalizeProductHierarchyInput(viewRootEpc);
      final focus = inputType == 'SSCC'
          ? normalizedRoot
          : normalizeProductHierarchyInput(input);

      final pageFuture = _hierarchyService.getHierarchyChildren(
        viewRootEpc,
        page: 0,
        size: _pageSize,
      );
      // Lightweight parent probe — same answer as children?focusEpc without
      // loading a siblings page we discard.
      final parentProbeFuture =
          _hierarchyService.getParentContainer(viewRootEpc);

      final page = await pageFuture;
      final viewRootParent = await parentProbeFuture;
      final rootHasParent =
          viewRootParent != null && viewRootParent.isNotEmpty;

      final rootState = HierarchyTreeNodeState(
        node: HierarchyNode(
          epc: normalizedRoot,
          type: _inferType(normalizedRoot),
          hasChildren: page.children.isNotEmpty,
          childCount: page.total,
        ),
        isExpanded: true,
        loadedChildren: page.children
            .map((n) => HierarchyTreeNodeState(node: n))
            .toList(),
        loadedPage: page.page,
        totalPages: page.totalPages,
        hasMore: page.hasMore,
      );
      // Await the details (started in parallel above) so the tree + node details
      // reveal together in a single emit — no staggered "tree first, details
      // later". Both panels show their skeletons until this point.
      dynamic journey;
      String? detailsError;
      try {
        journey = await journeyFuture;
      } catch (e) {
        detailsError = e.toString();
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          root: rootState,
          selectedEpc: focus,
          focusEpc: focus,
          searchedEpc: focus,
          selectedJourney: journey,
          isResolvingRoot: false,
          isLoadingDetails: false,
          clearHierarchyError: true,
          parentHasParent: rootHasParent,
          detailsError: detailsError ??
              (journey == null ? 'No product details found.' : null),
          scrollToEpc: focus != normalizedRoot ? focus : null,
          flashFocusEpc: focus != normalizedRoot ? focus : null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isResolvingRoot: false, hierarchyError: e.toString()),
      );
    }
  }

  Future<ProductJourney?> _getJourneyCached(String epc) async {
    final key = normalizeProductHierarchyInput(epc);
    if (_journeyCache.containsKey(key)) {
      return _journeyCache[key];
    }
    final journey = await _journeyService.getJourneyByIdentifier(key);
    _journeyCache[key] = journey;
    return journey;
  }

  /// Specialized internal helper that only fetches journey data for [epc].
  /// Assumes [isLoadingDetails] is already set to true by caller in the same
  /// frame as clearing other loading flags to prevent UI flicker.
  Future<void> _loadDetailsOnly(String epc) async {
    try {
      final journey = await _getJourneyCached(epc);
      if (isClosed) return;
      emit(
        state.copyWith(
          selectedJourney: journey,
          isLoadingDetails: false,
          detailsError: journey == null ? 'No product details found.' : null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingDetails: false, detailsError: e.toString()));
    }
  }

  /// Climb one level from [epc]: graft parent + siblings above the current
  /// view-root, reusing the existing expanded subtree by reference.
  Future<void> climbToParent(String epc) async {
    final focus = normalizeProductHierarchyInput(epc);
    if (focus.isEmpty || state.isClimbing) return;

    final previousRoot = state.root;
    if (previousRoot == null) return;

    emit(state.copyWith(isClimbing: true, clearClimbToast: true));
    try {
      final page = await _hierarchyService.getParentContext(
        focus,
        size: _pageSize,
      );
      if (page.hasParent != true ||
          page.parent == null ||
          page.parentEpc == null) {
        emit(
          state.copyWith(
            isClimbing: false,
            climbToast: 'Top of hierarchy',
            parentHasParent: false,
          ),
        );
        return;
      }

      final parentNode = page.parent!;
      // Seed the grafted parent from a clean page-0 children window so it
      // forward-paginates on scroll-down at EVERY depth, exactly like the
      // original root. Focus-anchored seeding left mid-level grafted parents
      // unable to load their remaining children on scroll (their siblings were
      // treated as "earlier" pages), so only the root kept paginating.
      final page0 = await _hierarchyService.getHierarchyChildren(
        parentNode.epc,
        page: 0,
        size: _pageSize,
      );

      var focusReused = false;
      final siblings = <HierarchyTreeNodeState>[];
      for (final n in page0.children) {
        if (_sameEpc(n.epc, focus)) {
          // Reuse the current view-root subtree (expansion + loaded descendants).
          siblings.add(previousRoot);
          focusReused = true;
        } else {
          siblings.add(HierarchyTreeNodeState(node: n));
        }
      }
      if (!focusReused) {
        // Focus child lives on a later page; keep its subtree grafted so it
        // stays visible. The dedupe-by-EPC merge in loadMoreChildren swaps it
        // into place (no duplicate) when its real page is scrolled into view.
        siblings.add(previousRoot);
      }

      final newParentRoot = HierarchyTreeNodeState(
        node: HierarchyNode(
          epc: parentNode.epc,
          type: parentNode.type,
          hasChildren: true,
          childCount: page0.total,
          gtin: parentNode.gtin,
          productName: parentNode.productName,
          lotNumber: parentNode.lotNumber,
          expiryDate: parentNode.expiryDate,
          sscc: parentNode.sscc,
          containerType: parentNode.containerType,
          status: parentNode.status,
          disposition: parentNode.disposition,
        ),
        isExpanded: true,
        loadedChildren: siblings,
        loadedPage: page0.page,
        totalPages: page0.totalPages,
        hasMore: page0.hasMore,
      );

      emit(
        state.copyWith(
          root: newParentRoot,
          selectedEpc: focus,
          focusEpc: focus,
          parentHasParent: page.parentHasParent == true,
          isClimbing: false,
          isLoadingDetails: true,
          treeVersion: state.treeVersion + 1,
          // Animate the list up to the new parent (view-root).
          scrollToEpc: parentNode.epc,
          flashFocusEpc: parentNode.epc,
          clearHierarchyError: true,
        ),
      );
      await _loadDetailsOnly(focus);
    } catch (e) {
      emit(
        state.copyWith(
          isClimbing: false,
          hierarchyError: e.toString(),
        ),
      );
    }
  }

  bool _sameEpc(String a, String b) =>
      normalizeProductHierarchyInput(a) == normalizeProductHierarchyInput(b);

  void clearScrollToEpc() {
    if (state.scrollToEpc == null) return;
    emit(state.copyWith(clearScrollToEpc: true));
  }

  void clearFlashFocusEpc() {
    if (state.flashFocusEpc == null) return;
    emit(state.copyWith(clearFlashFocusEpc: true));
  }

  void clearClimbToast() {
    if (state.climbToast == null) return;
    emit(state.copyWith(clearClimbToast: true));
  }

  Future<void> searchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      emit(state.copyWith(searchResults: const [], isSearching: false));
      return;
    }
    emit(state.copyWith(isSearching: true));
    final results = await _journeyService.searchProducts(trimmed);
    emit(state.copyWith(searchResults: results, isSearching: false));
  }

  Future<void> selectSuggestion(ProductSearchResult result) async {
    await openHierarchy(result.identifier);
  }

  Future<void> selectEpc(String epc) async {
    final normalized = normalizeProductHierarchyInput(epc);
    emit(
      state.copyWith(
        selectedEpc: normalized,
        focusEpc: normalized,
        isLoadingDetails: true,
        clearDetailsError: true,
      ),
    );
    try {
      final journey = await _getJourneyCached(normalized);
      emit(
        state.copyWith(
          selectedJourney: journey,
          isLoadingDetails: false,
          detailsError: journey == null ? 'No product details found.' : null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingDetails: false, detailsError: e.toString()));
    }
  }

  Future<void> expand(HierarchyTreeNodeState target) async {
    if (target.isExpanded || target.isLoading) return;
    if (target.node.isCycle || !target.node.hasChildren) return;

    
    if (target.loadedChildren.isNotEmpty || target.loadedPage >= 0) {
      _mutate(target, (n) {
        n.isExpanded = true;
        n.error = null;
      });
      return;
    }

    _mutate(target, (n) {
      n.isLoading = true;
      n.error = null;
    });
    try {
      final page = await _hierarchyService.getHierarchyChildren(
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
        n.loadedPage = page.page;
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
      final page = await _hierarchyService.getHierarchyChildren(
        target.node.epc,
        page: nextPage,
        size: _pageSize,
      );
      _mutate(target, (n) {
        n.isLoading = false;
        // Dedupe by EPC: skip any child already present (e.g. a grafted/expanded
        // subtree kept from a climb) so we keep the loaded node instead of
        // appending a duplicate plain one.
        for (final c in page.children) {
          final exists =
              n.loadedChildren.any((e) => _sameEpc(e.node.epc, c.epc));
          if (exists) continue;
          n.loadedChildren.add(HierarchyTreeNodeState(node: c));
        }
        n.loadedPage = page.page;
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

  /// Prepend the child page immediately *before* [target].firstLoadedPage
  /// (climb-grafted parents only). Dedupes by EPC so a grafted/expanded subtree
  /// isn't duplicated. Returns the number of newly inserted rows so the caller
  /// can preserve scroll position after the prepend.
  Future<int> loadPreviousChildren(HierarchyTreeNodeState target) async {
    if (!target.hasPrevious || target.isLoading) return 0;
    final prevPage = target.firstLoadedPage - 1;
    if (prevPage < 0) {
      _mutate(target, (n) => n.hasPrevious = false);
      return 0;
    }
    _mutate(target, (n) => n.isLoading = true);
    try {
      final page = await _hierarchyService.getHierarchyChildren(
        target.node.epc,
        page: prevPage,
        size: _pageSize,
      );
      var inserted = 0;
      _mutate(target, (n) {
        n.isLoading = false;
        final fresh = <HierarchyTreeNodeState>[];
        for (final c in page.children) {
          final exists =
              n.loadedChildren.any((e) => _sameEpc(e.node.epc, c.epc));
          if (exists) continue;
          fresh.add(HierarchyTreeNodeState(node: c));
        }
        n.loadedChildren.insertAll(0, fresh);
        inserted = fresh.length;
        n.firstLoadedPage = page.page;
        n.hasPrevious = page.page > 0;
      });
      return inserted;
    } catch (e) {
      _mutate(target, (n) {
        n.isLoading = false;
        n.error = 'Failed to load previous: ${e.toString()}';
      });
      return 0;
    }
  }

  Future<void> expandAll() async {
    final root = state.root;
    if (root == null) return;
    await _expandAllRecursive(root);
    _bumpTreeVersion();
  }

  Future<void> _expandAllRecursive(HierarchyTreeNodeState node) async {
    if (node.node.hasChildren && !node.isExpanded && !node.isLoading) {
      await expand(node);
    }
    final children = List<HierarchyTreeNodeState>.of(node.loadedChildren);
    await Future.wait(children.map(_expandAllRecursive));
  }

  void collapseAll() {
    final root = state.root;
    if (root == null) return;
    _collapseAllRecursive(root);
    _bumpTreeVersion(root: root);
  }

  void _collapseAllRecursive(HierarchyTreeNodeState node) {
    node.isExpanded = false;
    for (final child in node.loadedChildren) {
      _collapseAllRecursive(child);
    }
  }

  void clearSuggestions() {
    emit(state.copyWith(searchResults: const []));
  }

  /// Reset to the idle left panel (drop the loaded tree + node details +
  /// selection/search), keeping the recent-parents list so idle is instant.
  /// Mirrors Product Journey's clear-on-search-cancel behavior.
  void clear() {
    final recent = state.recentParents;
    final recentLoading = state.recentParentsLoading;
    emit(
      ProductHierarchyState(
        recentParents: recent,
        recentParentsLoading: recentLoading,
      ),
    );
    if (recent.isEmpty) {
      _recentParentsRequested = false;
      loadRecentParents();
    }
  }

  void _mutate(
    HierarchyTreeNodeState target,
    void Function(HierarchyTreeNodeState) fn,
  ) {
    final root = state.root;
    if (root == null) return;
    fn(target);
    _bumpTreeVersion(root: root);
  }

  void _bumpTreeVersion({HierarchyTreeNodeState? root}) {
    emit(
      state.copyWith(
        root: root ?? state.root,
        treeVersion: state.treeVersion + 1,
      ),
    );
  }

  String _inferType(String epc) {
    final lower = epc.toLowerCase();
    if (lower.contains(':sscc:') || lower.contains('/00/')) return 'SSCC';
    if (lower.contains(':sgtin:') || lower.contains('/01/')) return 'SGTIN';
    return 'EPC';
  }
}
