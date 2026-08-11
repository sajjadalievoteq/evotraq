import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class PreferredTimeField extends StatelessWidget {
  const PreferredTimeField({super.key});

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<TimeOfDay>(
      name: 'preferredTime',
      builder: (field) {
        final selected = field.value;
        return InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: selected ?? const TimeOfDay(hour: 9, minute: 0),
            );
            if (picked != null) field.didChange(picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Preferred Delivery Time',
              helperText: 'The time of day deliveries should go out',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: Icon(Icons.access_time),
            ),
            child: Text(selected?.format(context) ?? 'Not set (uses default)'),
          ),
        );
      },
    );
  }
}
