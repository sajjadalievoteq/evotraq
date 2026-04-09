import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:traqtrace_app/features/epcis/widgets/field_validation_indicator.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_text_field.dart';
// Import for ValidationSeverity enum
import 'package:traqtrace_app/features/epcis/widgets/field_validation_indicator.dart'
    show ValidationSeverity;

/// A demonstration screen for the validation features
class ValidationRuleDemoRoute extends StatefulWidget {
  /// Constructor
  const ValidationRuleDemoRoute({Key? key}) : super(key: key);

  @override
  State<ValidationRuleDemoRoute> createState() => _ValidationRuleDemoRouteState();
}

class _ValidationRuleDemoRouteState extends State<ValidationRuleDemoRoute> {
  final _formKey = GlobalKey<FormState>();
  
  final _eventIdController = TextEditingController();
  final _actionController = TextEditingController();
  final _businessStepController = TextEditingController();
  final _dispositionController = TextEditingController();
  final _epcListController = TextEditingController();
  
  RuleSeverity _selectedSeverity = RuleSeverity.ERROR;
  bool _animateValidation = true;
  
  @override
  void dispose() {
    _eventIdController.dispose();
    _actionController.dispose();
    _businessStepController.dispose();
    _dispositionController.dispose();
    _epcListController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progressive Validation Demo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This demo shows field-level validation that updates as you type, '
              'with different severity levels and animated feedback.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // Demo form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValidatedTextField(
                    controller: _eventIdController,
                    decoration: const InputDecoration(
                      labelText: 'Event ID',
                      hintText: 'Enter a unique event ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.perm_identity),
                    ),
                    validator: _validateEventId,
                    helpText: 'A unique identifier for this event',
                    validateOnChange: _animateValidation,
                    validateOnBlur: true,
                  ),
                  const SizedBox(height: 16),
                  
                  ValidatedTextField(
                    controller: _actionController,
                    decoration: const InputDecoration(
                      labelText: 'Action',
                      hintText: 'ADD, OBSERVE, or DELETE',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    validator: _validateAction,
                    helpText: 'The action type for this event',
                    validateOnChange: _animateValidation,
                    validateOnBlur: true,
                  ),
                  const SizedBox(height: 16),
                  
                  ValidatedTextField(
                    controller: _businessStepController,
                    decoration: const InputDecoration(
                      labelText: 'Business Step',
                      hintText: 'e.g., urn:epcglobal:cbv:bizstep:shipping',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: _validateBusinessStep,
                    helpText: 'The business process step (optional but recommended)',
                    validateOnChange: _animateValidation,
                    validateOnBlur: true,
                  ),
                  const SizedBox(height: 16),
                  
                  ValidatedTextField(
                    controller: _dispositionController,
                    decoration: const InputDecoration(
                      labelText: 'Disposition',
                      hintText: 'e.g., urn:epcglobal:cbv:disp:in_transit',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.style),
                    ),
                    validator: _validateDisposition,
                    helpText: 'The business condition (optional)',
                    validateOnChange: _animateValidation,
                    validateOnBlur: true,
                  ),
                  const SizedBox(height: 16),
                  
                  ValidatedTextField(
                    controller: _epcListController,
                    decoration: const InputDecoration(
                      labelText: 'EPCs (comma separated)',
                      hintText: 'urn:epc:id:sgtin:0614141.107346.1, ...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list),
                    ),
                    validator: _validateEpcList,
                    helpText: 'List of EPCs associated with this event',
                    validateOnChange: _animateValidation,
                    validateOnBlur: true,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 24),
                  
                  // Demo controls
                  const Text(
                    'Demo Controls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Severity selector
                  const Text('Error Severity Level:'),
                  Wrap(
                    spacing: 8,
                    children: RuleSeverity.values.map((severity) {
                      return ChoiceChip(
                        label: Text(severity.displayName),
                        selected: _selectedSeverity == severity,
                        selectedColor: severity.color.withOpacity(0.2),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSeverity = severity;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Animation toggle
                  SwitchListTile(
                    title: const Text('Animate Validation Feedback'),
                    subtitle: const Text('Show validation results as you type'),
                    value: _animateValidation,
                    onChanged: (value) {
                      setState(() {
                        _animateValidation = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Validation display demo
                  const Text('Validation Indicator Examples:'),
                  const SizedBox(height: 8),
                  
                  // Sample indicators for different states
                  Row(
                    children: const [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Not Validated'),
                                SizedBox(height: 4),
                                FieldValidationIndicator(
                                  wasValidated: false,
                                  helpText: 'Enter a value',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Valid'),
                                SizedBox(height: 4),
                                FieldValidationIndicator(
                                  wasValidated: true,
                                  isValid: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Sample indicators for different severity levels
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Warning'),
                                const SizedBox(height: 4),
                                FieldValidationIndicator(
                                  wasValidated: true,
                                  isValid: false,
                                  severity: ValidationSeverity.warning,
                                  errorMessage: 'This field is recommended',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Error'),
                                const SizedBox(height: 4),
                                FieldValidationIndicator(
                                  wasValidated: true,
                                  isValid: false,
                                  severity: ValidationSeverity.error,
                                  errorMessage: 'This field is required',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final form = _formKey.currentState;
                        if (form != null) {
                          form.validate();
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Validate All'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String? _validateEventId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Event ID is required';
    }
    if (value.length < 4) {
      return 'Event ID must be at least 4 characters';
    }
    return null;
  }
  
  String? _validateAction(String? value) {
    if (value == null || value.isEmpty) {
      return 'Action is required';
    }
    
    final validActions = ['ADD', 'OBSERVE', 'DELETE'];
    if (!validActions.contains(value.toUpperCase())) {
      return 'Action must be ADD, OBSERVE, or DELETE';
    }
    
    return null;
  }
  
  String? _validateBusinessStep(String? value) {
    if (value == null || value.isEmpty) {
      // For demo purposes, we'll use the selected severity for this field
      if (_selectedSeverity.failsValidation) {
        return 'Business step is required';
      } else {
        // This is a warning, not an error
        return 'Business step is recommended';
      }
    }
    
    if (!value.startsWith('urn:epcglobal:cbv:bizstep:')) {
      return 'Business step should use the CBV namespace';
    }
    
    return null;
  }
  
  String? _validateDisposition(String? value) {
    if (value == null || value.isEmpty) {
      // Optional field, so no error
      return null;
    }
    
    if (!value.startsWith('urn:epcglobal:cbv:disp:')) {
      return 'Disposition should use the CBV namespace';
    }
    
    return null;
  }
  
  String? _validateEpcList(String? value) {
    if (value == null || value.isEmpty) {
      return 'At least one EPC is required';
    }
    
    final epcs = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    if (epcs.isEmpty) {
      return 'At least one EPC is required';
    }
    
    for (final epc in epcs) {
      if (!epc.startsWith('urn:epc:')) {
        return 'EPCs must start with urn:epc:';
      }
    }
    
    return null;
  }
  
  /// Create the route for navigation
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (context) => ValidationRuleProvider(
          appConfig: getIt<AppConfig>(),
        ),
        child: const ValidationRuleDemoRoute(),
      ),
    );
  }
  
  /// Navigate to this screen
  /// 
  /// Note: This method is kept for API consistency with other routes,
  /// even though it's currently not used directly in the codebase.
  /// It provides a convenient way to navigate to this screen from anywhere.
  // ignore: unused_element
  static void navigate(BuildContext context) {
    Navigator.of(context).push(route());
  }
}
