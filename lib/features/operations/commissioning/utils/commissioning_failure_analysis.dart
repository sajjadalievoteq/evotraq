import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_failure_category.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_failure_category_info.dart';

CommissioningFailureCategory categorizeCommissioningError(String? message) {
  final m = (message ?? '').toLowerCase();
  if (m.contains('duplicate serial') ||
      m.contains('duplicate_serial') ||
      m.contains('already active for gtin')) {
    return CommissioningFailureCategory.duplicateSerial;
  }
  if (m.contains('already commissioned') ||
      m.contains('epc already commissioned') ||
      m.contains('serial number reuse') ||
      m.contains('terminal state') ||
      m.contains('terminal status')) {
    return CommissioningFailureCategory.alreadyCommissioned;
  }
  if (m.contains('serial number must') ||
      m.contains('file-7') ||
      m.contains('invalid serial') ||
      m.contains('serial_low_entropy')) {
    return CommissioningFailureCategory.invalidSerial;
  }
  if (m.contains('epcis') || m.contains('objectevent')) {
    return CommissioningFailureCategory.epcis;
  }
  if (m.contains('validation') ||
      m.contains('required') ||
      m.contains('must be') ||
      m.contains('invalid')) {
    return CommissioningFailureCategory.validation;
  }
  return CommissioningFailureCategory.other;
}

CommissioningFailureCategoryInfo categoryInfo(
  CommissioningFailureCategory category,
) {
  switch (category) {
    case CommissioningFailureCategory.duplicateSerial:
      return const CommissioningFailureCategoryInfo(
        category: CommissioningFailureCategory.duplicateSerial,
        title: 'Duplicate serial in this batch',
        explanation:
            'The same serial appears more than once in the request, or another active '
            'SGTIN already exists for this GTIN and serial.',
        defaultRemoveFromOperation: true,
      );
    case CommissioningFailureCategory.alreadyCommissioned:
      return const CommissioningFailureCategoryInfo(
        category: CommissioningFailureCategory.alreadyCommissioned,
        title: 'Already commissioned or not reusable',
        explanation:
            'These serials were previously commissioned, are linked to an EPCIS event, '
            'or are in a terminal lifecycle state and cannot be commissioned again.',
        defaultRemoveFromOperation: true,
      );
    case CommissioningFailureCategory.invalidSerial:
      return const CommissioningFailureCategoryInfo(
        category: CommissioningFailureCategory.invalidSerial,
        title: 'Invalid serial format',
        explanation:
            'Serial numbers must be 1–20 characters using the GS1 file-7 character set. '
            'Fix the value or remove the serial from this operation.',
        defaultRemoveFromOperation: false,
      );
    case CommissioningFailureCategory.validation:
      return const CommissioningFailureCategoryInfo(
        category: CommissioningFailureCategory.validation,
        title: 'Validation rule failed',
        explanation:
            'Business or GS1 validation rejected these items. Review the message, correct '
            'the data if possible, or remove the serial from this operation.',
        defaultRemoveFromOperation: false,
      );
    case CommissioningFailureCategory.epcis:
      return const CommissioningFailureCategoryInfo(
        category: CommissioningFailureCategory.epcis,
        title: 'EPCIS event could not be created',
        explanation:
            'The SGTIN rows may have been created but the commissioning EPCIS event failed. '
            'Remove affected serials or retry after resolving the backend issue.',
        defaultRemoveFromOperation: false,
      );
    case CommissioningFailureCategory.other:
      return const CommissioningFailureCategoryInfo(
        category: CommissioningFailureCategory.other,
        title: 'Other errors',
        explanation:
            'These items failed for an unexpected reason. Review each message and decide '
            'whether to remove the serial or retry.',
        defaultRemoveFromOperation: true,
      );
  }
}

Map<CommissioningFailureCategory, List<CommissioningItemResult>>
groupFailedCommissioningResults(List<CommissioningItemResult> results) {
  final failed = results.where((r) => !r.success).toList();
  final grouped = <CommissioningFailureCategory, List<CommissioningItemResult>>{};
  for (final item in failed) {
    final category = categorizeCommissioningError(item.errorMessage);
    grouped.putIfAbsent(category, () => []).add(item);
  }
  return grouped;
}
