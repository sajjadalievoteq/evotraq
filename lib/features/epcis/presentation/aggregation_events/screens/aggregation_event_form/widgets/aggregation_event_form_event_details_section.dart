import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class AggregationEventFormEventDetailsSection extends StatelessWidget {
  const AggregationEventFormEventDetailsSection({
    super.key,
    required this.selectedAction,
    required this.eventTime,
    required this.onActionChanged,
    required this.onSelectEventTime,
  });

  final String selectedAction;
  final DateTime eventTime;
  final ValueChanged<String?> onActionChanged;
  final VoidCallback onSelectEventTime;

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Event Details',
      showTitleRequiredIndicator: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Action *',
              border: OutlineInputBorder(),
              helperText:
                  'ADD = pack items into container · OBSERVE = record state · DELETE = unpack',
            ),
            value: selectedAction,
            items: ['ADD', 'OBSERVE', 'DELETE']
                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                .toList(),
            onChanged: onActionChanged,
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Please select an action' : null,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onSelectEventTime,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Event Time *',
                border: OutlineInputBorder(),
                suffixIcon: TraqIcon(AppAssets.iconClock),
                helperText: 'When the aggregation event occurred',
              ),
              child: Text(DateFormat.yMd().add_Hms().format(eventTime)),
            ),
          ),
        ],
      ),
    );
  }
}
