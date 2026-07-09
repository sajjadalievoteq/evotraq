import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_status_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_date_picker_row.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';

class CommissioningBatchDatesCard extends StatelessWidget {
  const CommissioningBatchDatesCard({
    super.key,
    required this.batchLotController,
    required this.expiryDate,
    required this.productionDate,
    required this.bestBeforeDate,
    required this.onSelectDate,
    required this.onClearDate,
    required this.onBatchLotEditingComplete,
    required this.onBatchLotFocusLost,
    required this.registrationQuantityController,
    required this.onSelectRegistrationDate,
    required this.onClearRegistrationDate,
    required this.onRegisterBatch,
    required this.onToggleRegistrationPanel,
    this.showPharmaBatchLookup = false,
    this.batchLookupStatus = CommissioningBatchLookupStatus.idle,
    this.resolvedBatch,
    this.batchLookupError,
    this.registrationPanelExpanded = false,
    this.registrationExpiryDate,
    this.registrationManufactureDate,
    this.isBatchRegistering = false,
  });

  final TextEditingController batchLotController;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<String> onClearDate;
  final VoidCallback onBatchLotEditingComplete;
  final VoidCallback onBatchLotFocusLost;
  final TextEditingController registrationQuantityController;
  final ValueChanged<String> onSelectRegistrationDate;
  final ValueChanged<String> onClearRegistrationDate;
  final VoidCallback onRegisterBatch;
  final ValueChanged<bool> onToggleRegistrationPanel;

  final bool showPharmaBatchLookup;
  final CommissioningBatchLookupStatus batchLookupStatus;
  final GtinBatch? resolvedBatch;
  final String? batchLookupError;
  final bool registrationPanelExpanded;
  final DateTime? registrationExpiryDate;
  final DateTime? registrationManufactureDate;
  final bool isBatchRegistering;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final batchLot = batchLotController.text.trim();

    return Gs1GroupCard(
      title: 'Batch & Dates',
      showRequiredStar: true,
      outlineColor: outline,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) onBatchLotFocusLost();
            },
            child: Gs1ValidatedField(
              controller: batchLotController,
              fieldName: 'batchLotNumber',
              label: 'Batch/Lot Number *',
              hintText: 'Enter batch or lot number',
              validator:
                  CommissioningFieldValidators.validateBatchLotNumberRequired,
              onEditingComplete: onBatchLotEditingComplete,
            ),
          ),
          if (showPharmaBatchLookup && batchLot.isNotEmpty) ...[
            const SizedBox(height: 12),
            CommissioningBatchStatusCard(
              status: batchLookupStatus,
              batchLot: batchLot,
              resolvedBatch: resolvedBatch,
              errorMessage: batchLookupError,
              registrationPanelExpanded: registrationPanelExpanded,
              registrationExpiryDate: registrationExpiryDate,
              registrationManufactureDate: registrationManufactureDate,
              registrationQuantityController: registrationQuantityController,
              onSelectRegistrationDate: onSelectRegistrationDate,
              onClearRegistrationDate: onClearRegistrationDate,
              onRegisterBatch: onRegisterBatch,
              onToggleRegistrationPanel: onToggleRegistrationPanel,
              isRegistering: isBatchRegistering,
            ),
          ],
          const SizedBox(height: 16),
          CommissioningDatePickerRow(
            label: 'Production Date',
            dateKey: 'production',
            value: productionDate,
            onSelect: onSelectDate,
            onClear: onClearDate,
          ),
          const SizedBox(height: 12),
          CommissioningDatePickerRow(
            label: showPharmaBatchLookup ? 'Expiry Date *' : 'Expiry Date',
            dateKey: 'expiry',
            value: expiryDate,
            onSelect: onSelectDate,
            onClear: onClearDate,
            allowClear: !showPharmaBatchLookup,
          ),
          const SizedBox(height: 12),
          CommissioningDatePickerRow(
            label: 'Best Before Date',
            dateKey: 'bestBefore',
            value: bestBeforeDate,
            onSelect: onSelectDate,
            onClear: onClearDate,
          ),
        ],
      ),
    );
  }
}
