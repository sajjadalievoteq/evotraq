import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_lookup_status.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/batch/sgtin_batch_status_container.dart';

class SgtinBatchFoundCard extends StatelessWidget {
  const SgtinBatchFoundCard({
    required this.status,
    required this.batch,
    required this.lot,
    super.key,
  });

  final SgtinBatchLookupStatus status;
  final GtinBatch? batch;
  final String lot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final manufacture = batch?.manufactureDate;
    final expiry = batch?.expiryDate;
    final batchStatus = batch?.batchStatus;
    return SgtinBatchStatusContainer(
      outline: theme.colorScheme.primary.withValues(alpha: 0.35),
      icon: TraqIcon(
        AppAssets.iconCheckCircle,
        color: theme.colorScheme.primary,
        size: 20,
      ),
      title: status == SgtinBatchLookupStatus.registered
          ? 'Batch registered'
          : 'Batch found',
      subtitle: [
        'Lot: $lot',
        if (manufacture != null && manufacture.isNotEmpty)
          'Manufacture: $manufacture',
        if (expiry != null && expiry.isNotEmpty) 'Expiry: $expiry',
        if (batchStatus != null && batchStatus.isNotEmpty)
          'Status: $batchStatus',
      ].join('\n'),
    );
  }
}
