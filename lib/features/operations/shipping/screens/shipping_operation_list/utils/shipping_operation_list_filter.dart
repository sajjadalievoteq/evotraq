import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';

class ShippingOperationListFilter {
  ShippingOperationListFilter._();

  static List<ShippingResponse> apply({
    required List<ShippingResponse> operations,
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

      return (operation.shippingReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.sourceGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.destinationGLN?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.trackingNumber?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.shippingOperationId
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
      if (statusFilter != null && (operation.status?.name ?? '') != statusFilter) {
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
          (operation.destinationGLN?.toLowerCase().contains(normalizedQuery) ??
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
    ShippingResponse a,
    ShippingResponse b,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'shippingReference':
        return _compareStrings(a.shippingReference, b.shippingReference);
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

  static int _compareOperationsByField(
    Operation a,
    Operation b,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'shippingReference':
        return _compareStrings(a.operationReference, b.operationReference);
      case 'sourceGLN':
        return _compareStrings(a.sourceGLN, b.sourceGLN);
      case 'destinationGLN':
        return _compareStrings(a.destinationGLN, b.destinationGLN);
      case 'status':
        return _compareStrings(a.status?.name, b.status?.name);
      case 'shippedEpcsCount':
        return a.itemCount.compareTo(b.itemCount);
      case 'processedAt':
      default:
        final aDate = a.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
    }
  }
}
