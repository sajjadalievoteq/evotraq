import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/services/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';

abstract final class UnpackingContainerContentsLoader {
  static Future<List<HierarchyNode>> loadDirectChildren(
    HierarchyService hierarchyService,
    String parentContainerId,
  ) async {
    final parentEpc = normalizeHierarchyEpc(
      Gs1Converter.barcodeToEpc(parentContainerId) ?? parentContainerId,
    );

    const pageSize = 200;
    final first = await hierarchyService.getHierarchyChildren(
      parentEpc,
      page: 0,
      size: pageSize,
    );

    final nodes = <HierarchyNode>[...first.children];
    if (!first.hasMore) return nodes;

    final remainingPages = first.totalPages > 1
        ? first.totalPages - 1
        : 0;
    if (remainingPages <= 0) {
      
      var page = 1;
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

    final rest = await Future.wait([
      for (var page = 1; page <= remainingPages; page++)
        hierarchyService.getHierarchyChildren(
          parentEpc,
          page: page,
          size: pageSize,
        ),
    ]);
    for (final page in rest) {
      nodes.addAll(page.children);
    }
    return nodes;
  }
}
