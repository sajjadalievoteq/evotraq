import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';

class CancelShippingOperationListFilter {
  CancelShippingOperationListFilter._();

  static List<CancelShippingResponse> apply({
    required List<CancelShippingResponse> operations,
    required String query,
    String? statusFilter,
    String? gincFilter,
    required String sortBy,
    required String sortDir,
  }) {
    final normalizedQuery = query.toLowerCase().trim();
    final normalizedGinc = gincFilter?.toLowerCase().trim() ?? '';

    final filtered = operations.where((operation) {
      if (statusFilter != null &&
          (operation.status?.name ?? '') != statusFilter) {
        return false;
      }

      if (normalizedGinc.isNotEmpty) {
        final ginc = operation.originalShippingReference?.toLowerCase() ?? '';
        if (!ginc.contains(normalizedGinc)) return false;
      }

      if (normalizedQuery.isEmpty) return true;

      return (operation.cancelShippingReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.sourceGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.destinationGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.cancelReason?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.originalShippingReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.cancelShippingOperationId
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
    CancelShippingResponse a,
    CancelShippingResponse b,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'cancelShippingReference':
        return _compareStrings(a.cancelShippingReference, b.cancelShippingReference);
      case 'sourceGLN':
        return _compareStrings(a.sourceGLN, b.sourceGLN);
      case 'destinationGLN':
        return _compareStrings(a.destinationGLN, b.destinationGLN);
      case 'status':
        return _compareStrings(a.status?.name, b.status?.name);
      case 'cancelledEpcsCount':
        return (a.cancelledEpcsCount ?? 0).compareTo(b.cancelledEpcsCount ?? 0);
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
