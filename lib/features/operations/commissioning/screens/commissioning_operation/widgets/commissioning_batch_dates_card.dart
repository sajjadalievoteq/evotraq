import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_date_picker_row.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_lookup_status.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_state.dart';

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
    this.batchLookupState = const SgtinBatchState(),
  });

  final TextEditingController batchLotController;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<String> onClearDate;
  final bool requireExpiry;
  final SgtinBatchState batchLookupState;

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
          if (batchLotController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _BatchLookupMessage(state: batchLookupState),
          ],
          const SizedBox(height: 16),
          CommissioningDatePickerRow(
            label: requireExpiry
                ? 'Lot Manufacturing Date *'
                : 'Lot Manufacturing Date',
            dateKey: 'production',
            value: productionDate,
            onSelect: batchLookupState.status.isResolved
                ? (_) {}
                : onSelectDate,
            onClear: batchLookupState.status.isResolved ? (_) {} : onClearDate,
            allowClear: !requireExpiry && !batchLookupState.status.isResolved,
          ),
          const SizedBox(height: 12),
          CommissioningDatePickerRow(
            label: requireExpiry ? 'Expiry Date *' : 'Expiry Date',
            dateKey: 'expiry',
            value: expiryDate,
            onSelect: batchLookupState.status.isResolved
                ? (_) {}
                : onSelectDate,
            onClear: batchLookupState.status.isResolved ? (_) {} : onClearDate,
            allowClear: !requireExpiry && !batchLookupState.status.isResolved,
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

class _BatchLookupMessage extends StatelessWidget {
  const _BatchLookupMessage({required this.state});

  final SgtinBatchState state;

  @override
  Widget build(BuildContext context) {
    final (icon, color, message) = switch (state.status) {
      SgtinBatchLookupStatus.lookingUp => (
        Icons.sync,
        Theme.of(context).colorScheme.primary,
        'Checking batch master data…',
      ),
      SgtinBatchLookupStatus.found || SgtinBatchLookupStatus.registered => (
        Icons.check_circle_outline,
        Colors.green,
        'Existing batch found. Batch dates were filled automatically.',
      ),
      SgtinBatchLookupStatus.notFound => (
        Icons.add_circle_outline,
        Theme.of(context).colorScheme.primary,
        'New batch. Enter its manufacturing and expiry dates below.',
      ),
      SgtinBatchLookupStatus.error => (
        Icons.error_outline,
        Theme.of(context).colorScheme.error,
        state.error ?? 'Could not check batch master data.',
      ),
      _ => (Icons.info_outline, Colors.grey, 'Enter a batch/lot number.'),
    };
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: TextStyle(color: color)),
        ),
      ],
    );
  }
}
