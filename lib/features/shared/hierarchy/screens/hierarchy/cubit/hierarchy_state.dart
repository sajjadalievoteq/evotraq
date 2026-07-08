part of 'hierarchy_cubit.dart';

sealed class HierarchyState {
  const HierarchyState();
}

class HierarchyLoading extends HierarchyState {
  const HierarchyLoading();
}

class HierarchyResolvingRoot extends HierarchyState {
  const HierarchyResolvingRoot();
}

class HierarchyLoaded extends HierarchyState {
  final HierarchyTreeNodeState root;
  final HierarchySummary? summary;
  final String? highlightEpc;

  const HierarchyLoaded(this.root, {this.summary, this.highlightEpc});
}

class HierarchyError extends HierarchyState {
  final String message;
  const HierarchyError(this.message);
}
