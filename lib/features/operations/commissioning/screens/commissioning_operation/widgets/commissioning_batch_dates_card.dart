import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
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
    this.requireExpiry = false,
  });

  final TextEditingController batchLotController;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<String> onClearDate;
  final bool requireExpiry;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return Gs1GroupCard(
      title: 'Batch & Dates',
      showRequiredStar: true,
      outlineColor: outline,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gs1ValidatedField(
            controller: batchLotController,
            fieldName: 'batchLotNumber',
            label: 'Batch/Lot Number *',
            hintText: 'Enter batch or lot number',
            validator:
                CommissioningFieldValidators.validateBatchLotNumberRequired,
          ),
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
            label: requireExpiry ? 'Expiry Date *' : 'Expiry Date',
            dateKey: 'expiry',
            value: expiryDate,
            onSelect: onSelectDate,
            onClear: onClearDate,
            allowClear: !requireExpiry,
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
