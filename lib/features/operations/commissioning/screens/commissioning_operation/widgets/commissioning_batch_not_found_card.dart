import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_status_container.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_date_picker_row.dart';

class CommissioningBatchNotFoundCard extends StatelessWidget {
  const CommissioningBatchNotFoundCard({
    required this.batchLot,
    required this.errorMessage,
    required this.registrationPanelExpanded,
    required this.registrationExpiryDate,
    required this.registrationManufactureDate,
    required this.registrationQuantityController,
    required this.onSelectRegistrationDate,
    required this.onClearRegistrationDate,
    required this.onRegisterBatch,
    required this.onToggleRegistrationPanel,
    required this.isRegistering,
    super.key,
  });

  final String batchLot;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommissioningBatchStatusContainer(
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
            child: Text(registrationPanelExpanded ? 'Hide' : 'Register Batch'),
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
                : const TraqIcon(AppAssets.iconPlus),
            label: const Text('Register Batch'),
          ),
        ],
      ],
    );
  }
}
