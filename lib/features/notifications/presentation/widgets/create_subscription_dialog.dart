import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../constants/notification_constants.dart';
import '../widgets/notification_subscription_help.dart';
import '../../domain/models/notification_subscription.dart';
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
      return NotificationConstants.notificationFormats.where((format) => 
        format['value'] == 'SUMMARY' || format['value'] == 'EMAIL_HTML'
      ).toList();
    } else {
      return NotificationConstants.notificationFormats.where((format) => 
        format['value'] != 'EMAIL_HTML'
      ).toList();
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(3),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDropdownSection<String>(
                    'deliveryMethod',
                    'Delivery Method',
                    NotificationConstants.deliveryMethods,
                    FormBuilderValidators.required(),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        helperText: 'HTTP endpoint that will receive POST requests',
                        helperStyle: TextStyle(fontSize: 11),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        helperText: 'Email address to receive notifications',
                        helperStyle: TextStyle(fontSize: 11),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                    ),
                  const SizedBox(height: 12),
                  _buildDropdownSection<String>(
                    'subscriptionType',
                    'Subscription Type',
                    NotificationConstants.subscriptionTypes,
                    FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 12),
                  FormBuilderDropdown<String>(
                    key: ValueKey('notificationFormat_$_selectedDeliveryMethod'),
                    name: 'notificationFormat',
                    decoration: const InputDecoration(
                      labelText: 'Notification Format',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: FormBuilderValidators.required(),
                    isDense: true,
                    initialValue: _selectedDeliveryMethod == 'EMAIL' ? 'EMAIL_HTML' : 'SUMMARY',
                    items: _getAvailableFormats().map((option) => DropdownMenuItem<String>(
                          value: option['value'],
                          child: Text(
                            option['label']!,
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )).toList(),
                  ),
                  const SizedBox(height: 12),
                  _buildAdvancedSection(),
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
                  label: Text(_selectedDeliveryMethod == 'EMAIL' ? 'Test Email' : 'Test Webhook'),
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

  Widget _buildAdvancedSection() {
    return ExpansionTile(
      title: const Text('Event Filtering (Advanced)'),
      subtitle: const Text('Configure which events trigger notifications'),
      children: [
        const SizedBox(height: 8),
        _buildMultiSelectField(
          'eventTypes',
          'Event Types',
          NotificationConstants.eventTypes,
          'Select which EPCIS event types to monitor',
        ),
        const SizedBox(height: 12),
        _buildEnhancedDropdown(
          'bizStep',
          'Business Step',
          NotificationConstants.businessSteps,
          'Filter by business process steps',
          isRequired: false,
        ),
        const SizedBox(height: 12),
        _buildEnhancedDropdown(
          'disposition',
          'Disposition',
          NotificationConstants.dispositions,
          'Filter by item status or condition',
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
            helperStyle: TextStyle(fontSize: 11),
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
            helperStyle: TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedDropdown(
    String name,
    String label,
    List<Map<String, String>> options,
    String helperText, {
    bool isRequired = false,
  }) {
    return FormBuilderDropdown<String>(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        helperText: helperText,
        helperMaxLines: 1,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        helperStyle: const TextStyle(fontSize: 11),
      ),
      validator: isRequired ? FormBuilderValidators.required() : null,
      isDense: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('-- Select Option --', style: TextStyle(fontSize: 14)),
        ),
        ...options.map((option) => DropdownMenuItem<String>(
              value: option['value'],
              child: Text(
                option['label']!,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
    );
  }

  Widget _buildMultiSelectField(
    String name,
    String label,
    List<Map<String, String>> options,
    String helperText,
  ) {
    return FormBuilderField<List<String>>(
      name: name,
      builder: (FormFieldState<List<String>> field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            helperText: helperText,
            helperMaxLines: 1,
            errorText: field.errorText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            helperStyle: const TextStyle(fontSize: 11),
          ),
          child: Column(
            children: [
              if (field.value != null && field.value!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: field.value!.map((value) {
                      final option = options.firstWhere(
                        (opt) => opt['value'] == value,
                        orElse: () => {'label': value, 'value': value},
                      );
                      return Chip(
                        label: Text(option['label']!),
                        onDeleted: () {
                          final newValue = List<String>.from(field.value!)
                            ..remove(value);
                          field.didChange(newValue.isEmpty ? null : newValue);
                        },
                        deleteIcon: TraqIcon(AppAssets.iconX, size: 16),
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: TraqIcon(AppAssets.iconPlus),
                  label: Text(field.value == null || field.value!.isEmpty
                      ? 'Select Event Types'
                      : 'Add More Event Types'),
                  onPressed: () => _showMultiSelectDialog(
                    context,
                    label,
                    options,
                    field.value ?? [],
                    (selectedValues) {
                      field.didChange(
                          selectedValues.isEmpty ? null : selectedValues);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdownSection<T>(
    String name,
    String label,
    List<Map<String, String>> options,
    String? Function(T?)? validator,
  ) {
    return FormBuilderDropdown<T>(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: validator,
      isDense: true,
      onChanged: (value) {
        if (name == 'deliveryMethod' && value != null) {
          setState(() {
            _selectedDeliveryMethod = value as String;
          });
        }
      },
      items: options.map((option) => DropdownMenuItem<T>(
            value: option['value'] as T,
            child: Text(
              option['label']!,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NotificationSubscriptionHelp(),
    );
  }

  void _showMultiSelectDialog(
    BuildContext context,
    String title,
    List<Map<String, String>> options,
    List<String> currentSelection,
    Function(List<String>) onSelectionChanged,
  ) {
    List<String> tempSelection = List.from(currentSelection);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Select $title'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = tempSelection.contains(option['value']);
                
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        tempSelection.add(option['value']!);
                      } else {
                        tempSelection.remove(option['value']);
                      }
                    });
                  },
                  title: Text(
                    option['label']!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: option['description'] != null
                      ? Text(
                          option['description']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                tempSelection.clear();
                setState(() {});
              },
              child: const Text('Clear All'),
            ),
            ElevatedButton(
              onPressed: () {
                onSelectionChanged(tempSelection);
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
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
            if (state.webhookTestResult != null || state.emailTestResult != null) {
              Navigator.of(context).pop();
              Map<String, dynamic> result = state.webhookTestResult ?? state.emailTestResult!;
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
        queryParameters['bizStep'] = formData['bizStep'];
      }

      if (formData['disposition'] != null && 
          (formData['disposition'] as String).isNotEmpty) {
        queryParameters['disposition'] = formData['disposition'];
      }

      if (formData['readPoint'] != null && 
          (formData['readPoint'] as String).isNotEmpty) {
        queryParameters['readPoint'] = formData['readPoint'];
      }

      if (formData['epcPattern'] != null && 
          (formData['epcPattern'] as String).isNotEmpty) {
        queryParameters['epcPattern'] = formData['epcPattern'];
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
                notificationFormat: notificationFormat,
                queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
              );
      } else {
        context.read<NotificationCubit>().createSubscription(
                subscriptionName: formData['subscriptionName'],
                webhookUrl: endpointOrEmail,
                subscriptionType: formData['subscriptionType'],
                notificationFormat: notificationFormat,
                queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
              );
      }
    }
  }
}
