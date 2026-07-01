part of 'hierarchy_cubit.dart';

sealed class HierarchyState {
  const HierarchyState();
}

class HierarchyLoading extends HierarchyState {
  const HierarchyLoading();
}

/// Shown briefly while the backend walks upward to find the root ancestor.
class HierarchyResolvingRoot extends HierarchyState {
  const HierarchyResolvingRoot();
}

/// Tree is loaded and ready to display.
///
/// [summary] is populated from the traversal endpoint (may be null while
/// still loading or if the endpoint returned no data).
///
/// [highlightEpc] is the EPC the user originally requested. It may differ
/// from [root.node.epc] when the user tapped on a child deep in the tree —
/// the tree is rooted at the ancestor but the selected EPC is highlighted.
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
