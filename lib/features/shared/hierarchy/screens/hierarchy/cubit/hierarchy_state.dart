import 'package:traqtrace_app/data/models/hierarchy/hierarchy_summary.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

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
