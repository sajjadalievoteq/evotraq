import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';

class DecommissioningOperationListFilter {
  DecommissioningOperationListFilter._();

  static List<DecommissioningResponse> apply({
    required List<DecommissioningResponse> operations,
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

  static int _compareByField(
    DecommissioningResponse a,
    DecommissioningResponse b,
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
}
