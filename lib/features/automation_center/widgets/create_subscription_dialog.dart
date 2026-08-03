import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/utils/notification_constants.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_advanced_section.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_dropdown_section.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notification_subscription_help.dart';
import 'package:traqtrace_app/data/models/notifications/notification_subscription.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class CreateSubscriptionDialog extends StatefulWidget {
  final NotificationSubscription? subscription;

  const CreateSubscriptionDialog({
    super.key,
    this.subscription,
  });

  @override
  State<CreateSubscriptionDialog> createState() =>
      _CreateSubscriptionDialogState();
}

class _CreateSubscriptionDialogState extends State<CreateSubscriptionDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  String _selectedDeliveryMethod = 'WEBHOOK';

  bool get _isEditing => widget.subscription != null;

  List<Map<String, String>> _getAvailableFormats() {
    if (_selectedDeliveryMethod == 'EMAIL') {
      return NotificationConstants.notificationFormats
          .where(
            (format) =>
                format['value'] == 'SUMMARY' ||
                format['value'] == 'EMAIL_HTML',
          )
          .toList();
    } else {
      return NotificationConstants.notificationFormats
          .where((format) => format['value'] != 'EMAIL_HTML')
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listener: (context, state) {
        if (state.status == NotificationStatus.subscriptionCreated ||
            state.status == NotificationStatus.subscriptionUpdated) {
          Navigator.of(context).pop();
        } else if (state.status == NotificationStatus.error) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Text(_isEditing ? 'Edit Subscription' : 'Create Subscription'),
            const Spacer(),
            IconButton(
              icon: TraqIcon(AppAssets.iconInfo),
              onPressed: () => _showHelpDialog(context),
              tooltip: 'Show Help',
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          child: FormBuilder(
            key: _formKey,
            initialValue: _isEditing
                ? {
                    'subscriptionName': widget.subscription!.subscriptionName,
                    'webhookUrl': widget.subscription!.webhookUrl,
                    'subscriptionType': widget.subscription!.subscriptionType,
                    'notificationFormat':
                        widget.subscription!.notificationFormat,
                    'deliveryMethod': 'WEBHOOK',
                  }
                : {
                    'subscriptionType': 'REALTIME',
                    'deliveryMethod': 'WEBHOOK',
                  },
            onChanged: () {
              final formData = _formKey.currentState?.value;
              if (formData != null && formData['deliveryMethod'] != null) {
                final newDeliveryMethod = formData['deliveryMethod'] as String;
                if (_selectedDeliveryMethod != newDeliveryMethod) {
                  setState(() {
                    _selectedDeliveryMethod = newDeliveryMethod;
                  });
                }
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'subscriptionName',
                    decoration: const InputDecoration(
                      labelText: 'Subscription Name',
                      hintText: 'Enter a descriptive name',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      if (value != null) {
                        setState(() {
                          _selectedDeliveryMethod = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_selectedDeliveryMethod == 'WEBHOOK')
                    FormBuilderTextField(
                      key: const ValueKey('webhookUrl'),
                      name: 'webhookUrl',
                      decoration: const InputDecoration(
                        labelText: 'Webhook Endpoint URL',
                        hintText: 'https://your-api.com/webhooks/notifications',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        helperText:
                            'HTTP endpoint that will receive POST requests',
                        helperStyle: TextStyle(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.url(),
                      ]),
                    )
                  else
                    FormBuilderTextField(
                      key: const ValueKey('emailAddress'),
                      name: 'emailAddress',
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'your.email@company.com',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  ),
                  const SizedBox(height: 12),
                  FormBuilderDropdown<String>(
                    key: ValueKey(
                      'notificationFormat_$_selectedDeliveryMethod',
                    ),
                    name: 'notificationFormat',
                    decoration: const InputDecoration(
                      labelText: 'Notification Format',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: FormBuilderValidators.required(),
                    isDense: true,
                    initialValue: _selectedDeliveryMethod == 'EMAIL'
                        ? 'EMAIL_HTML'
                        : 'SUMMARY',
                    items: _getAvailableFormats()
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(
                              option['label']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionAdvancedSection(),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isEditing) ...[
                TextButton.icon(
                  onPressed: _isLoading ? null : _testDelivery,
                  icon: TraqIcon(AppAssets.iconFlask),
                  label: Text(
                    _selectedDeliveryMethod == 'EMAIL'
                        ? 'Test Email'
                        : 'Test Webhook',
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_isEditing ? 'Update' : 'Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NotificationSubscriptionHelp(),
    );
  }

  void _testDelivery() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final deliveryMethod = formData['deliveryMethod'] as String? ?? 'WEBHOOK';

      if (deliveryMethod == 'WEBHOOK') {
        final webhookUrl = formData['webhookUrl'] as String?;
        if (webhookUrl != null && webhookUrl.isNotEmpty) {
          context.read<NotificationCubit>().testWebhook(webhookUrl);
        } else {
          context.showError('Please enter a valid webhook URL');
          return;
        }
      } else if (deliveryMethod == 'EMAIL') {
        final emailAddress = formData['emailAddress'] as String?;
        if (emailAddress != null && emailAddress.isNotEmpty) {
          context.read<NotificationCubit>().testEmail(emailAddress);
        } else {
          context.showError('Please enter a valid email address');
          return;
        }
      }

      showDialog(
        context: context,
        builder: (context) => BlocListener<NotificationCubit, NotificationState>(
          listener: (context, state) {
            if (state.webhookTestResult != null ||
                state.emailTestResult != null) {
              Navigator.of(context).pop();
              Map<String, dynamic> result =
                  state.webhookTestResult ?? state.emailTestResult!;
              _showTestResult(context, result);
            } else if (state.status == NotificationStatus.error) {
              Navigator.of(context).pop();
              context.showError('Test failed: ${state.error}');
            }
          },
          child: AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text('Testing ${deliveryMethod.toLowerCase()}...'),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _showTestResult(BuildContext context, Map<String, dynamic> result) {
    final success = result['success'] ?? false;
    final message = result['message'] ?? 'Unknown result';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success ? 'Test Successful' : 'Test Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final formData = _formKey.currentState!.value;
      final deliveryMethod = formData['deliveryMethod'] as String;

      final queryParameters = <String, dynamic>{};

      if (formData['eventTypes'] != null &&
          (formData['eventTypes'] as List<String>).isNotEmpty) {
        queryParameters['eventTypes'] = formData['eventTypes'];
      }

      if (formData['bizStep'] != null &&
          (formData['bizStep'] as String).isNotEmpty) {
        queryParameters['businessSteps'] = [formData['bizStep']];
      }

      if (formData['disposition'] != null &&
          (formData['disposition'] as String).isNotEmpty) {
        queryParameters['dispositions'] = [formData['disposition']];
      }

      if (formData['readPoint'] != null &&
          (formData['readPoint'] as String).isNotEmpty) {
        queryParameters['readPoints'] = [formData['readPoint']];
      }

      if (formData['epcPattern'] != null &&
          (formData['epcPattern'] as String).isNotEmpty) {
        queryParameters['epcs'] = [formData['epcPattern']];
      }

      final String endpointOrEmail = deliveryMethod == 'WEBHOOK'
          ? formData['webhookUrl']
          : formData['emailAddress'];

      final String? notificationFormat = deliveryMethod == 'EMAIL'
          ? null
          : formData['notificationFormat'];

      if (_isEditing) {
        context.read<NotificationCubit>().updateSubscription(
              id: widget.subscription!.id,
              subscriptionName: formData['subscriptionName'],
              webhookUrl: endpointOrEmail,
              subscriptionType: formData['subscriptionType'],
              deliveryMethod: deliveryMethod,
              notificationFormat: notificationFormat,
              queryParameters:
                  queryParameters.isNotEmpty ? queryParameters : null,
            );
      } else {
        context.read<NotificationCubit>().createSubscription(
              subscriptionName: formData['subscriptionName'],
              webhookUrl: endpointOrEmail,
              subscriptionType: formData['subscriptionType'],
              deliveryMethod: deliveryMethod,
              notificationFormat: notificationFormat,
              queryParameters:
                  queryParameters.isNotEmpty ? queryParameters : null,
            );
      }
    }
  }
}
