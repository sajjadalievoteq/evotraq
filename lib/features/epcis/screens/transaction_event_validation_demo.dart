import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/mixins/event_form_validation_mixin.dart';
import 'package:traqtrace_app/features/epcis/widgets/field_validation_indicator.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_form_field.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_text_field.dart';

/// Transaction Event form with integrated validation
class TransactionEventValidationDemo extends StatefulWidget {
  /// Constructor
  const TransactionEventValidationDemo({Key? key}) : super(key: key);

  @override
  State<TransactionEventValidationDemo> createState() => _TransactionEventValidationDemoState();
}

class _TransactionEventValidationDemoState extends State<TransactionEventValidationDemo> with EventFormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _transactionIdController = TextEditingController();
  final _transactionTypeController = TextEditingController();
  final _bizStepController = TextEditingController();
  String? _selectedBizStep;
  bool _isLoading = false;

  // Standard values from GS1 CBV
  final List<String> _standardBizSteps = [
    'urn:epcglobal:cbv:bizstep:shipping',
    'urn:epcglobal:cbv:bizstep:accepting',
    'urn:epcglobal:cbv:bizstep:invoicing',
    'urn:epcglobal:cbv:bizstep:paying',
  ];

  // Transaction types from GS1 CBV
  final List<String> _standardTransactionTypes = [
    'urn:epcglobal:cbv:bizTransType:po',
    'urn:epcglobal:cbv:bizTransType:desadv',
    'urn:epcglobal:cbv:bizTransType:inv',
    'urn:epcglobal:cbv:bizTransType:pedigree',
    'urn:epcglobal:cbv:bizTransType:contract',
  ];

  @override
  void dispose() {
    _transactionIdController.dispose();
    _transactionTypeController.dispose();
    _bizStepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Event Validation Demo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader('Transaction Information'),
                    const SizedBox(height: 16),
                    
                    // Transaction Type with validation
                    ValidatedTextField(
                      controller: _transactionTypeController,
                      decoration: InputDecoration(
                        labelText: 'Transaction Type',
                        hintText: 'Enter transaction type',
                        border: const OutlineInputBorder(),
                        suffixIcon: PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down),
                          onSelected: (value) {
                            setState(() {
                              _transactionTypeController.text = value;
                            });
                          },
                          itemBuilder: (context) => _standardTransactionTypes
                              .map((type) => PopupMenuItem(
                                    value: type,
                                    child: Text(type.split(':').last),
                                  ))
                              .toList(),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setFieldError('transactionType', 'Transaction type is required');
                          return 'Transaction type is required';
                        }
                        if (!value.startsWith('urn:epcglobal:cbv:bizTransType:')) {
                          setFieldError('transactionType', 'Should follow CBV format (urn:epcglobal:cbv:bizTransType:...)');
                          return 'Should follow CBV format (urn:epcglobal:cbv:bizTransType:...)';
                        }
                        setFieldError('transactionType', null);
                        return null;
                      },
                      helpText: 'Example: urn:epcglobal:cbv:bizTransType:po',
                      validateOnChange: true,
                      validateOnBlur: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Transaction ID with validation
                    ValidatedTextField(
                      controller: _transactionIdController,
                      decoration: const InputDecoration(
                        labelText: 'Transaction ID',
                        hintText: 'Enter transaction ID',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setFieldError('transactionId', 'Transaction ID is required');
                          return 'Transaction ID is required';
                        }
                        setFieldError('transactionId', null);
                        return null;
                      },
                      helpText: 'Example: urn:epcglobal:cbv:bt:0614141000005:PO12345',
                      validateOnChange: false, // Only validate on blur or submit
                      validateOnBlur: true,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildHeader('Business Context'),
                    const SizedBox(height: 16),
                    
                    // Business Step dropdown with validation
                    ValidatedFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setFieldError('bizStep', 'Business step is required');
                          return 'Business step is required';
                        }
                        if (!value.startsWith('urn:epcglobal:cbv:bizstep:')) {
                          setFieldError('bizStep', 'Should follow CBV format (urn:epcglobal:cbv:bizstep:...)');
                          return 'Should follow CBV format (urn:epcglobal:cbv:bizstep:...)';
                        }
                        setFieldError('bizStep', null);
                        return null;
                      },
                      helpText: 'Select a standard business step or enter custom value',
                      validateOnChange: true,
                      validateOnBlur: true,
                      formField: DropdownButtonFormField<String>(
                        value: _selectedBizStep,
                        decoration: const InputDecoration(
                          labelText: 'Business Step',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Custom...'),
                          ),
                          ..._standardBizSteps.map((step) => DropdownMenuItem<String>(
                                value: step,
                                child: Text(step.split(':').last),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value == null) {
                              // Show dialog for custom entry
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Custom Business Step'),
                                    content: TextField(
                                      controller: _bizStepController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter custom business step',
                                        prefixText: 'urn:epcglobal:cbv:bizstep:',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final customValue = 'urn:epcglobal:cbv:bizstep:${_bizStepController.text}';
                                          setState(() {
                                            _selectedBizStep = customValue;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              _selectedBizStep = value;
                              // Trigger validation
                              final error = _validateBizStep(value);
                              setFieldError('bizStep', error);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _validateAndSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Validate & Submit'),
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
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper to create section headers
  Widget _buildHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
      ],
    );
  }

  // Validation for business step
  String? _validateBizStep(String? value) {
    if (value == null || value.isEmpty) {
      return 'Business step is required';
    }
    if (!value.startsWith('urn:epcglobal:cbv:bizstep:')) {
      return 'Should follow CBV format (urn:epcglobal:cbv:bizstep:...)';
    }
    return null;
  }

  // Form validation and submission
  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      // All fields are valid, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validation successful! Transaction event is valid.'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Simulate API call
      setState(() {
        _isLoading = true;
      });
      
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      // Show error summary
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validation failed. Please check the form for errors.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Reset the form
  void _resetForm() {
    _formKey.currentState?.reset();
    _transactionIdController.clear();
    _transactionTypeController.clear();
    _bizStepController.clear();
    setState(() {
      _selectedBizStep = null;
    });
    
    // Clear validation errors
    clearFieldErrors();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form has been reset.'),
      ),
    );
  }
}
