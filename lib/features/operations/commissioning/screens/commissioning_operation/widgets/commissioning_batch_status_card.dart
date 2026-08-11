import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_not_found_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_status_container.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_success_card.dart';

class CommissioningBatchStatusCard extends StatelessWidget {
  const CommissioningBatchStatusCard({
    super.key,
    required this.status,
    required this.batchLot,
    this.resolvedBatch,
    this.errorMessage,
    required this.registrationPanelExpanded,
    required this.registrationExpiryDate,
    required this.registrationManufactureDate,
    required this.registrationQuantityController,
    required this.onSelectRegistrationDate,
    required this.onClearRegistrationDate,
    required this.onRegisterBatch,
    required this.onToggleRegistrationPanel,
    this.isRegistering = false,
  });

  final CommissioningBatchLookupStatus status;
  final String batchLot;
  final GtinBatch? resolvedBatch;
  final String? errorMessage;
  final bool registrationPanelExpanded;
  final DateTime? registrationExpiryDate;
  final DateTime? registrationManufactureDate;
  final TextEditingController registrationQuantityController;
  final ValueChanged<String> onSelectRegistrationDate;
  final ValueChanged<String> onClearRegistrationDate;
  final VoidCallback onRegisterBatch;
  final ValueChanged<bool> onToggleRegistrationPanel;
  final bool isRegistering;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outlineVariant;

    return switch (status) {
      CommissioningBatchLookupStatus.idle => const SizedBox.shrink(),
      CommissioningBatchLookupStatus.lookingUp =>
        CommissioningBatchStatusContainer(
          outline: outline,
          icon: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          title: 'Looking up batch in Batch Master…',
          subtitle: 'Lot: $batchLot',
        ),
      CommissioningBatchLookupStatus.found ||
      CommissioningBatchLookupStatus.registered =>
        CommissioningBatchSuccessCard(
          status: status,
          batch: resolvedBatch,
          lot: batchLot,
        ),
      CommissioningBatchLookupStatus.notFound => CommissioningBatchNotFoundCard(
        batchLot: batchLot,
        errorMessage: errorMessage,
        registrationPanelExpanded: registrationPanelExpanded,
        registrationExpiryDate: registrationExpiryDate,
        registrationManufactureDate: registrationManufactureDate,
        registrationQuantityController: registrationQuantityController,
        onSelectRegistrationDate: onSelectRegistrationDate,
        onClearRegistrationDate: onClearRegistrationDate,
        onRegisterBatch: onRegisterBatch,
        onToggleRegistrationPanel: onToggleRegistrationPanel,
        isRegistering: isRegistering,
      ),
      CommissioningBatchLookupStatus.registering =>
        CommissioningBatchStatusContainer(
          outline: outline,
          icon: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          title: 'Registering batch…',
          subtitle: 'Lot: $batchLot',
        ),
      CommissioningBatchLookupStatus.error => CommissioningBatchStatusContainer(
        outline: theme.colorScheme.error.withValues(alpha: 0.4),
        icon: TraqIcon(
          AppAssets.iconAlert,
          color: theme.colorScheme.error,
          size: 20,
        ),
        title: 'Batch lookup failed',
        subtitle: errorMessage ?? 'Could not verify batch. You may continue.',
      ),
    };
  }
}
