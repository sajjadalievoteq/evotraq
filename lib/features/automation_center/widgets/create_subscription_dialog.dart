import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/create_subscription_form_fields.dart';
import 'package:traqtrace_app/features/automation_center/widgets/help_widgets/notification_subscription_help.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_delivery_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/delivery_test_feedback.dart';

class CreateSubscriptionDialog extends StatefulWidget {
  final NotificationSubscription? subscription;

  const CreateSubscriptionDialog({super.key, this.subscription});

  @override
  State<CreateSubscriptionDialog> createState() =>
      _CreateSubscriptionDialogState();
}

class _CreateSubscriptionDialogState extends State<CreateSubscriptionDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _isTesting = false;
  bool? _testSucceeded;
  String? _testMessage;
  late String _selectedDeliveryMethod;
  late String _selectedSubscriptionType;
  String? _selectedNotificationFrequency;

  bool get _isEditing => widget.subscription != null;

  static const _typeDefaultFrequency = {
    'BATCH': 'HOURLY',
    'SCHEDULED': 'DAILY',
  };

  @override
  void initState() {
    super.initState();
    final endpoint = widget.subscription?.webhookUrl ?? '';
    _selectedDeliveryMethod =
        SubscriptionDeliveryUtils.isEmailEndpoint(endpoint)
        ? 'EMAIL'
        : 'WEBHOOK';
    _selectedSubscriptionType =
        widget.subscription?.subscriptionType ?? 'REALTIME';
    _selectedNotificationFrequency =
        widget.subscription?.notificationFrequency ??
        _typeDefaultFrequency[_selectedSubscriptionType];
  }

  Map<String, dynamic> get _initialValue {
    final subscription = widget.subscription;
    if (subscription == null) {
      return const {
        'subscriptionType': 'REALTIME',
        'deliveryMethod': 'WEBHOOK',
        'notificationFormat': 'SUMMARY',
      };
    }

    final query = subscription.queryParameters ?? const <String, dynamic>{};
    String? firstString(String key) {
      final value = query[key];
      if (value is List && value.isNotEmpty) return '${value.first}';
      if (value is String && value.isNotEmpty) return value;
      return null;
    }

    final eventTypes = query['eventTypes'];
    return {
      'subscriptionName': subscription.subscriptionName,
      'deliveryMethod': _selectedDeliveryMethod,
      if (_selectedDeliveryMethod == 'EMAIL')
        'emailAddress': subscription.webhookUrl
      else
        'webhookUrl': subscription.webhookUrl,
      'subscriptionType': subscription.subscriptionType,
      'notificationFormat':
          subscription.notificationFormat ??
          (_selectedDeliveryMethod == 'EMAIL' ? 'EMAIL_HTML' : 'SUMMARY'),
      'notificationFrequency':
          subscription.notificationFrequency ??
          _typeDefaultFrequency[subscription.subscriptionType],
      if (subscription.preferredHour != null &&
          subscription.preferredMinute != null)
        'preferredTime': TimeOfDay(
          hour: subscription.preferredHour!,
          minute: subscription.preferredMinute!,
        ),
      if (eventTypes is List)
        'eventTypes': eventTypes.map((value) => '$value').toList(),
      'bizStep': firstString('businessSteps'),
      'disposition': firstString('dispositions'),
      'readPoint': firstString('readPoints'),
      'epcPattern': firstString('epcs'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listener: (context, state) {
        if (state.status == NotificationStatus.subscriptionCreated ||
            state.status == NotificationStatus.subscriptionUpdated) {
          Navigator.of(context).pop(true);
        } else if (_isTesting &&
            (_selectedDeliveryMethod == 'EMAIL'
                ? state.emailTestResult != null
                : state.webhookTestResult != null)) {
          final result = _selectedDeliveryMethod == 'EMAIL'
              ? state.emailTestResult!
              : state.webhookTestResult!;
          setState(() {
            _isTesting = false;
            _testSucceeded = result['success'] == true;
            _testMessage = '${result['message'] ?? 'Delivery test completed'}';
          });
        } else if (state.status == NotificationStatus.error) {
          setState(() {
            _isLoading = false;
            if (_isTesting) {
              _isTesting = false;
              _testSucceeded = false;
              _testMessage = state.error ?? 'Delivery test failed';
            }
          });
        }
      },
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _isEditing ? 'Edit Subscription' : 'New Subscription',
              ),
            ),
            IconButton(
              icon: TraqIcon(AppAssets.iconInfo),
              onPressed: () => _showHelpDialog(context),
              tooltip: 'Show Help',
            ),
          ],
        ),
        content: SizedBox(
          width: (MediaQuery.sizeOf(context).width - 64)
              .clamp(280.0, 720.0)
              .toDouble(),
          height: (MediaQuery.sizeOf(context).height * 0.7)
              .clamp(360.0, 720.0)
              .toDouble(),
          child: FormBuilder(
            key: _formKey,
            initialValue: _initialValue,
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
                children: [
                  CreateSubscriptionFormFields(
                    selectedDeliveryMethod: _selectedDeliveryMethod,
                    onDeliveryMethodChanged: (value) {
                      setState(() {
                        _selectedDeliveryMethod = value;
                        _testSucceeded = null;
                        _testMessage = null;
                      });
                    },
                    selectedSubscriptionType: _selectedSubscriptionType,
                    onSubscriptionTypeChanged: (value) {
                      setState(() {
                        _selectedSubscriptionType = value;
                      });
                      final defaultFrequency = _typeDefaultFrequency[value];
                      if (defaultFrequency != null) {
                        setState(
                          () =>
                              _selectedNotificationFrequency = defaultFrequency,
                        );
                        _formKey.currentState?.patchValue({
                          'notificationFrequency': defaultFrequency,
                        });
                      }
                    },
                    selectedNotificationFrequency:
                        _selectedNotificationFrequency,
                    onNotificationFrequencyChanged: (value) {
                      setState(() => _selectedNotificationFrequency = value);
                    },
                  ),
                  if (_isTesting || _testMessage != null) ...[
                    const SizedBox(height: TraqSpacing.md),
                    DeliveryTestFeedback(
                      testing: _isTesting,
                      success: _testSucceeded,
                      message: _testMessage,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!_isEditing) ...[
                TextButton.icon(
                  onPressed: _isLoading || _isTesting ? null : _testDelivery,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TraqIcon(AppAssets.iconFlask),
                  label: Text(
                    _selectedDeliveryMethod == 'EMAIL'
                        ? 'Test Email'
                        : 'Test Webhook',
                  ),
                ),
              ],
              FilledButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Save Changes' : 'Create Subscription'),
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
      setState(() {
        _isTesting = true;
        _testSucceeded = null;
        _testMessage = null;
      });

      if (deliveryMethod == 'WEBHOOK') {
        final webhookUrl = formData['webhookUrl'] as String?;
        if (webhookUrl != null && webhookUrl.isNotEmpty) {
          context.read<NotificationCubit>().testWebhook(webhookUrl);
        } else {
          setState(() => _isTesting = false);
          context.showError('Please enter a valid webhook URL');
          return;
        }
      } else if (deliveryMethod == 'EMAIL') {
        final emailAddress = formData['emailAddress'] as String?;
        if (emailAddress != null && emailAddress.isNotEmpty) {
          context.read<NotificationCubit>().testEmail(emailAddress);
        } else {
          setState(() => _isTesting = false);
          context.showError('Please enter a valid email address');
          return;
        }
      }
    }
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

      final String subscriptionType = formData['subscriptionType'];
      final bool usesCadence =
          subscriptionType == 'BATCH' || subscriptionType == 'SCHEDULED';
      final String? notificationFrequency = usesCadence
          ? formData['notificationFrequency'] as String?
          : null;

      final bool usesPreferredTime =
          usesCadence &&
          (notificationFrequency == 'DAILY' ||
              notificationFrequency == 'WEEKLY' ||
              notificationFrequency == 'MONTHLY');
      final TimeOfDay? preferredTime = usesPreferredTime
          ? formData['preferredTime'] as TimeOfDay?
          : null;

      if (_isEditing) {
        context.read<NotificationCubit>().updateSubscription(
          id: widget.subscription!.id,
          subscriptionName: formData['subscriptionName'],
          webhookUrl: endpointOrEmail,
          subscriptionType: subscriptionType,
          deliveryMethod: deliveryMethod,
          notificationFormat: notificationFormat,
          notificationFrequency: notificationFrequency,
          preferredHour: preferredTime?.hour,
          preferredMinute: preferredTime?.minute,
          queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
        );
      } else {
        context.read<NotificationCubit>().createSubscription(
          subscriptionName: formData['subscriptionName'],
          webhookUrl: endpointOrEmail,
          subscriptionType: subscriptionType,
          deliveryMethod: deliveryMethod,
          notificationFormat: notificationFormat,
          notificationFrequency: notificationFrequency,
          preferredHour: preferredTime?.hour,
          preferredMinute: preferredTime?.minute,
          queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
        );
      }
    }
  }
}
