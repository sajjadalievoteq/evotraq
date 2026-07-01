import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';

/// Filters and sorts shipping operations for the list screen.
class ReturnShippingOperationListFilter {
  ReturnShippingOperationListFilter._();

  static List<ReturnShippingResponse> apply({
    required List<ReturnShippingResponse> operations,
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

      return (operation.returnReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.sourceGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.destinationGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.trackingNumber?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.returnShippingOperationId
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
    ReturnShippingResponse a,
    ReturnShippingResponse b,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'returnReference':
        return _compareStrings(a.returnReference, b.returnReference);
      case 'sourceGLN':
        return _compareStrings(a.sourceGLN, b.sourceGLN);
      case 'destinationGLN':
        return _compareStrings(a.destinationGLN, b.destinationGLN);
      case 'status':
        return _compareStrings(a.status?.name, b.status?.name);
      case 'shippedEpcsCount':
        return (a.shippedEpcsCount ?? 0).compareTo(b.shippedEpcsCount ?? 0);
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
