import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';

/// Filters and sorts Receiving operations for the list screen.
class ReceivingOperationListFilter {
  ReceivingOperationListFilter._();

  static List<ReceivingResponse> apply({
    required List<ReceivingResponse> operations,
    required String query,
    String? statusFilter,
    String? trackingFilter,
    required String sortBy,
    required String sortDir,
  }) {
    final normalizedQuery = query.toLowerCase().trim();
    final normalizedTracking = trackingFilter?.toLowerCase().trim() ?? '';

    final filtered = operations.where((operation) {
      if (statusFilter != null &&
          (operation.status?.name ?? '') != statusFilter) {
        return false;
      }

      if (normalizedTracking.isNotEmpty) {
        final tracking = operation.trackingNumber?.toLowerCase() ?? '';
        if (!tracking.contains(normalizedTracking)) return false;
      }

      if (normalizedQuery.isEmpty) return true;

      return (operation.receivingReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.sourceGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.receivingGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.trackingNumber?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.receivingOperationId
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
    String? trackingFilter,
    required String sortBy,
    required String sortDir,
  }) {
    final normalizedQuery = query.toLowerCase().trim();
    final normalizedTracking = trackingFilter?.toLowerCase().trim() ?? '';

    final filtered = operations.where((operation) {
      if (statusFilter != null &&
          (operation.status?.name ?? '') != statusFilter) {
        return false;
      }

      if (normalizedTracking.isNotEmpty) {
        final tracking = operation.trackingNumber?.toLowerCase() ?? '';
        if (!tracking.contains(normalizedTracking)) return false;
      }

      if (normalizedQuery.isEmpty) return true;

      return (operation.operationReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.sourceGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.receivingGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.trackingNumber?.toLowerCase().contains(normalizedQuery) ??
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
    ReceivingResponse a,
    ReceivingResponse b,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'receivingReference':
        return _compareStrings(a.receivingReference, b.receivingReference);
      case 'sourceGLN':
        return _compareStrings(a.sourceGLN, b.sourceGLN);
      case 'receivingGLN':
        return _compareStrings(a.receivingGLN, b.receivingGLN);
      case 'status':
        return _compareStrings(a.status?.name, b.status?.name);
      case 'processedEpcsCount':
        return (a.processedEpcsCount ?? 0).compareTo(b.processedEpcsCount ?? 0);
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
      case 'receivingReference':
        return _compareStrings(a.operationReference, b.operationReference);
      case 'sourceGLN':
        return _compareStrings(a.sourceGLN, b.sourceGLN);
      case 'receivingGLN':
        return _compareStrings(a.receivingGLN, b.receivingGLN);
      case 'status':
        return _compareStrings(a.status?.name, b.status?.name);
      case 'processedEpcsCount':
        return a.itemCount.compareTo(b.itemCount);
      case 'processedAt':
      default:
        final aDate = a.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
    }
  }
}
