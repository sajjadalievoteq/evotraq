import 'package:traqtrace_app/data/models/operations/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/services/operations/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';

/// Loads all direct children of a parent SSCC via the hierarchy API.
abstract final class UnpackingContainerContentsLoader {
  static Future<List<HierarchyNode>> loadDirectChildren(
    HierarchyService hierarchyService,
    String parentContainerId,
  ) async {
    final parentEpc = normalizeHierarchyEpc(
      EPCURIConverter.convertToEPCUri(parentContainerId) ?? parentContainerId,
    );

    final nodes = <HierarchyNode>[];
    var page = 0;
    const pageSize = 100;

    while (true) {
      final result = await hierarchyService.getHierarchyChildren(
        parentEpc,
        page: page,
        size: pageSize,
      );
      nodes.addAll(result.children);
      if (!result.hasMore) break;
      page++;
    }

    return nodes;
  }
}
