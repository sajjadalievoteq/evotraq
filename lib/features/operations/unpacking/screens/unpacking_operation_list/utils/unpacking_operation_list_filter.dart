import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';

/// Filters and sorts unpacking operations for the list screen.
class UnpackingOperationListFilter {
  UnpackingOperationListFilter._();

  static List<UnpackingResponse> apply({
    required List<UnpackingResponse> operations,
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

      return (operation.unpackingReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.parentContainerId
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.unpackingLocationGLN
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.workOrderNumber
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.batchNumber?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.unpackingOperationId
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

  static int _compareByField(
    UnpackingResponse a,
    UnpackingResponse b,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'unpackingReference':
        return _compareStrings(a.unpackingReference, b.unpackingReference);
      case 'parentContainerId':
        return _compareStrings(a.parentContainerId, b.parentContainerId);
      case 'status':
        return _compareStrings(a.status?.name, b.status?.name);
      case 'unpackedItemsCount':
        return (a.unpackedItemsCount ?? 0).compareTo(b.unpackedItemsCount ?? 0);
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
}
