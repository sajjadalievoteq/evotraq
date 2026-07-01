import 'package:traqtrace_app/core/config/app_assets.dart';

/// Configuration for a single step in an operation wizard stepper.
class OperationStepConfig {
  const OperationStepConfig({
    required this.label,
    required this.iconAsset,
  });

  final String label;
  final String iconAsset;

  /// Wizard steps shared by most logistics / lifecycle operations.
  static const details = OperationStepConfig(
    label: 'Details',
    iconAsset: AppAssets.iconPin,
  );
  static const items = OperationStepConfig(
    label: 'Items',
    iconAsset: AppAssets.iconList,
  );
  static const review = OperationStepConfig(
    label: 'Review',
    iconAsset: AppAssets.iconCheck,
  );
  static const product = OperationStepConfig(
    label: 'Product',
    iconAsset: AppAssets.iconPackage,
  );
  static const serials = OperationStepConfig(
    label: 'Serials',
    iconAsset: AppAssets.iconSgtin,
  );
}
