import 'package:flutter/material.dart';

/// Placeholder shown when no Receiving operation is selected in split view.
class ReceivingDetailAwaitingSelection extends StatelessWidget {
  const ReceivingDetailAwaitingSelection({
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
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a Receiving operation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
