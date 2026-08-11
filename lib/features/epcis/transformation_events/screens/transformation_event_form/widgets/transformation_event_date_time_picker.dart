import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class TransformationEventDateTimePicker extends StatelessWidget {
  const TransformationEventDateTimePicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const TraqIcon(AppAssets.iconClock),
            label: Text(DateFormat('yyyy-MM-dd').format(value)),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: value,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (pickedDate != null) {
                onChanged(
                  DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    value.hour,
                    value.minute,
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const TraqIcon(AppAssets.iconClock),
            label: Text(DateFormat('HH:mm').format(value)),
            onPressed: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(value),
              );
              if (pickedTime != null) {
                onChanged(
                  DateTime(
                    value.year,
                    value.month,
                    value.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
