import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:traqtrace_app/features/automation_center/utils/notification_constants.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_multi_select_field.dart';

class SubscriptionAdvancedSection extends StatelessWidget {
  const SubscriptionAdvancedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('Event filters'),
      subtitle: const Text('Choose which EPCIS events trigger delivery'),
      children: [
        const SizedBox(height: 8),
        const SubscriptionMultiSelectField(
          name: 'operationTypes',
          label: 'Operations',
          options: NotificationConstants.operationTypes,
          helperText: 'Select which supply-chain operations to monitor',
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