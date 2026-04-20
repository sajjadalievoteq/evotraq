import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/providers/transaction_events_provider.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/mixins/event_form_validation_mixin.dart';
import 'package:traqtrace_app/features/epcis/widgets/validation_error_widget.dart';

import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_generator.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';

/// Screen for creating or editing Transaction Events
class TransactionEventFormScreen extends StatefulWidget {
  /// The ID of the transaction event to edit, null for new events
  final String? transactionEventId;

  const TransactionEventFormScreen({Key? key, this.transactionEventId})
    : super(key: key);

  @override
  _TransactionEventFormScreenState createState() =>
      _TransactionEventFormScreenState();
}

class _TransactionEventFormScreenState extends State<TransactionEventFormScreen>
    with EventFormValidationMixin<TransactionEventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _bizTransactionTypeController = TextEditingController();
  final _bizTransactionIdController = TextEditingController();
  final _epcsController = TextEditingController();
  final _locationGLNController = TextEditingController();

  // String variables for dropdown values
  String? _businessStep;
  String? _disposition;
  String? _bizTransactionType;

  // Business data key-value pairs
  final List<MapEntry<TextEditingController, TextEditingController>>
  _bizDataControllers = [];
  // Other form state
  String _selectedAction = 'ADD';
  bool _isEdit = false;
  DateTime _eventTime = DateTime.now().subtract(
    const Duration(seconds: 5),
  ); // Set to 5 seconds ago to avoid future time error
  String _eventTimeZoneOffset = '+00:00'; // ISO 8601 timezone format

  // GS1 standard business steps
  final List<String> _standardBusinessSteps = [
    'urn:epcglobal:cbv:bizstep:commissioning',
    'urn:epcglobal:cbv:bizstep:shipping',
    'urn:epcglobal:cbv:bizstep:receiving',
    'urn:epcglobal:cbv:bizstep:packing',
    'urn:epcglobal:cbv:bizstep:unpacking',
    'urn:epcglobal:cbv:bizstep:accepting',
    'urn:epcglobal:cbv:bizstep:inspecting',
    'urn:epcglobal:cbv:bizstep:storing',
    'urn:epcglobal:cbv:bizstep:departing',
    'urn:epcglobal:cbv:bizstep:arriving',
    'urn:epcglobal:cbv:bizstep:picking',
    'urn:epcglobal:cbv:bizstep:loading',
    'urn:epcglobal:cbv:bizstep:unloading',
    'urn:epcglobal:cbv:bizstep:dispensing',
    'urn:epcglobal:cbv:bizstep:destroying',
    'urn:epcglobal:cbv:bizstep:decommissioning',
    'urn:epcglobal:cbv:bizstep:transforming',
    'urn:epcglobal:cbv:bizstep:sorting',
    'urn:epcglobal:cbv:bizstep:holding',
    'urn:epcglobal:cbv:bizstep:encoding',
  ];

  // GS1 standard dispositions
  final List<String> _standardDispositions = [
    'urn:epcglobal:cbv:disp:active',
    'urn:epcglobal:cbv:disp:available',
    'urn:epcglobal:cbv:disp:in_progress',
    'urn:epcglobal:cbv:disp:in_transit',
    'urn:epcglobal:cbv:disp:expired',
    'urn:epcglobal:cbv:disp:container_closed',
    'urn:epcglobal:cbv:disp:damaged',
    'urn:epcglobal:cbv:disp:destroyed',
    'urn:epcglobal:cbv:disp:dispensed',
    'urn:epcglobal:cbv:disp:disposed',
    'urn:epcglobal:cbv:disp:encoded',
    'urn:epcglobal:cbv:disp:inactive',
    'urn:epcglobal:cbv:disp:no_pedigree_match',
    'urn:epcglobal:cbv:disp:non_sellable_other',
    'urn:epcglobal:cbv:disp:partially_dispensed',
    'urn:epcglobal:cbv:disp:recalled',
    'urn:epcglobal:cbv:disp:reserved',
    'urn:epcglobal:cbv:disp:retail_sold',
    'urn:epcglobal:cbv:disp:returned',
    'urn:epcglobal:cbv:disp:sellable_accessible',
    'urn:epcglobal:cbv:disp:sellable_not_accessible',
    'urn:epcglobal:cbv:disp:stolen',
    'urn:epcglobal:cbv:disp:unknown',
  ];

  // Standard business transaction types from GS1 CBV
  final List<String> _standardBizTransactionTypes = [
    'urn:epcglobal:cbv:btt:po', // Purchase Order
    'urn:epcglobal:cbv:btt:desadv', // Despatch Advice
    'urn:epcglobal:cbv:btt:inv', // Invoice
    'urn:epcglobal:cbv:btt:pedigree', // Pedigree
    'urn:epcglobal:cbv:btt:receipt', // Receipt Advice
    'urn:epcglobal:cbv:btt:prodorder', // Production Order
    'urn:epcglobal:cbv:btt:transdoc', // Transport Document
    'urn:epcglobal:cbv:btt:cert', // Certificate
    'urn:epcglobal:cbv:btt:bol', // Bill of Lading
    'urn:epcglobal:cbv:btt:customs', // Customs Declaration
    'urn:epcglobal:cbv:btt:contract', // Contract
  ];
  @override
  void initState() {
    super.initState();
    _isEdit = widget.transactionEventId != null;

    // Format timezone offset in the ISO 8601 format
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    // Format as +/-HH:MM for standard ISO 8601 timezone format
    _eventTimeZoneOffset =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTransactionEvent();
      });
    } else {
      // Add initial business data field
      _addBizDataField();
    }
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

  /// Show success snackbar
  void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Load transaction event data for editing
  Future<void> _loadTransactionEvent() async {
    if (widget.transactionEventId == null) return;

    final event = await context
        .read<TransactionEventsCubit>()
        .getTransactionEventById(widget.transactionEventId!);

    if (event != null) {
      setState(() {
        // Fill form fields with event data
        _selectedAction = event.action;
        _eventTime = event.eventTime;

        // Get first business transaction if available
        if (event.bizTransactionList.isNotEmpty) {
          final entry = event.bizTransactionList.entries.first;
          _bizTransactionTypeController.text = entry.key;
          _bizTransactionIdController.text = entry.value;
          // Set the dropdown value for business transaction type
          if (_standardBizTransactionTypes.contains(entry.key)) {
            _bizTransactionType = entry.key;
          }
        }

        // Join EPCs with comma
        _epcsController.text = event.epcList?.join(', ') ?? '';

        // Use businessLocation GLN code if available
        _locationGLNController.text = event.businessLocation?.glnCode ?? '';

        // Business Step now uses businessStep property from EPCISEvent
        _businessStep = event.businessStep;

        // Disposition from base class
        _disposition = event.disposition;

        // Set business data
        _bizDataControllers.clear();
        if (event.bizData != null && event.bizData!.isNotEmpty) {
          event.bizData!.forEach((key, value) {
            final keyController = TextEditingController(text: key);
            final valueController = TextEditingController(text: value);
            _bizDataControllers.add(MapEntry(keyController, valueController));
          });
        } else {
          _addBizDataField();
        }
      });
    }
  }

  /// Add a new business data field
  void _addBizDataField() {
    setState(() {
      _bizDataControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  /// Remove a business data field
  void _removeBizDataField(int index) {
    setState(() {
      final entry = _bizDataControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  /// Save transaction event
  Future<void> _saveTransactionEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cubit = context.read<TransactionEventsCubit>();

    // Collect form data
    final bizTransactionType =
        _bizTransactionType ?? _bizTransactionTypeController.text.trim();
    final bizTransactionId = _bizTransactionIdController.text.trim();
    final epcs = _epcsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map(
          (e) => EPCFormatter.formatToEPCUri(e),
        ) // Format to EPC URI if needed
        .toList();
    final locationGLN = _locationGLNController.text.trim();
    final businessStep = _businessStep ?? '';
    final disposition = _disposition ?? '';

    // Build business data
    final bizData = <String, String>{};
    for (var entry in _bizDataControllers) {
      final key = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        bizData[key] = value;
      }
    }

    try {
      if (_isEdit) {
        // For editing, we'd need the full event object
        // For editing, we'd need the full event object
        // Use a time that's definitely in the past to avoid validation errors
        final eventTime = DateTime.now().subtract(const Duration(seconds: 60));

        final event = TransactionEvent(
          id: widget.transactionEventId,
          eventId: widget.transactionEventId ?? '',
          eventTime: eventTime,
          recordTime: DateTime.now(),
          eventTimeZoneOffset:
              _eventTimeZoneOffset, // Use our formatted timezone
          epcisVersion: EPCISVersion.v2_0,
          action: _selectedAction,
          disposition: disposition.isEmpty ? null : disposition,
          bizStep: businessStep.isEmpty ? null : businessStep,
          readPoint: locationGLN.isEmpty ? null : GLN.fromCode(locationGLN),
          bizLocation: locationGLN.isEmpty ? null : GLN.fromCode(locationGLN),
          bizData: bizData.isEmpty ? null : bizData,
          epcList: epcs.isEmpty ? null : epcs,
          bizTransactionList:
              bizTransactionType.isEmpty || bizTransactionId.isEmpty
              ? {}
              : {bizTransactionType: bizTransactionId},
        );

        await cubit.updateTransactionEvent(event);
      } else {
        // For creating a new event
        // Use a time that's definitely in the past (60 seconds ago) to avoid validation errors
        final eventTime = DateTime.now().subtract(const Duration(seconds: 60));

        if (_selectedAction == 'ADD') {
          await cubit.createAddTransactionEvent(
            bizTransactionType: bizTransactionType,
            bizTransactionId: bizTransactionId,
            epcs: epcs,
            locationGLN: locationGLN,
            businessStep: businessStep,
            disposition: disposition,
            bizData: bizData,
            eventTime: eventTime,
          );
        } else if (_selectedAction == 'DELETE') {
          await cubit.createDeleteTransactionEvent(
            bizTransactionType: bizTransactionType,
            bizTransactionId: bizTransactionId,
            epcs: epcs,
            locationGLN: locationGLN,
            businessStep: businessStep,
            disposition: disposition,
            bizData: bizData,
            eventTime: eventTime,
          );
        } else if (_selectedAction == 'OBSERVE') {
          // Use the dedicated method for creating OBSERVE events
          await cubit.createObserveTransactionEvent(
            bizTransactionType: bizTransactionType,
            bizTransactionId: bizTransactionId,
            epcs: epcs,
            locationGLN: locationGLN,
            businessStep: businessStep,
            disposition: disposition,
            bizData: bizData,
            eventTime: eventTime,
          );
        }
      }

      if (!mounted) return;

      showSuccessSnackBar(
        context,
        _isEdit ? 'Transaction event updated' : 'Transaction event created',
      );
      Navigator.pop(context, true);
    } catch (e) {
      showErrorSnackBar(context, e.toString());
    }
  }

  /// Show help screen
  void _showHelpScreen(BuildContext context) {
    context.push('/epcis/transaction-events/help');
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
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpScreen(context),
            tooltip: 'Help',
          ),
        ],
      ),
      body: BlocBuilder<TransactionEventsCubit, TransactionEventsState>(
        builder: (context, state) {
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
                  // Event Action
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
                  const SizedBox(height: 16), // Business Transaction Type
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
                  // Business Transaction ID
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
                  const SizedBox(height: 16), // EPCs
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _epcsController,
                              decoration: const InputDecoration(
                                labelText: 'EPCs (comma separated) *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter at least one EPC';
                                }

                                // Check if EPCs are in correct format
                                final epcList = value
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();
                                for (final epc in epcList) {
                                  if (!epc.startsWith('urn:epc:id:') &&
                                      !RegExp(r'\(\d+\)').hasMatch(epc)) {
                                    return 'Invalid EPC format: $epc';
                                  }
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Formats accepted:\n'
                              '• URI: urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber\n'
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
                              // Generate a random SGTIN
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
                              // Generate batch of SGTINs
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
                  const SizedBox(height: 16), // Location GLN
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationGLNController,
                          decoration: const InputDecoration(
                            labelText: 'Location GLN *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter location GLN';
                            }
                            // Check if the GLN is in valid format
                            if (!RegExp(r'^[0-9\.]+$').hasMatch(value)) {
                              return 'GLN should contain only digits and dots';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Generate a GLN
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
                  // Business Step
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Business Step *',
                      border: OutlineInputBorder(),
                    ),
                    value: _businessStep,
                    items: _standardBusinessSteps
                        .map(
                          (step) => DropdownMenuItem(
                            value: step,
                            child: Text(
                              step.split(':').last.replaceAll('bizstep:', ''),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _businessStep = value;
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
                  // Disposition
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Disposition *',
                      border: OutlineInputBorder(),
                    ),
                    value: _disposition,
                    items: _standardDispositions
                        .map(
                          (disp) => DropdownMenuItem(
                            value: disp,
                            child: Text(
                              disp.split(':').last.replaceAll('disp:', ''),
                            ),
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

                  // Event Time
                  ListTile(
                    title: const Text('Event Time'),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(_eventTime),
                    ),
                    trailing: const Icon(Icons.calendar_today),
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

                  // Business Data
                  const Text(
                    'Business Data',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  ..._buildBizDataFields(),

                  TextButton.icon(
                    onPressed: _addBizDataField,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Business Data Field'),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
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

  /// Build business data key-value fields
  List<Widget> _buildBizDataFields() {
    return List.generate(
      _bizDataControllers.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bizDataControllers[index].key,
                decoration: const InputDecoration(
                  labelText: 'Key',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Key is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _bizDataControllers[index].value,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Value is required';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeBizDataField(index),
            ),
          ],
        ),
      ),
    );
  }
}
