import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:traqtrace_app/features/automation_center/utils/notification_constants.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_format_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_advanced_section.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_dropdown_section.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/preferred_time_field.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_auth_password_field.dart';

class CreateSubscriptionFormFields extends StatelessWidget {
  const CreateSubscriptionFormFields({
    super.key,
    required this.selectedDeliveryMethod,
    required this.onDeliveryMethodChanged,
    required this.selectedSubscriptionType,
    required this.onSubscriptionTypeChanged,
    required this.selectedNotificationFrequency,
    required this.onNotificationFrequencyChanged,
    this.isEditing = false,
  });

  final String selectedDeliveryMethod;
  final ValueChanged<String> onDeliveryMethodChanged;

  /// True when editing an existing subscription — used to adjust the API
  /// password field's copy (leaving it blank on edit keeps the saved
  /// credential rather than clearing it).
  final bool isEditing;

  /// Tracked so the batch-cadence dropdown can be shown/hidden and given a
  /// sensible type-based default without needing a separate form rebuild.
  final String selectedSubscriptionType;
  final ValueChanged<String> onSubscriptionTypeChanged;

  /// Tracked so the time-of-day picker only shows for cadences where a
  /// specific time actually means something (DAILY/WEEKLY/MONTHLY — not
  /// IMMEDIATE/HOURLY, which repeat too often for a "time of day" to apply).
  final String? selectedNotificationFrequency;
  final ValueChanged<String> onNotificationFrequencyChanged;

  bool get _showsCadence =>
      selectedSubscriptionType == 'BATCH' ||
      selectedSubscriptionType == 'SCHEDULED';

  bool get _showsPreferredTime =>
      _showsCadence &&
      (selectedNotificationFrequency == 'DAILY' ||
          selectedNotificationFrequency == 'WEEKLY' ||
          selectedNotificationFrequency == 'MONTHLY');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FormBuilderTextField(
          name: 'subscriptionName',
          decoration: const InputDecoration(
            labelText: 'Subscription Name',
            hintText: 'Enter a descriptive name',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.minLength(3),
          ]),
        ),
        const SizedBox(height: 12),
        SubscriptionDropdownSection<String>(
          name: 'deliveryMethod',
          label: 'Delivery Method',
          options: NotificationConstants.deliveryMethods,
          validator: FormBuilderValidators.required(),
          onChanged: (value) {
            if (value != null) onDeliveryMethodChanged(value);
          },
        ),
        const SizedBox(height: 12),
        if (selectedDeliveryMethod == 'WEBHOOK') ...[
          FormBuilderTextField(
            key: const ValueKey('webhookUrl'),
            name: 'webhookUrl',
            decoration: const InputDecoration(
              labelText: 'API Endpoint URL',
              hintText: 'https://your-api.com/api/notifications',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              helperText: 'HTTP endpoint that will receive POST requests',
              helperStyle: TextStyle(),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.url(),
            ]),
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            key: const ValueKey('webhookAuthUsername'),
            name: 'webhookAuthUsername',
            decoration: const InputDecoration(
              labelText: 'API Username (optional)',
              hintText: 'Leave blank if the API needs no authentication',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              helperText:
                  'Sent as HTTP Basic Auth if the destination API requires it',
              helperStyle: TextStyle(),
            ),
          ),
          const SizedBox(height: 12),
          SubscriptionAuthPasswordField(
            name: 'webhookAuthPassword',
            labelText: 'API Password (optional)',
            hintText: isEditing
                ? 'Leave blank to keep the saved password'
                : 'Leave blank if the API needs no authentication',
            helperText: isEditing
                ? 'Only fill in to set a new password'
                : 'Sent as HTTP Basic Auth if the destination API requires it',
          ),
        ] else
          FormBuilderTextField(
            key: const ValueKey('emailAddress'),
            name: 'emailAddress',
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'your.email@company.com',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              helperText: 'Email address to receive notifications',
              helperStyle: TextStyle(),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.email(),
            ]),
          ),
        const SizedBox(height: 12),
        SubscriptionDropdownSection<String>(
          name: 'subscriptionType',
          label: 'Subscription Type',
          options: NotificationConstants.subscriptionTypes,
          validator: FormBuilderValidators.required(),
          onChanged: (value) {
            if (value != null) onSubscriptionTypeChanged(value);
          },
        ),
        const SizedBox(height: 12),
        if (_showsCadence) ...[
          SubscriptionDropdownSection<String>(
            key: ValueKey('notificationFrequency_$selectedSubscriptionType'),
            name: 'notificationFrequency',
            label: 'Delivery Cadence',
            options: NotificationConstants.notificationFrequencies,
            validator: FormBuilderValidators.required(),
            onChanged: (value) {
              if (value != null) onNotificationFrequencyChanged(value);
            },
          ),
          const SizedBox(height: 12),
        ],
        if (_showsPreferredTime) ...[
          const PreferredTimeField(),
          const SizedBox(height: 12),
        ],
        FormBuilderDropdown<String>(
          key: ValueKey('notificationFormat_$selectedDeliveryMethod'),
          name: 'notificationFormat',
          decoration: const InputDecoration(
            labelText: 'Notification Format',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          validator: FormBuilderValidators.required(),
          isDense: true,
          initialValue: 'SUMMARY',
          items:
              SubscriptionFormatUtils.availableFormats(selectedDeliveryMethod)
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option['value'],
                      child: Text(
                        option['label']!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 12),
        const SubscriptionAdvancedSection(),
      ],
    );
  }
}
