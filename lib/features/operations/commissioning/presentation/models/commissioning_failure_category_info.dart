import 'commissioning_failure_category.dart';

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

  final bool defaultRemoveFromOperation;
}
