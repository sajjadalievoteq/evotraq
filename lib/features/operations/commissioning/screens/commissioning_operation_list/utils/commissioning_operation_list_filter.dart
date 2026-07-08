import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';

class CommissioningOperationListFilter {
  CommissioningOperationListFilter._();

  static List<Operation> applyToOperations({
    required List<Operation> operations,
    required String query,
    String? statusFilter,
  }) {
    final normalizedQuery = query.toLowerCase().trim();

    return operations.where((operation) {
      if (statusFilter != null &&
          (operation.commissioningBatchStatus ?? '') != statusFilter) {
        return false;
      }

      if (normalizedQuery.isEmpty) return true;

      return (operation.operationReference
                  ?.toLowerCase()
                  .contains(normalizedQuery) ??
              false) ||
          (operation.gtinCode?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.batchLotNumber?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.primaryGln?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (operation.operationId?.toLowerCase().contains(normalizedQuery) ??
              false);
    }).toList();
  }
}
