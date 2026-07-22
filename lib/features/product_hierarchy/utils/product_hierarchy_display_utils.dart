import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/models/hierarchy_tree_node_state.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';



abstract final class ProductHierarchyTreeUtils {
  static HierarchyTreeNodeState? findNode(
    HierarchyTreeNodeState? root,
    String? epc,
  ) {
    if (root == null || epc == null || epc.isEmpty) return null;
    final target = normalizeHierarchyEpc(epc);
    HierarchyTreeNodeState? walk(HierarchyTreeNodeState n) {
      if (normalizeHierarchyEpc(n.node.epc) == target) return n;
      for (final child in n.loadedChildren) {
        final hit = walk(child);
        if (hit != null) return hit;
      }
      return null;
    }

    return walk(root);
  }

  static HierarchyTreeNodeState? findParent(
    HierarchyTreeNodeState? root,
    String? epc,
  ) {
    if (root == null || epc == null || epc.isEmpty) return null;
    final target = normalizeHierarchyEpc(epc);
    if (normalizeHierarchyEpc(root.node.epc) == target) return null;

    HierarchyTreeNodeState? walk(HierarchyTreeNodeState n) {
      for (final child in n.loadedChildren) {
        if (normalizeHierarchyEpc(child.node.epc) == target) return n;
        final hit = walk(child);
        if (hit != null) return hit;
      }
      return null;
    }

    return walk(root);
  }

  
  static List<HierarchyTreeNodeState> pathTo(
    HierarchyTreeNodeState? root,
    String? epc,
  ) {
    if (root == null || epc == null || epc.isEmpty) return const [];
    final target = normalizeHierarchyEpc(epc);
    final path = <HierarchyTreeNodeState>[];

    bool walk(HierarchyTreeNodeState n) {
      path.add(n);
      if (normalizeHierarchyEpc(n.node.epc) == target) return true;
      for (final child in n.loadedChildren) {
        if (walk(child)) return true;
      }
      path.removeLast();
      return false;
    }

    walk(root);
    return List.unmodifiable(path);
  }

  
  static int? depthOf(HierarchyTreeNodeState? root, String? epc) {
    final path = pathTo(root, epc);
    if (path.isEmpty) return null;
    return path.length - 1;
  }

  
  static ({int total, int leaves, int sscc, int sgtin}) loadedDescendantStats(
    HierarchyTreeNodeState node,
  ) {
    var total = 0;
    var leaves = 0;
    var sscc = 0;
    var sgtin = 0;

    void walk(HierarchyTreeNodeState n) {
      for (final child in n.loadedChildren) {
        total++;
        if (child.node.isSscc) sscc++;
        if (child.node.isSgtin) sgtin++;
        if (!child.node.hasChildren) leaves++;
        walk(child);
      }
    }

    walk(node);
    return (total: total, leaves: leaves, sscc: sscc, sgtin: sgtin);
  }
}


abstract final class ProductHierarchyDisplayUtils {
  
  static String packagingTitle({
    required HierarchyNode node,
    ProductInfo? info,
  }) {
    final raw = _firstNonEmpty([
      info?.packagingLevel,
      info?.unitType,
      info?.containerType,
      node.containerType,
      info?.functionalName,
      info?.description,
      node.productName,
    ]);
    if (raw != null) return _titleCase(raw);

    if (node.isSgtin || info?.isSgtin == true) return 'Serialized Product';
    if (node.isSscc || info?.isSscc == true) return 'Container';
    return node.type;
  }

  static String? packagingLevelLabel({
    required HierarchyNode node,
    ProductInfo? info,
  }) {
    final raw = _firstNonEmpty([
      info?.packagingLevel,
      info?.unitType,
      info?.containerType,
      node.containerType,
    ]);
    return raw == null ? null : _titleCase(raw);
  }

  
  static String shortIdentifier({
    required HierarchyNode node,
    ProductInfo? info,
    String? journeyIdentifier,
  }) {
    final candidate = _firstNonEmpty([
      info?.sscc,
      node.sscc,
      info?.serialNumber,
      journeyIdentifier,
      node.epc,
    ])!;
    return _shortenIdentifier(candidate);
  }

  static String _shortenIdentifier(String value) {
    
    final linkMatch = RegExp(r'/(?:00|21)/([^/?#]+)').firstMatch(value);
    if (linkMatch != null) return linkMatch.group(1)!;

    
    final urnMatch = RegExp(r':(?:sscc|sgtin):(.+)$', caseSensitive: false)
        .firstMatch(value);
    if (urnMatch != null) {
      final tail = urnMatch.group(1)!;
      final parts = tail.split('.');
      return parts.isNotEmpty ? parts.last : tail;
    }

    if (value.length <= 22) return value;
    return '…${value.substring(value.length - 18)}';
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  static String _titleCase(String raw) {
    final cleaned = raw.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return raw;
    return cleaned
        .split(RegExp(r'\s+'))
        .map((w) {
          if (w.isEmpty) return w;
          return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}
