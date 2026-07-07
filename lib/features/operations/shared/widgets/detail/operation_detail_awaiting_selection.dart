import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

/// Shared awaiting-selection placeholder for operation detail screens.
/// Replaces: ShippingDetailAwaitingSelection, ReceivingDetailAwaitingSelection, etc.
class OperationDetailAwaitingSelection extends StatelessWidget {
  const OperationDetailAwaitingSelection({
    super.key,
    required this.operationLabel,
    this.iconAsset = AppAssets.iconPackage,
    this.listLoading = false,
  });

  final String operationLabel;
  final String iconAsset;
  final bool listLoading;

  @override
  Widget build(BuildContext context) {
    if (listLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(
            iconAsset,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a $operationLabel operation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
