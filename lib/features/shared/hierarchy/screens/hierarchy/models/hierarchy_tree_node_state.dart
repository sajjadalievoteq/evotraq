import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';

class HierarchyTreeNodeState {
  final HierarchyNode node;
  bool isExpanded;
  bool isLoading;
  String? error;
  List<HierarchyTreeNodeState> loadedChildren;
  int loadedPage;

  int firstLoadedPage;
  int totalPages;
  bool hasMore;

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