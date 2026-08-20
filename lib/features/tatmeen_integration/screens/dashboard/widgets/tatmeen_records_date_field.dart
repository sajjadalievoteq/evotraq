part of '../tatmeen_records_screen.dart';

class TatmeenRecordsDateField extends StatelessWidget {
  const TatmeenRecordsDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedDate = value;
    return SizedBox(
      width: 180,
      height: 40,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: selectedDate == null
                ? const TraqIcon(AppAssets.iconClock, size: 14)
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: () => onChanged(null),
                    icon: const TraqIcon(AppAssets.iconX, size: 16),
                  ),
          ),
          child: Text(
            selectedDate == null
                ? 'Select date'
                : DisplayDateUtils.dmy(selectedDate),
          ),
        ),
      ),
    );
  }
}
