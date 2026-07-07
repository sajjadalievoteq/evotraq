import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';

/// Filters and sorts packing operations for the list screen.
class PackingOperationListFilter {
  PackingOperationListFilter._();

  static List<PackingResponse> apply({
    required List<PackingResponse> operations,
    required String query,
    String? statusFilter,
    String? containerFilter,
    required String sortBy,
    required String sortDir,
  }) {
    final normalizedQuery = query.toLowerCase().trim();
    final normalizedContainer = containerFilter?.toLowerCase().trim() ?? '';

    final filtered = operations.where((operation) {
      if (statusFilter != null &&
          (operation.status?.name ?? '') != statusFilter) {
        return false;
      }

      if (normalizedContainer.isNotEmpty) {
        final container = operation.parentContainerId?.toLowerCase() ?? '';
        if (!container.contains(normalizedContainer)) return false;
      }

      if (normalizedQuery.isEmpty) return true;

      return (operation.packingReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.parentContainerId
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.packingLocationGLN
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.workOrderNumber
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.batchNumber?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.packingOperationId
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false);
    }).toList();

    filtered.sort((a, b) {
      final cmp = _compareByField(a, b, sortBy);
      return sortDir == 'asc' ? cmp : -cmp;
    });

    return filtered;
  }

  static List<Operation> applyToOperations({
    required List<Operation> operations,
    required String query,
    String? statusFilter,
    String? containerFilter,
    required String sortBy,
    required String sortDir,
  }) {
    final normalizedQuery = query.toLowerCase().trim();
    final normalizedContainer = containerFilter?.toLowerCase().trim() ?? '';

    final filtered = operations.where((operation) {
      if (statusFilter != null &&
          (operation.status?.name ?? '') != statusFilter) {
        return false;
      }

      if (normalizedContainer.isNotEmpty) {
        final container = operation.parentContainerId?.toLowerCase() ?? '';
        if (!container.contains(normalizedContainer)) return false;
      }

      if (normalizedQuery.isEmpty) return true;

      return (operation.operationReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.parentContainerId
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.primaryGln?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.workOrderNumber
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.batchNumber?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.operationId?.toLowerCase().contains(normalizedQuery) ??
              false);
    }).toList();

    filtered.sort((a, b) {
      final cmp = _compareOperationsByField(a, b, sortBy);
      return sortDir == 'asc' ? cmp : -cmp;
    });

    return filtered;
  }

  static int _compareByField(
    PackingResponse a,
    PackingResponse b,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'packingReference':
        return _compareStrings(a.packingReference, b.packingReference);
      case 'parentContainerId':
        return _compareStrings(a.parentContainerId, b.parentContainerId);
      case 'status':
        return _compareStrings(a.status?.name, b.status?.name);
      case 'packedItemsCount':
        return (a.packedItemsCount ?? 0).compareTo(b.packedItemsCount ?? 0);
      case 'processedAt':
      default:
        final aDate = a.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
    }
  }

  static int _compareStrings(String? a, String? b) {
    return (a ?? '').toLowerCase().compareTo((b ?? '').toLowerCase());
  }

  static int _compareOperationsByField(
    Operation a,
    Operation b,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'packingReference':
        return _compareStrings(a.operationReference, b.operationReference);
      case 'parentContainerId':
        return _compareStrings(a.parentContainerId, b.parentContainerId);
      case 'status':
        return _compareStrings(a.status?.name, b.status?.name);
      case 'packedItemsCount':
        return a.itemCount.compareTo(b.itemCount);
      case 'processedAt':
      default:
        final aDate = a.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
    }
  }
}
