import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_date_picker_row.dart';

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
      CommissioningBatchLookupStatus.lookingUp => _statusContainer(
          context,
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
        _successCard(context, resolvedBatch, batchLot),
      CommissioningBatchLookupStatus.notFound => _notFoundCard(context),
      CommissioningBatchLookupStatus.registering => _statusContainer(
          context,
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
      CommissioningBatchLookupStatus.error => _statusContainer(
          context,
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

  Widget _successCard(
    BuildContext context,
    GtinBatch? batch,
    String lot,
  ) {
    final theme = Theme.of(context);
    final expiry = batch?.expiryDate;
    return _statusContainer(
      context,
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

  Widget _notFoundCard(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _statusContainer(
          context,
          outline: theme.colorScheme.tertiary.withValues(alpha: 0.45),
          icon: TraqIcon(
            AppAssets.iconAlert,
            color: theme.colorScheme.tertiary,
            size: 20,
          ),
          title: 'Batch not found in Batch Master',
          subtitle: 'Lot: $batchLot',
          trailing: TextButton(
            onPressed: () =>
                onToggleRegistrationPanel(!registrationPanelExpanded),
            child: Text(
              registrationPanelExpanded ? 'Hide' : 'Register Batch',
            ),
          ),
        ),
        if (errorMessage != null && errorMessage!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (registrationPanelExpanded) ...[
          const SizedBox(height: 12),
          CommissioningDatePickerRow(
            label: 'Expiry Date *',
            dateKey: 'registrationExpiry',
            value: registrationExpiryDate,
            onSelect: onSelectRegistrationDate,
            onClear: onClearRegistrationDate,
            allowClear: false,
          ),
          const SizedBox(height: 12),
          CommissioningDatePickerRow(
            label: 'Manufacture Date',
            dateKey: 'registrationManufacture',
            value: registrationManufactureDate,
            onSelect: onSelectRegistrationDate,
            onClear: onClearRegistrationDate,
          ),
          const SizedBox(height: 12),
          Gs1ValidatedField(
            controller: registrationQuantityController,
            fieldName: 'quantityManufactured',
            label: 'Quantity Manufactured',
            hintText: 'Optional',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isRegistering ? null : onRegisterBatch,
            icon: isRegistering
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : TraqIcon(AppAssets.iconPlus),
            label: const Text('Register Batch'),
          ),
        ],
      ],
    );
  }

  Widget _statusContainer(
    BuildContext context, {
    required Color outline,
    required Widget icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: outline),
        color: theme.colorScheme.surfaceContainerLowest,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
