import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

class OperationStepConfig {
  const OperationStepConfig({
    required this.label,
    required this.iconAsset,
  });

  final String label;
  final String iconAsset;

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
    iconAsset: NavIcons.packaging,
  );
  static const serials = OperationStepConfig(
    label: 'Serials',
    iconAsset: NavIcons.sgtin,
  );
}
