import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_page.dart';
import 'package:traqtrace_app/data/services/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

class _MockHierarchyService extends Mock implements HierarchyService {}

class _MockJourneyService extends Mock implements ProductJourneyService {}

void main() {
  late _MockHierarchyService hierarchyService;
  late _MockJourneyService journeyService;
  late ProductHierarchyCubit cubit;

  const rootEpc = 'urn:epc:id:sscc:0614141.1234567890';
  const childEpc = 'urn:epc:id:sscc:0614141.1234567891';
  const leafEpc = 'urn:epc:id:sgtin:0614141.107346.SN1001';

  setUp(() {
    hierarchyService = _MockHierarchyService();
    journeyService = _MockJourneyService();
    cubit = ProductHierarchyCubit(
      hierarchyService: hierarchyService,
      journeyService: journeyService,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  HierarchyTreeNodeState seededTree() {
    final leaf = HierarchyTreeNodeState(
      node: const HierarchyNode(
        epc: leafEpc,
        type: 'SGTIN',
        hasChildren: false,
      ),
    );
    final child = HierarchyTreeNodeState(
      node: const HierarchyNode(
        epc: childEpc,
        type: 'SSCC',
        hasChildren: true,
        childCount: 1,
      ),
      isExpanded: true,
      loadedPage: 0,
      loadedChildren: [leaf],
    );
    return HierarchyTreeNodeState(
      node: const HierarchyNode(
        epc: rootEpc,
        type: 'SSCC',
        hasChildren: true,
        childCount: 1,
      ),
      isExpanded: true,
      loadedPage: 0,
      loadedChildren: [child],
    );
  }

  test('collapseAll collapses every node and bumps treeVersion', () {
    final root = seededTree();
    cubit.emit(
      ProductHierarchyState(root: root, selectedEpc: rootEpc, treeVersion: 0),
    );

    cubit.collapseAll();

    expect(cubit.state.root!.isExpanded, isFalse);
    expect(cubit.state.root!.loadedChildren.first.isExpanded, isFalse);
    expect(cubit.state.treeVersion, greaterThan(0));
  });

  blocTest<ProductHierarchyCubit, ProductHierarchyState>(
    'expandAll re-expands collapsed loaded nodes without refetch',
    build: () => cubit,
    seed: () {
      final root = seededTree();
      
      root.isExpanded = false;
      root.loadedChildren.first.isExpanded = false;
      return ProductHierarchyState(
        root: root,
        selectedEpc: rootEpc,
        treeVersion: 1,
      );
    },
    act: (c) => c.expandAll(),
    verify: (c) {
      expect(c.state.root!.isExpanded, isTrue);
      expect(c.state.root!.loadedChildren.first.isExpanded, isTrue);
      expect(c.state.treeVersion, greaterThan(1));
      verifyNever(
        () => hierarchyService.getHierarchyChildren(
          any(),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      );
    },
  );
}
