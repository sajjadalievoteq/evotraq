import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_summary.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_list_item.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/utils/hierarchy_tree_flatten.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/widgets/hierarchy_auto_load_sentinel.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/widgets/hierarchy_summary_banner.dart';

const _rootNode = HierarchyNode(epc: 'root', type: 'SSCC', hasChildren: true);
const _childNode = HierarchyNode(
  epc: 'child',
  type: 'SGTIN',
  hasChildren: false,
);

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  test('flatten preserves node, child, and paging-sentinel order', () {
    final child = HierarchyTreeNodeState(node: _childNode);
    final root = HierarchyTreeNodeState(
      node: _rootNode,
      isExpanded: true,
      loadedChildren: [child],
      hasMore: true,
    );

    final items = flattenHierarchyTree(root, 0);

    expect(items, hasLength(3));
    expect(items[0], isA<HierarchyNodeListItem>());
    expect((items[0] as HierarchyNodeListItem).depth, 0);
    expect(items[1], isA<HierarchyNodeListItem>());
    expect((items[1] as HierarchyNodeListItem).depth, 1);
    expect(items[2], isA<HierarchySentinelListItem>());
    expect((items[2] as HierarchySentinelListItem).depth, 1);
  });

  testWidgets('summary banner preserves total and direct counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const HierarchySummaryBanner(
          summary: HierarchySummary(
            totalItemCount: 12,
            hierarchyDepth: 3,
            directChildCount: 4,
          ),
        ),
      ),
    );

    expect(find.textContaining('12'), findsOneWidget);
    expect(find.textContaining('4'), findsOneWidget);
  });

  testWidgets('sentinel requests another page after becoming visible', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      _host(
        HierarchyAutoLoadSentinel(
          depth: 1,
          isLoading: false,
          onVisible: () => calls++,
        ),
      ),
    );
    await tester.pump();

    expect(calls, 1);
  });
}
