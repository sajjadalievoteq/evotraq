import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';

class UpdateStatusOperationListFilter {
  UpdateStatusOperationListFilter._();

  static List<UpdateStatusResponse> apply({
    required List<UpdateStatusResponse> operations,
    required String query,
    String? statusFilter,
    required String sortBy,
    required String sortDir,
  }) {
    final normalizedQuery = query.toLowerCase().trim();

    final filtered = operations.where((operation) {
      if (statusFilter != null &&
          (operation.status?.name ?? '') != statusFilter) {
        return false;
      }

      if (normalizedQuery.isEmpty) return true;

      return (operation.decommissioningReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.locationGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.disposition?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.reason?.toLowerCase().contains(normalizedQuery) ?? false) ||
          (operation.decommissioningOperationId
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
    required String sortBy,
    required String sortDir,
  }) {
    final normalizedQuery = query.toLowerCase().trim();

    final filtered = operations.where((operation) {
      if (statusFilter != null &&
          (operation.status?.name ?? '') != statusFilter) {
        return false;
      }

      if (normalizedQuery.isEmpty) return true;

      return (operation.operationReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.locationGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.disposition?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.reason?.toLowerCase().contains(normalizedQuery) ?? false) ||
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
    UpdateStatusResponse a,
    UpdateStatusResponse b,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'decommissioningReference':
        return _compareStrings(
          a.decommissioningReference,
          b.decommissioningReference,
        );
      case 'locationGLN':
        return _compareStrings(a.locationGLN, b.locationGLN);
      case 'disposition':
        return _compareStrings(a.disposition, b.disposition);
      case 'status':
        return _compareStrings(a.status?.name, b.status?.name);
      case 'decommissionedEpcsCount':
        return (a.decommissionedEpcsCount ?? 0)
            .compareTo(b.decommissionedEpcsCount ?? 0);
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
      case 'decommissioningReference':
        return _compareStrings(a.operationReference, b.operationReference);
      case 'locationGLN':
        return _compareStrings(a.locationGLN, b.locationGLN);
      case 'disposition':
        return _compareStrings(a.disposition, b.disposition);
      case 'status':
        return _compareStrings(a.status?.name, b.status?.name);
      case 'decommissionedEpcsCount':
        return a.itemCount.compareTo(b.itemCount);
      case 'processedAt':
      default:
        final aDate = a.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
    }
  }
}
