import 'commissioning_failure_category.dart';

/// User-facing explanation of why partial success occurred for a category.
class CommissioningFailureCategoryInfo {
  const CommissioningFailureCategoryInfo({
    required this.category,
    required this.title,
    required this.explanation,
    required this.defaultRemoveFromOperation,
  });

  final CommissioningFailureCategory category;
  final String title;
  final String explanation;

  /// When true, failed serials in this category are pre-selected for removal.
  final bool defaultRemoveFromOperation;
}
