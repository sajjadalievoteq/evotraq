part of 'product_hierarchy_cubit.dart';

extension ProductHierarchyTreeActions on ProductHierarchyCubit {
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
        size: ProductHierarchyCubit._pageSize,
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
        size: ProductHierarchyCubit._pageSize,
      );
      _mutate(target, (n) {
        n.isLoading = false;
        // Dedupe by EPC: skip any child already present (e.g. a grafted/expanded
        // subtree kept from a climb) so we keep the loaded node instead of
        // appending a duplicate plain one.
        for (final c in page.children) {
          final exists = n.loadedChildren.any(
            (e) => _sameEpc(e.node.epc, c.epc),
          );
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
        size: ProductHierarchyCubit._pageSize,
      );
      var inserted = 0;
      _mutate(target, (n) {
        n.isLoading = false;
        final fresh = <HierarchyTreeNodeState>[];
        for (final c in page.children) {
          final exists = n.loadedChildren.any(
            (e) => _sameEpc(e.node.epc, c.epc),
          );
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
