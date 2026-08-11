import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_event_validation_demo/widgets/transaction_event_validation_section_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_form_field.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_text_field.dart';

class TransactionEventValidationDemo extends StatefulWidget {
  const TransactionEventValidationDemo({Key? key}) : super(key: key);

  @override
  State<TransactionEventValidationDemo> createState() =>
      _TransactionEventValidationDemoState();
}

class _TransactionEventValidationDemoState
    extends State<TransactionEventValidationDemo> {
  final _formKey = GlobalKey<FormState>();
  final _transactionIdController = TextEditingController();
  final _transactionTypeController = TextEditingController();
  final _bizStepController = TextEditingController();
  String? _selectedBizStep;
  bool _isLoading = false;

  void _setFieldError(String fieldName, String? error) {
    context.read<ValidationCubit>().setFieldError(fieldName, error);
  }

  void _clearFieldErrors() {
    context.read<ValidationCubit>().clearFieldErrors();
  }

  final List<String> _standardTransactionTypes = [
    'urn:epcglobal:cbv:bizTransType:po',
    'urn:epcglobal:cbv:bizTransType:desadv',
    'urn:epcglobal:cbv:bizTransType:inv',
    'urn:epcglobal:cbv:bizTransType:pedigree',
    'urn:epcglobal:cbv:bizTransType:contract',
  ];

  @override
  void initState() {
    super.initState();
    context.read<CbvVocabularyCubit>().loadVocabulary();
  }

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
      appBar: AppBar(title: const Text('Transaction Event Validation Demo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TransactionEventValidationSectionHeader(
                      title: 'Transaction Information',
                    ),
                    const SizedBox(height: 16),

                    ValidatedTextField(
                      controller: _transactionTypeController,
                      decoration: InputDecoration(
                        labelText: 'Transaction Type',
                        hintText: 'Enter transaction type',
                        border: const OutlineInputBorder(),
                        suffixIcon: PopupMenuButton<String>(
                          icon: const TraqIcon(AppAssets.iconChevronD),
                          onSelected: (value) {
                            setState(() {
                              _transactionTypeController.text = value;
                            });
                          },
                          itemBuilder: (context) => _standardTransactionTypes
                              .map(
                                (type) => PopupMenuItem(
                                  value: type,
                                  child: Text(type.split(':').last),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _setFieldError(
                            'transactionType',
                            'Transaction type is required',
                          );
                          return 'Transaction type is required';
                        }
                        if (!value.startsWith(
                          'urn:epcglobal:cbv:bizTransType:',
                        )) {
                          _setFieldError(
                            'transactionType',
                            'Should follow the GS1 CBV business-transaction-type URN format.',
                          );
                          return 'Should follow the GS1 CBV business-transaction-type URN format.';
                        }
                        _setFieldError('transactionType', null);
                        return null;
                      },
                      helpText:
                          'Example: GS1 CBV business transaction type URN (purchase order).',
                      validateOnChange: true,
                      validateOnBlur: true,
                    ),
                    const SizedBox(height: 16),

                    ValidatedTextField(
                      controller: _transactionIdController,
                      decoration: const InputDecoration(
                        labelText: 'Transaction ID',
                        hintText: 'Enter transaction ID',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _setFieldError(
                            'transactionId',
                            'Transaction ID is required',
                          );
                          return 'Transaction ID is required';
                        }
                        _setFieldError('transactionId', null);
                        return null;
                      },
                      helpText:
                          'Example: urn:epcglobal:cbv:bt:0614141000005:PO12345',
                      validateOnChange: false,
                      validateOnBlur: true,
                    ),
                    const SizedBox(height: 16),

                    const TransactionEventValidationSectionHeader(
                      title: 'Business Context',
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<CbvVocabularyCubit, CbvVocabularyState>(
                      builder: (context, cbvState) {
                        if (cbvState.isLoading && !cbvState.isLoaded) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: LinearProgressIndicator(),
                          );
                        }
                        if (cbvState.hasError && !cbvState.isLoaded) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text('Failed to load CBV vocabulary.'),
                                ),
                                TextButton(
                                  onPressed: () => context
                                      .read<CbvVocabularyCubit>()
                                      .refresh(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    ValidatedFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _setFieldError(
                            'bizStep',
                            'Business step is required',
                          );
                          return 'Business step is required';
                        }
                        if (!value.startsWith(
                          CbvVocabularyFormatter.bizStepUrnPrefix,
                        )) {
                          _setFieldError(
                            'bizStep',
                            'Should follow GS1 CBV business-step URN format.',
                          );
                          return 'Should follow GS1 CBV business-step URN format.';
                        }
                        _setFieldError('bizStep', null);
                        return null;
                      },
                      helpText:
                          'Select a standard business step or enter custom value',
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
                          ...context
                              .watch<CbvVocabularyCubit>()
                              .state
                              .bizSteps
                              .map(
                                (step) => DropdownMenuItem<String>(
                                  value: step.urn,
                                  child: Text(step.label),
                                ),
                              ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value == null) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Custom Business Step'),
                                    content: TextField(
                                      controller: _bizStepController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter custom business step',
                                        prefixText: CbvVocabularyFormatter
                                            .bizStepUrnPrefix,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final customValue =
                                              '${CbvVocabularyFormatter.bizStepUrnPrefix}${_bizStepController.text}';
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
                              final error = _validateBizStep(value);
                              _setFieldError('bizStep', error);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

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

  String? _validateBizStep(String? value) {
    if (value == null || value.isEmpty) {
      return 'Business step is required';
    }
    if (!value.startsWith(CbvVocabularyFormatter.bizStepUrnPrefix)) {
      return 'Should follow GS1 CBV business-step URN format.';
    }
    return null;
  }

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      context.showSuccess('Validation successful! Transaction event is valid.');

      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      context.showError('Validation failed. Please check the form for errors.');
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _transactionIdController.clear();
    _transactionTypeController.clear();
    _bizStepController.clear();
    setState(() {
      _selectedBizStep = null;
    });

    _clearFieldErrors();

    context.showInfo('Form has been reset.');
  }
}
