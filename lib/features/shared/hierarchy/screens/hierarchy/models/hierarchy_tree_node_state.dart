import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';

class HierarchyTreeNodeState {
  final HierarchyNode node;
  bool isExpanded;
  bool isLoading;
  String? error;
  List<HierarchyTreeNodeState> loadedChildren;
  int loadedPage;

  /// Lowest child page currently loaded. Equals [loadedPage] for page-0 seeded
  /// nodes; differs only for climb-grafted parents anchored at a focus page,
  /// which can page *backwards* (see [hasPrevious]).
  int firstLoadedPage;
  int totalPages;
  bool hasMore;

  /// True when child pages *before* [firstLoadedPage] exist and can be
  /// prepended (climb-grafted parents anchored mid-list). Forward-only nodes
  /// leave this false.
  bool hasPrevious;

  HierarchyTreeNodeState({
    required this.node,
    this.isExpanded = false,
    this.isLoading = false,
    this.error,
    List<HierarchyTreeNodeState>? loadedChildren,
    this.loadedPage = -1,
    int? firstLoadedPage,
    this.totalPages = 0,
    this.hasMore = false,
    this.hasPrevious = false,
  })  : firstLoadedPage = firstLoadedPage ?? loadedPage,
        loadedChildren = loadedChildren ?? [];
}
