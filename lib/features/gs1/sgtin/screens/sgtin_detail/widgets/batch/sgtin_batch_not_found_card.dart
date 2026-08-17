import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_state.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/batch/sgtin_batch_status_container.dart';

class SgtinBatchNotFoundCard extends StatelessWidget {
  const SgtinBatchNotFoundCard({
    required this.batchLot,
    required this.state,
    super.key,
  });

  final String batchLot;
  final SgtinBatchState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SgtinBatchStatusContainer(
          outline: theme.colorScheme.tertiary.withValues(alpha: 0.45),
          icon: TraqIcon(
            AppAssets.iconAlert,
            color: theme.colorScheme.tertiary,
            size: 20,
          ),
          title: 'Batch not found in Batch Master',
          subtitle:
              'Lot: $batchLot. Fill manufacture date, expiry, and quantity below, then tap Register Batch.',
        ),
        if (state.error != null && state.error!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            state.error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
