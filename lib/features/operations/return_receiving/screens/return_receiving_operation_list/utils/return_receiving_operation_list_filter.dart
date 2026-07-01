import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';

/// Filters and sorts ReturnReceiving operations for the list screen.
class ReturnReceivingOperationListFilter {
  ReturnReceivingOperationListFilter._();

  static List<ReturnReceivingResponse> apply({
    required List<ReturnReceivingResponse> operations,
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

      return (operation.returnReceivingReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.sourceGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.receivingGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.trackingNumber?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.returnReceivingOperationId
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
    ReturnReceivingResponse a,
    ReturnReceivingResponse b,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'returnReceivingReference':
        return _compareStrings(a.returnReceivingReference, b.returnReceivingReference);
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
}
