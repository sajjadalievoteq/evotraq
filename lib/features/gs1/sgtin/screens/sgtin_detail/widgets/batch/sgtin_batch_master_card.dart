import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_lookup_status.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_state.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/batch/sgtin_batch_found_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/batch/sgtin_batch_not_found_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/batch/sgtin_batch_status_container.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/batch/sgtin_batch_status_skeleton.dart';

class SgtinBatchMasterCard extends StatelessWidget {
  const SgtinBatchMasterCard({
    super.key,
    required this.state,
    required this.batchLot,
  });

  final SgtinBatchState state;
  final String batchLot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outlineVariant;

    return switch (state.status) {
      SgtinBatchLookupStatus.idle =>
        batchLot.trim().isEmpty
            ? const SizedBox.shrink()
            : SgtinBatchStatusContainer(
                outline: outline,
                icon: TraqIcon(
                  AppAssets.iconAlert,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
                title: state.gtinId == null
                    ? 'Select a GTIN to look up this batch'
                    : 'Waiting to look up batch in Batch Master',
                subtitle: state.gtinId == null
                    ? 'Lot: $batchLot. Choose a saved GTIN first, then TraqTrace will check Batch Master and let you register the lot if it is missing.'
                    : 'Lot: $batchLot',
              ),
      SgtinBatchLookupStatus.lookingUp => const SgtinBatchStatusSkeleton(),
      SgtinBatchLookupStatus.found ||
      SgtinBatchLookupStatus.registered => SgtinBatchFoundCard(
        status: state.status,
        batch: state.resolvedBatch,
        lot: batchLot,
      ),
      SgtinBatchLookupStatus.notFound => SgtinBatchNotFoundCard(
        batchLot: batchLot,
        state: state,
      ),
      SgtinBatchLookupStatus.registering => const SgtinBatchStatusSkeleton(),
      SgtinBatchLookupStatus.error => SgtinBatchStatusContainer(
        outline: theme.colorScheme.error.withValues(alpha: 0.4),
        icon: TraqIcon(
          AppAssets.iconAlert,
          color: theme.colorScheme.error,
          size: 20,
        ),
        title: 'Batch lookup failed',
        subtitle: state.error ?? 'Could not verify batch in Batch Master.',
      ),
    };
  }
}
