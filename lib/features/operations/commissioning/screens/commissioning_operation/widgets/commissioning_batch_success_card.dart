import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_status_container.dart';

class CommissioningBatchSuccessCard extends StatelessWidget {
  const CommissioningBatchSuccessCard({
    required this.status,
    required this.batch,
    required this.lot,
    super.key,
  });

  final CommissioningBatchLookupStatus status;
  final GtinBatch? batch;
  final String lot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expiry = batch?.expiryDate;
    return CommissioningBatchStatusContainer(
      outline: theme.colorScheme.primary.withValues(alpha: 0.35),
      icon: TraqIcon(
        AppAssets.iconCheckCircle,
        color: theme.colorScheme.primary,
        size: 20,
      ),
      title: status == CommissioningBatchLookupStatus.registered
          ? 'Batch registered'
          : 'Batch found',
      subtitle: [
        'Lot: $lot',
        if (expiry != null && expiry.isNotEmpty) 'Expiry: $expiry',
      ].join('\n'),
    );
  }
}
