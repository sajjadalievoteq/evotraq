import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_list_item.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

List<HierarchyListItem> flattenHierarchyTree(
  HierarchyTreeNodeState node,
  int depth,
) {
  final items = <HierarchyListItem>[HierarchyNodeListItem(node, depth)];
  if (node.isExpanded) {
    for (final child in node.loadedChildren) {
      items.addAll(flattenHierarchyTree(child, depth + 1));
    }
    if (node.hasMore) {
      items.add(HierarchySentinelListItem(node, depth + 1));
    }
  }
  return items;
}
