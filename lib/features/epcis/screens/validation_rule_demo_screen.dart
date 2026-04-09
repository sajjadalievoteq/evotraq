import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/features/epcis/mixins/event_form_validation_mixin.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/widgets/field_validation_indicator.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_form_field.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_text_field.dart';

/// A demonstration screen for validation rule testing and field validation widgets
class ValidationRuleDemoScreen extends StatefulWidget {
  /// Constructor
  const ValidationRuleDemoScreen({Key? key}) : super(key: key);

  @override
  State<ValidationRuleDemoScreen> createState() => _ValidationRuleDemoScreenState();
}

class _ValidationRuleDemoScreenState extends State<ValidationRuleDemoScreen> with EventFormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  
  final _epcController = TextEditingController();
  final _businessStepController = TextEditingController();
  final _dispositionController = TextEditingController();
  final _readPointController = TextEditingController();
  final _bizLocationController = TextEditingController();
  final _eventTimeController = TextEditingController();
  
  ValidationSeverity _selectedSeverity = ValidationSeverity.error;
  bool _validateOnChange = true;
  bool _validateOnBlur = true;
  
  @override
  void dispose() {
    _epcController.dispose();
    _businessStepController.dispose();
    _dispositionController.dispose();
    _readPointController.dispose();
    _bizLocationController.dispose();
    _eventTimeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsSection(),
              const Divider(height: 32),
              _buildFieldsSection(),
              const SizedBox(height: 24),
              _buildButtonsSection(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Validation Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ValidationSeverity>(
              decoration: const InputDecoration(
                labelText: 'Validation Severity',
                border: OutlineInputBorder(),
              ),
              value: _selectedSeverity,
              items: ValidationSeverity.values.map((severity) {
                String label;
                Color color;
                
                switch (severity) {
                  case ValidationSeverity.info:
                    label = 'Info';
                    color = Colors.blue;
                    break;
                  case ValidationSeverity.warning:
                    label = 'Warning';
                    color = Colors.orange;
                    break;
                  case ValidationSeverity.error:
                    label = 'Error';
                    color = Colors.red;
                    break;
                }
                
                return DropdownMenuItem(
                  value: severity,
                  child: Row(
                    children: [
                      Icon(severity == ValidationSeverity.info 
                          ? Icons.info_outline 
                          : severity == ValidationSeverity.warning 
                              ? Icons.warning_amber_outlined 
                              : Icons.error_outline,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Text(label, style: TextStyle(color: color)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSeverity = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Validate on Change'),
                    value: _validateOnChange,
                    onChanged: (value) {
                      setState(() {
                        _validateOnChange = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Validate on Blur'),
                    value: _validateOnBlur,
                    onChanged: (value) {
                      setState(() {
                        _validateOnBlur = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFieldsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Fields',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Example of ValidatedTextField
            ValidatedTextField(
              controller: _epcController,
              decoration: const InputDecoration(
                labelText: 'EPC / Serial Number',
                hintText: 'Enter EPC or serial number',
                border: OutlineInputBorder(),
              ),
              helpText: 'Example: urn:epc:id:sgtin:0614141.107346.2017',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'EPC is required';
                }
                if (!value.startsWith('urn:epc:')) {
                  return 'EPC must be in proper format (urn:epc:...)';
                }
                return null;
              },
              validateOnChange: _validateOnChange,
              validateOnBlur: _validateOnBlur,
            ),
            const SizedBox(height: 16),
            // Example of ValidatedTextField with custom validation
            ValidatedTextField(
              controller: _businessStepController,
              decoration: const InputDecoration(
                labelText: 'Business Step',
                hintText: 'Enter business step',
                border: OutlineInputBorder(),
              ),
              helpText: 'Example: urn:epcglobal:cbv:bizstep:shipping',
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.startsWith('urn:epcglobal:cbv:bizstep:')) {
                  return 'Business step should follow CBV format';
                }
                return null;
              },
              validateOnChange: _validateOnChange,
              validateOnBlur: _validateOnBlur,
            ),
            const SizedBox(height: 16),
            ValidatedTextField(
              controller: _dispositionController,
              decoration: const InputDecoration(
                labelText: 'Disposition',
                hintText: 'Enter disposition',
                border: OutlineInputBorder(),
              ),
              helpText: 'Example: urn:epcglobal:cbv:disp:in_transit',
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.startsWith('urn:epcglobal:cbv:disp:')) {
                  return 'Disposition should follow CBV format';
                }
                return null;
              },
              validateOnChange: _validateOnChange,
              validateOnBlur: _validateOnBlur,
            ),
            const SizedBox(height: 16),
            // Example using ValidatedFormField with a different child widget
            ValidatedFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Event time is required';
                }
                try {
                  DateTime.parse(value);
                  return null;
                } catch (e) {
                  return 'Invalid date format';
                }
              },
              helpText: 'Format: YYYY-MM-DDTHH:MM:SS.sssZ',
              validateOnChange: _validateOnChange,
              validateOnBlur: _validateOnBlur,
              formField: TextFormField(
                controller: _eventTimeController,
                decoration: InputDecoration(
                  labelText: 'Event Time',
                  hintText: 'Enter event time',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final now = DateTime.now();
                      _eventTimeController.text = now.toUtc().toIso8601String();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ValidatedTextField(
                    controller: _readPointController,
                    decoration: const InputDecoration(
                      labelText: 'Read Point',
                      hintText: 'Enter read point',
                      border: OutlineInputBorder(),
                    ),
                    helpText: 'Example: urn:epc:id:sgln:0614141.00777.0',
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !value.startsWith('urn:epc:id:sgln:')) {
                        return 'Read point should be a valid SGLN';
                      }
                      return null;
                    },
                    validateOnChange: _validateOnChange,
                    validateOnBlur: _validateOnBlur,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ValidatedTextField(
                    controller: _bizLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Business Location',
                      hintText: 'Enter business location',
                      border: OutlineInputBorder(),
                    ),
                    helpText: 'Example: urn:epc:id:sgln:0614141.00888.0',
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !value.startsWith('urn:epc:id:sgln:')) {
                        return 'Business location should be a valid SGLN';
                      }
                      return null;
                    },
                    validateOnChange: _validateOnChange,
                    validateOnBlur: _validateOnBlur,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildButtonsSection() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _validateForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Validate'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _resetForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Reset'),
          ),
        ),
      ],
    );
  }
  
  void _validateForm() {
    if (_formKey.currentState!.validate()) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validation passed!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validation failed. Please check the form for errors.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _resetForm() {
    _formKey.currentState?.reset();
    _epcController.clear();
    _businessStepController.clear();
    _dispositionController.clear();
    _readPointController.clear();
    _bizLocationController.clear();
    _eventTimeController.clear();
    
    // Clear validation errors
    clearFieldErrors();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form has been reset.'),
      ),
    );
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Validation Demo'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This screen demonstrates:'),
              SizedBox(height: 8),
              Text('• Field-level validation with visual indicators'),
              Text('• Progressive validation (onChange and onBlur)'),
              Text('• Different validation severity levels'),
              Text('• Custom validation rules'),
              Text('• Form validation integration'),
              SizedBox(height: 16),
              Text('Try entering invalid data to see validation in action.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
