import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_date_picker_row.dart';

class CommissioningDatesCard extends StatelessWidget {
  const CommissioningDatesCard({
    super.key,
    required this.productionDate,
    required this.expiryDate,
    required this.bestBeforeDate,
    required this.onSelectDate,
    required this.onClearDate,
  });

  final DateTime? productionDate;
  final DateTime? expiryDate;
  final DateTime? bestBeforeDate;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<String> onClearDate;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Dates',
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        children: [
          CommissioningDatePickerRow(
            label: 'Production Date',
            dateKey: 'production',
            value: productionDate,
            onSelect: onSelectDate,
            onClear: onClearDate,
          ),
          const SizedBox(height: 12),
          CommissioningDatePickerRow(
            label: 'Expiry Date *',
            dateKey: 'expiry',
            value: expiryDate,
            onSelect: onSelectDate,
            onClear: onClearDate,
            allowClear: false,
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
