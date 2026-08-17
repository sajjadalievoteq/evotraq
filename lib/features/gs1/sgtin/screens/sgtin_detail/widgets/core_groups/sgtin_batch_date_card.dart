import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_picker_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

class SgtinBatchDateCard extends StatelessWidget {
  const SgtinBatchDateCard({
    super.key,
    required this.borderColor,
    required this.isCreating,
    required this.onPickExpiry,
    required this.onPickProduction,
    required this.onPickBestBefore,
    required this.batchLotNumberController,
    this.expiryDate,
    this.productionDate,
    this.bestBeforeDate,
    this.expiryDateTime,
    this.lockDatesFromBatch = false,
    this.showRegistrationFields = false,
    this.quantityController,
    this.onRegister,
    this.isRegistering = false,
    this.setFieldError,
    this.onBatchLotEditingComplete,
    this.onBatchLotFocusLost,
    this.batchStatusPanel,
  });

  final Color borderColor;
  final bool isCreating;
  final VoidCallback onPickExpiry;
  final VoidCallback onPickProduction;
  final VoidCallback onPickBestBefore;
  final TextEditingController batchLotNumberController;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  final DateTime? expiryDateTime;
  final bool lockDatesFromBatch;
  final bool showRegistrationFields;
  final TextEditingController? quantityController;
  final VoidCallback? onRegister;
  final bool isRegistering;
  final void Function(String, String?)? setFieldError;
  final VoidCallback? onBatchLotEditingComplete;
  final VoidCallback? onBatchLotFocusLost;
  final Widget? batchStatusPanel;

  @override
  Widget build(BuildContext context) {
    final canEditDates = isCreating && !lockDatesFromBatch;
    final quantity = quantityController;
    final statusPanel = batchStatusPanel;
    return Gs1GroupCard(
      title: 'Batch & Date Information',
      showRequiredStar: true,
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) onBatchLotFocusLost?.call();
            },
            child: Gs1ValidatedField(
              controller: batchLotNumberController,
              fieldName: 'batchLotNumber',
              label: 'Batch / Lot Number *',
              readOnly: !isCreating,
              validator: sgtin_validators.validateBatchLotNumber,
              setFieldError: setFieldError,
              onEditingComplete: onBatchLotEditingComplete,
            ),
          ),
          if (statusPanel != null) ...[const SizedBox(height: 12), statusPanel],
          const SizedBox(height: 12),
          Gs1DatePickerField(
            label: isCreating ? 'Manufacture Date *' : 'Production Date',
            value: productionDate,
            helperText: lockDatesFromBatch
                ? 'From Batch Master'
                : (showRegistrationFields
                      ? 'Required to register this batch'
                      : null),
            onTap: canEditDates ? onPickProduction : null,
          ),
          const SizedBox(height: 12),
          Gs1DatePickerField(
            label: 'Expiry Date *',
            value: expiryDate,
            helperText: lockDatesFromBatch
                ? 'From Batch Master'
                : (showRegistrationFields
                      ? 'Required to register this batch'
                      : null),
            onTap: canEditDates ? onPickExpiry : null,
          ),
          if (showRegistrationFields && quantity != null) ...[
            const SizedBox(height: 12),
            Gs1ValidatedField(
              controller: quantity,
              fieldName: 'quantityManufactured',
              label: 'Quantity Manufactured',
              hintText: 'Optional',
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 12),
          Gs1DatePickerField(
            label: 'Best Before Date',
            value: bestBeforeDate,
            onTap: isCreating ? onPickBestBefore : null,
          ),
          if (expiryDateTime != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow('Extended Expiry', sgtinFormatDt(expiryDateTime)),
          ],
          if (onRegister != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isRegistering ? null : onRegister,
              icon: const TraqIcon(AppAssets.iconPlus),
              label: const Text('Register Batch'),
            ),
          ],
        ],
      ),
    );
  }
}
