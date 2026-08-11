import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

sealed class HierarchyListItem {
  const HierarchyListItem();
}

class HierarchyNodeListItem extends HierarchyListItem {
  const HierarchyNodeListItem(this.nodeState, this.depth);

  final HierarchyTreeNodeState nodeState;
  final int depth;
}

class HierarchySentinelListItem extends HierarchyListItem {
  const HierarchySentinelListItem(this.parent, this.depth);

  final HierarchyTreeNodeState parent;
  final int depth;
}
