import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Placeholder shown when no Decommissioning operation is selected in split view.
class DecommissioningDetailAwaitingSelection extends StatelessWidget {
  const DecommissioningDetailAwaitingSelection({
    super.key,
    required this.listLoading,
  });

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
          TraqIcon(AppAssets.iconPackage,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a Decommissioning operation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
