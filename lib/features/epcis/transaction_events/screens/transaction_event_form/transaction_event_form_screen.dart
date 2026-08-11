import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/transaction_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_state.dart';

import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/epc_entry_field.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gln_entry_field.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_epc_validators.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_gln_validators.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_generator.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_event_form/widgets/transaction_biz_data_fields.dart';

part 'transaction_event_form_actions.dart';

class TransactionEventFormScreen extends StatefulWidget {
  final String? transactionEventId;

  const TransactionEventFormScreen({Key? key, this.transactionEventId})
    : super(key: key);

  @override
  _TransactionEventFormScreenState createState() =>
      _TransactionEventFormScreenState();
}

class _TransactionEventFormScreenState
    extends State<TransactionEventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _bizTransactionTypeController = TextEditingController();
  final _bizTransactionIdController = TextEditingController();
  final _epcsController = TextEditingController();
  final _locationGLNController = TextEditingController();

  String? _businessStep;
  String? _disposition;
  String? _bizTransactionType;

  final List<MapEntry<TextEditingController, TextEditingController>>
  _bizDataControllers = [];
  String _selectedAction = 'ADD';
  bool _isEdit = false;
  DateTime _eventTime = DateTime.now().subtract(const Duration(seconds: 5));
  String _eventTimeZoneOffset = '+00:00';

  final List<String> _standardBizTransactionTypes = [
    'urn:epcglobal:cbv:btt:po',
    'urn:epcglobal:cbv:btt:desadv',
    'urn:epcglobal:cbv:btt:inv',
    'urn:epcglobal:cbv:btt:pedigree',
    'urn:epcglobal:cbv:btt:receipt',
    'urn:epcglobal:cbv:btt:prodorder',
    'urn:epcglobal:cbv:btt:transdoc',
    'urn:epcglobal:cbv:btt:cert',
    'urn:epcglobal:cbv:btt:bol',
    'urn:epcglobal:cbv:btt:customs',
    'urn:epcglobal:cbv:btt:contract',
  ];
  @override
  void initState() {
    super.initState();
    _isEdit = widget.transactionEventId != null;

    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    _eventTimeZoneOffset =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTransactionEvent();
      });
    } else {
      _addBizDataField();
    }
    context.read<CbvVocabularyCubit>().loadVocabulary();
  }

  List<CbvVocabularyItem> _allowedDispositions(CbvVocabularyState state) {
    CbvVocabularyItem? selectedStep;
    if (_businessStep != null) {
      for (final item in state.bizSteps) {
        if (item.urn == _businessStep) {
          selectedStep = item;
          break;
        }
      }
    }
    if (selectedStep == null) {
      return state.dispositions;
    }
    final allowedCodes = state.bizStepValidDispositions[selectedStep.code];
    if (allowedCodes == null || allowedCodes.isEmpty) {
      return state.dispositions;
    }
    final allowedSet = allowedCodes.toSet();
    return state.dispositions
        .where((item) => allowedSet.contains(item.code))
        .toList();
  }

  @override
  void dispose() {
    _bizTransactionTypeController.dispose();
    _bizTransactionIdController.dispose();
    _epcsController.dispose();
    _locationGLNController.dispose();

    for (var entry in _bizDataControllers) {
      entry.key.dispose();
      entry.value.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Transaction Event' : 'Create Transaction Event',
        ),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconInfo),
            onPressed: () => _showHelpScreen(context),
            tooltip: 'Help',
          ),
        ],
      ),
      body: BlocBuilder<TransactionEventsCubit, TransactionEventsState>(
        builder: (context, state) {
          final cbvState = context.watch<CbvVocabularyCubit>().state;
          if (state.loading && _isEdit) {
            return const Center(child: AppLoadingIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Action *',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedAction,
                    items: ['ADD', 'OBSERVE', 'DELETE']
                        .map(
                          (action) => DropdownMenuItem(
                            value: action,
                            child: Text(action),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAction = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an action';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Business Transaction Type *',
                      border: OutlineInputBorder(),
                    ),
                    value: _bizTransactionType,
                    items: _standardBizTransactionTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.split(':').last.replaceAll('btt:', ''),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _bizTransactionType = value;
                        if (value != null) {
                          _bizTransactionTypeController.text = value;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a business transaction type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bizTransactionIdController,
                    decoration: const InputDecoration(
                      labelText: 'Business Transaction ID *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter business transaction ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EpcEntryField(
                              controller: _epcsController,
                              fieldName: 'epcs',
                              label: 'EPCs (comma separated) *',
                              required: true,
                              validator: (value) =>
                                  EpcisEpcValidators.validateEpcList(value),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Formats accepted:\n'
                              '• Digital Link: https://id.gs1.org/01/<GTIN-14>/21/<SerialNumber>\n'
                              '• GS1: (01)05415062325810(21)70005188444899',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final sgtin = GS1Generator.generateRandomSGTIN(
                                '0614141',
                                '112345',
                              );
                              setState(() {
                                final existingEpcs = _epcsController.text
                                    .trim();
                                if (existingEpcs.isEmpty) {
                                  _epcsController.text = sgtin;
                                } else {
                                  _epcsController.text =
                                      '$existingEpcs, $sgtin';
                                }
                              });
                            },
                            child: const Text('Generate SGTIN'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              final batch = GS1Generator.generateBatchSGTINs(
                                '0614141',
                                '112345',
                                5,
                              );
                              setState(() {
                                final existingEpcs = _epcsController.text
                                    .trim();
                                if (existingEpcs.isEmpty) {
                                  _epcsController.text = batch.join(', ');
                                } else {
                                  _epcsController.text =
                                      '$existingEpcs, ${batch.join(', ')}';
                                }
                              });
                            },
                            child: const Text('Generate Batch'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GlnEntryField(
                          controller: _locationGLNController,
                          label: 'Location GLN *',
                          validator: (value) =>
                              EpcisGlnValidators.validateLocationGln(value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final gln = GS1Generator.generateGLN(
                            '0614141',
                            '00001',
                          );
                          setState(() {
                            _locationGLNController.text = gln;
                          });
                        },
                        child: const Text('Generate GLN'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (cbvState.isLoading && !cbvState.isLoaded)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(),
                    ),
                  if (cbvState.hasError && !cbvState.isLoaded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Failed to load CBV vocabulary.'),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.read<CbvVocabularyCubit>().refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Business Step *',
                      border: OutlineInputBorder(),
                    ),
                    value: _businessStep,
                    items: cbvState.bizSteps
                        .map(
                          (step) => DropdownMenuItem(
                            value: step.urn,
                            child: Text(step.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _businessStep = value;
                        if (value != null) {
                          final allowed = _allowedDispositions(cbvState);
                          final selectedStillValid = allowed.any(
                            (item) => item.urn == _disposition,
                          );
                          if (!selectedStillValid) {
                            _disposition = null;
                          }
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a business step';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Disposition *',
                      border: OutlineInputBorder(),
                    ),
                    value: _disposition,
                    items: _allowedDispositions(cbvState)
                        .map(
                          (disp) => DropdownMenuItem(
                            value: disp.urn,
                            child: Text(disp.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _disposition = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a disposition';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    title: const Text('Event Time'),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(_eventTime),
                    ),
                    trailing: TraqIcon(AppAssets.iconClock),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _eventTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_eventTime),
                        );
                        if (time != null) {
                          setState(() {
                            _eventTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Business Data',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  TransactionBizDataFields(
                    controllers: _bizDataControllers,
                    onRemove: _removeBizDataField,
                  ),

                  TextButton.icon(
                    onPressed: _addBizDataField,
                    icon: TraqIcon(AppAssets.iconPlus),
                    label: const Text('Add Business Data Field'),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.loading ? null : _saveTransactionEvent,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _isEdit
                              ? 'Update Transaction Event'
                              : 'Create Transaction Event',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
