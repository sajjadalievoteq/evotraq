import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_display_utils.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';

void main() {
  group('ProductHierarchyDisplayUtils', () {
    test('packagingTitle prefers packaging level then falls back', () {
      const node = HierarchyNode(
        epc: 'urn:epc:id:sscc:0614141.1234567890',
        type: 'SSCC',
        hasChildren: true,
      );
      expect(
        ProductHierarchyDisplayUtils.packagingTitle(
          node: node,
          info: const ProductInfo(packagingLevel: 'PALLET'),
        ),
        'Pallet',
      );
      expect(
        ProductHierarchyDisplayUtils.packagingTitle(node: node),
        'Container',
      );
    });

    test('shortIdentifier extracts digital-link and URN tails', () {
      const node = HierarchyNode(
        epc: 'https://id.gs1.org/00/162920000955842182',
        type: 'SSCC',
        hasChildren: false,
      );
      expect(
        ProductHierarchyDisplayUtils.shortIdentifier(node: node),
        '162920000955842182',
      );
    });
  });

  group('ProductHierarchyTreeUtils', () {
    test('pathTo / findParent / depthOf walk loaded tree', () {
      final leaf = HierarchyTreeNodeState(
        node: const HierarchyNode(
          epc: 'child',
          type: 'SGTIN',
          hasChildren: false,
        ),
      );
      final root = HierarchyTreeNodeState(
        node: const HierarchyNode(
          epc: 'root',
          type: 'SSCC',
          hasChildren: true,
          childCount: 1,
        ),
        isExpanded: true,
        loadedChildren: [leaf],
      );

      expect(ProductHierarchyTreeUtils.findParent(root, 'child')?.node.epc, 'root');
      expect(ProductHierarchyTreeUtils.depthOf(root, 'child'), 1);
      expect(
        ProductHierarchyTreeUtils.pathTo(root, 'child').map((n) => n.node.epc),
        ['root', 'child'],
      );
      expect(
        ProductHierarchyTreeUtils.loadedDescendantStats(root).sgtin,
        1,
      );
    });
  });
}
