import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:traqtrace_app/features/automation_center/utils/notification_constants.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_enhanced_dropdown.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_multi_select_field.dart';

class SubscriptionAdvancedSection extends StatelessWidget {
  const SubscriptionAdvancedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Event Filtering (Advanced)'),
      subtitle: const Text('Configure which events trigger notifications'),
      children: [
        const SizedBox(height: 8),
        const SubscriptionMultiSelectField(
          name: 'eventTypes',
          label: 'Event Types',
          options: NotificationConstants.eventTypes,
          helperText: 'Select which EPCIS event types to monitor',
        ),
        const SizedBox(height: 12),
        const SubscriptionEnhancedDropdown(
          name: 'bizStep',
          label: 'Business Step',
          options: NotificationConstants.businessSteps,
          helperText: 'Filter by business process steps',
          isRequired: false,
        ),
        const SizedBox(height: 12),
        const SubscriptionEnhancedDropdown(
          name: 'disposition',
          label: 'Disposition',
          options: NotificationConstants.dispositions,
          helperText: 'Filter by item status or condition',
          isRequired: false,
        ),
        const SizedBox(height: 12),
        FormBuilderTextField(
          name: 'readPoint',
          decoration: const InputDecoration(
            labelText: 'Read Point (GLN)',
            hintText: 'https://id.gs1.org/414/0614141123452',
            border: OutlineInputBorder(),
            helperText: 'Specific location identifier (optional)',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            helperStyle: TextStyle(),
          ),
        ),
        const SizedBox(height: 12),
        FormBuilderTextField(
          name: 'epcPattern',
          decoration: const InputDecoration(
            labelText: 'EPC Pattern',
            hintText: 'https://id.gs1.org/01/*',
            border: OutlineInputBorder(),
            helperText: 'Filter by EPC patterns using wildcards (optional)',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            helperStyle: TextStyle(),
          ),
        ),
      ],
    );
  }
}
