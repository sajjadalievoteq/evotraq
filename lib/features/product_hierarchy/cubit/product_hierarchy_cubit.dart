import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/data/services/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_identifier_utils.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class ProductHierarchyCubit extends Cubit<ProductHierarchyState> {
  ProductHierarchyCubit({
    HierarchyService? hierarchyService,
    ProductJourneyService? journeyService,
  }) : _hierarchyService = hierarchyService ?? getIt<HierarchyService>(),
       _journeyService = journeyService ?? getIt<ProductJourneyService>(),
       super(const ProductHierarchyState());

  final HierarchyService _hierarchyService;
  final ProductJourneyService _journeyService;
  static const int _pageSize = 20;

  Future<void> openHierarchy(String rawInput) async {
    final input = normalizeProductHierarchyInput(rawInput);
    if (input.isEmpty) return;
    emit(
      state.copyWith(
        isResolvingRoot: true,
        clearHierarchyError: true,
        clearDetailsError: true,
        clearJourney: true,
        searchResults: const [],
      ),
    );
    try {
      final rootEpc = await _hierarchyService.getRootContainer(input);
      final page = await _hierarchyService.getHierarchyChildren(
        rootEpc,
        page: 0,
        size: _pageSize,
      );
      final rootState = HierarchyTreeNodeState(
        node: HierarchyNode(
          epc: rootEpc,
          type: _inferType(rootEpc),
          hasChildren: page.children.isNotEmpty,
          childCount: page.total,
        ),
        
        isExpanded: false,
        loadedChildren: page.children
            .map((n) => HierarchyTreeNodeState(node: n))
            .toList(),
        loadedPage: page.page,
        totalPages: page.totalPages,
        hasMore: page.hasMore,
      );
      emit(
        state.copyWith(
          root: rootState,
          selectedEpc: rootEpc,
          isResolvingRoot: false,
          clearHierarchyError: true,
        ),
      );
      await selectEpc(input == rootEpc ? rootEpc : input);
    } catch (e) {
      emit(
        state.copyWith(isResolvingRoot: false, hierarchyError: e.toString()),
      );
    }
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
        isLoadingDetails: true,
        clearDetailsError: true,
      ),
    );
    try {
      final journey = await _journeyService.getJourneyByIdentifier(normalized);
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
        n.loadedChildren.addAll(
          page.children.map((c) => HierarchyTreeNodeState(node: c)),
        );
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
    for (final child in List<HierarchyTreeNodeState>.of(node.loadedChildren)) {
      await _expandAllRecursive(child);
    }
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
