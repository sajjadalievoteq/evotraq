import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_types.dart' as types;
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/mixins/event_form_validation_mixin.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_form_field.dart';
import 'package:traqtrace_app/features/epcis/widgets/validation_error_widget.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_generator.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_utils.dart';
import 'package:traqtrace_app/features/epcis/widgets/object_event_help_widget.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/epcis/models/sensor_element.dart';
import 'package:traqtrace_app/features/epcis/models/certification_info.dart';
import 'package:traqtrace_app/features/epcis/widgets/sensor_element_widget.dart';
import 'package:traqtrace_app/features/epcis/widgets/certification_info_widget.dart';

/// Screen for creating, editing and viewing Object Events with support for GS1 EPCIS 2.0
class ObjectEventFormScreen extends StatefulWidget {
  /// Object event to edit or view, null for creation
  final ObjectEvent? event;

  /// Whether this is view-only mode (no editing)
  final bool isViewOnly;

  /// Constructor
  const ObjectEventFormScreen({Key? key, this.event, this.isViewOnly = false})
    : super(key: key);

  @override
  State<ObjectEventFormScreen> createState() => _ObjectEventFormScreenState();
}

class _ObjectEventFormScreenState extends State<ObjectEventFormScreen>
    with EventFormValidationMixin<ObjectEventFormScreen> {
  // Flag to track if validation is in progress
  bool _validating = false;

  // Store validation errors
  List<dynamic> _validationErrors = [];
  final _formKey = GlobalKey<FormState>();

  // Form fields
  late DateTime _eventTime;
  late String _eventTimeZone;
  String? _action;
  String? _businessStep;
  String? _disposition;
  String? _readPointGLN;
  String? _businessLocationGLN;
  String? _lotNumber;

  final List<String> _epcList = [];
  final List<String> _epcClassList = [];
  final List<types.QuantityElement> _quantityList = [];
  final Map<String, dynamic> _ilmd = {};
  final Map<String, String> _bizData = {};
  final List<types.SourceDestination> _sourceList = [];
  final List<types.SourceDestination> _destinationList = [];
  String? _persistentDisposition;

  // EPCIS 2.0 extensions
  final List<SensorElement> _sensorElementList = [];
  final List<CertificationInfo> _certificationInfoList = [];
  EPCISVersion _epcisVersion = EPCISVersion.v2_0;

  bool _isLoading = false;
  String? _errorMessage;

  // GS1 standard business steps - filtered to those relevant for Object Events
  final List<String> _standardBusinessSteps = [
    'urn:epcglobal:cbv:bizstep:commissioning',
    'urn:epcglobal:cbv:bizstep:shipping',
    'urn:epcglobal:cbv:bizstep:receiving',
    'urn:epcglobal:cbv:bizstep:packing',
    'urn:epcglobal:cbv:bizstep:unpacking',
    'urn:epcglobal:cbv:bizstep:inspecting',
    'urn:epcglobal:cbv:bizstep:storing',
    'urn:epcglobal:cbv:bizstep:picking',
    'urn:epcglobal:cbv:bizstep:loading',
    'urn:epcglobal:cbv:bizstep:unloading',
    'urn:epcglobal:cbv:bizstep:dispensing',
    'urn:epcglobal:cbv:bizstep:destroying',
    'urn:epcglobal:cbv:bizstep:decommissioning',
  ];

  // GS1 standard dispositions - filtered for Object Events
  final List<String> _standardDispositions = [
    'urn:epcglobal:cbv:disp:active',
    'urn:epcglobal:cbv:disp:available',
    'urn:epcglobal:cbv:disp:in_progress',
    'urn:epcglobal:cbv:disp:in_transit',
    'urn:epcglobal:cbv:disp:expired',
    'urn:epcglobal:cbv:disp:damaged',
    'urn:epcglobal:cbv:disp:destroyed',
    'urn:epcglobal:cbv:disp:dispensed',
    'urn:epcglobal:cbv:disp:recalled',
    'urn:epcglobal:cbv:disp:retail_sold',
    'urn:epcglobal:cbv:disp:returned',
    'urn:epcglobal:cbv:disp:sellable_accessible',
    'urn:epcglobal:cbv:disp:sellable_not_accessible',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize with existing data if editing
    if (widget.event != null) {
      _initializeWithEvent(widget.event!);
    } else {
      // Default values for new event
      _eventTime = DateTime.now();
      // Format timezone offset properly for backend (e.g., "+05:00" or "-08:00")
      final offset = DateTime.now().timeZoneOffset;
      final hours = offset.inHours.abs();
      final minutes = (offset.inMinutes.abs() % 60);
      final sign = offset.isNegative ? '-' : '+';
      _eventTimeZone =
          '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

      // Set default action if none provided
      _action = 'ADD';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only process query parameters if this is a new event (not editing)
    if (widget.event == null) {
      // Get query parameters from GoRouter
      final queryParams = GoRouter.of(
        context,
      ).routeInformationProvider.value.uri.queryParameters;

      // Handle bizStep parameter
      if (queryParams.containsKey('bizStep')) {
        setState(() {
          // Check if the bizStep is a full URN or just the final part
          final bizStep = queryParams['bizStep']!;
          if (bizStep.startsWith('urn:epcglobal:cbv:bizstep:')) {
            _businessStep = bizStep;
          } else {
            _businessStep = 'urn:epcglobal:cbv:bizstep:$bizStep';
          }
        });
      }

      // Handle action parameter
      if (queryParams.containsKey('action')) {
        setState(() {
          _action = queryParams['action']!;
        });
      }

      // Handle epcs parameter (comma-separated list of EPCs to commission)
      if (queryParams.containsKey('epcs')) {
        setState(() {
          final epcsList = queryParams['epcs']!.split(',');
          _epcList.addAll(
            epcsList.map((e) => e.trim()).where((e) => e.isNotEmpty),
          );
        });
      }
    }
  }

  // Helper to initialize all fields from an event
  void _initializeWithEvent(ObjectEvent event) {
    _eventTime = event.eventTime;
    _eventTimeZone = event.eventTimeZone;
    _action = event.action;
    _businessStep = event.businessStep;
    _disposition = event.disposition;
    _readPointGLN = event.readPoint?.glnCode;
    _businessLocationGLN = event.businessLocation?.glnCode;

    if (event.epcList != null) {
      _epcList.addAll(event.epcList!);
    }

    if (event.epcClassList != null) {
      _epcClassList.addAll(event.epcClassList!);
    }

    if (event.quantityList != null) {
      _quantityList.addAll(event.quantityList!);
    }

    if (event.bizData != null) {
      _bizData.addAll(event.bizData!);
    }

    if (event.ilmd != null) {
      _ilmd.addAll(event.ilmd!);
      // Extract lot number from ILMD if present
      _lotNumber =
          event.ilmd!['lot']?.toString() ?? event.ilmd!['lotID']?.toString();
    }

    if (event.sourceList != null) {
      _sourceList.addAll(event.sourceList!);
    }

    if (event.destinationList != null) {
      _destinationList.addAll(event.destinationList!);
    }

    if (event.persistentDisposition != null) {
      _persistentDisposition = event.persistentDisposition;
    }

    // Initialize EPCIS 2.0 extensions if available
    if (event.sensorElementList != null) {
      try {
        _sensorElementList.addAll(
          _mapListToSensorElementList(event.sensorElementList!),
        );
      } catch (error) {
        // If there's an error, create fresh empty sensor list
        _sensorElementList.clear();
      }
    }

    if (event.certificationInfo != null) {
      _certificationInfoList.addAll(
        _mapListToCertificationInfoList(event.certificationInfo!),
      );
    }

    // Set EPCIS version
    _epcisVersion = event.epcisVersion ?? EPCISVersion.v1_3;

    // Update UI
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _selectEventTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _eventTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_eventTime),
      );

      if (pickedTime != null) {
        setState(() {
          _eventTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addEpc() {
    showDialog(
      context: context,
      builder: (context) {
        String epc = '';
        return AlertDialog(
          title: const Text('Add EPC'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'EPC',
                  hintText: 'Enter EPC value or scan barcode',
                ),
                onChanged: (value) {
                  epc = value;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Formats accepted:\n'
                '• URI: urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber\n'
                '• GS1: (01)05415062325810(21)70005188444899',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Barcode'),
                onPressed: () async {
                  Navigator.pop(context);
                  _scanBarcode();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (epc.isNotEmpty) {
                  setState(() {
                    // Format EPC to URI if it's in GS1 barcode format
                    final formattedEpc = EPCFormatter.formatToEPCUri(epc);
                    _epcList.add(formattedEpc);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _generateEpc() {
    showDialog(
      context: context,
      builder: (context) {
        String companyPrefix = '0614141';
        String itemReference = '107346';
        int count = 1;
        int startSerial = 1000;

        return AlertDialog(
          title: const Text('Generate GS1 EPCs'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Company Prefix',
                        hintText: 'Enter GS1 Company Prefix',
                      ),
                      initialValue: companyPrefix,
                      onChanged: (value) {
                        companyPrefix = value;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Item Reference',
                        hintText: 'Enter Item Reference',
                      ),
                      initialValue: itemReference,
                      onChanged: (value) {
                        itemReference = value;
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Count',
                              hintText: 'Number of EPCs',
                            ),
                            initialValue: '1',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                count = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Start Serial',
                              hintText: 'Starting serial number',
                            ),
                            initialValue: '1000',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                startSerial = int.tryParse(value) ?? 1000;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Will generate $count SGTIN(s) starting from $startSerial',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'SGTINs follow format: urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (companyPrefix.isNotEmpty && itemReference.isNotEmpty) {
                  // Generate SGTINs
                  final sgitns = GS1Generator.generateBatchSGTINs(
                    companyPrefix,
                    itemReference,
                    count,
                    startSerial: startSerial,
                  );

                  // Add to EPCs list
                  setState(() {
                    _epcList.addAll(sgitns);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  void _bulkAddEpcs() {
    showDialog(
      context: context,
      builder: (context) {
        String bulkEpcs = '';
        return AlertDialog(
          title: const Text('Bulk Add EPCs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'EPCs (one per line)',
                  hintText: 'Enter multiple EPCs, one per line',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  bulkEpcs = value;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Each line should contain one EPC. Format: urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (bulkEpcs.isNotEmpty) {
                  final lines = bulkEpcs.split('\n');
                  setState(() {
                    for (final line in lines) {
                      final trimmed = line.trim();
                      if (trimmed.isNotEmpty) {
                        // Format each EPC to URI if it's in GS1 barcode format
                        final formattedEpc = EPCFormatter.formatToEPCUri(
                          trimmed,
                        );
                        _epcList.add(formattedEpc);
                      }
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add All'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('GS1 Object Event Help'),
                centerTitle: true,
                automaticallyImplyLeading: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: const ObjectEventHelpWidget(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _scanBarcode() async {
    // This is a placeholder for barcode scanning functionality
    // In a real implementation, you would integrate a barcode scanning package
    // such as flutter_barcode_scanner or mobile_scanner

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Barcode Scanner'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, size: 48),
              SizedBox(height: 16),
              Text('This is a placeholder for the barcode scanner.'),
              SizedBox(height: 8),
              Text(
                'In a production app, this would launch the device camera to scan GS1 barcodes.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Simulate scanning a URI format barcode
                final demoEpc =
                    'urn:epc:id:sgtin:0614141.107346.${DateTime.now().millisecondsSinceEpoch % 10000}';
                setState(() {
                  _epcList.add(demoEpc);
                });
                Navigator.pop(context);
              },
              child: const Text('Simulate URI Scan'),
            ),
            TextButton(
              onPressed: () {
                // Simulate scanning a GS1 barcode format
                final demoGS1 =
                    '(01)00614141107346(21)${DateTime.now().millisecondsSinceEpoch % 10000}';
                final formattedEpc = EPCFormatter.formatToEPCUri(demoGS1);
                setState(() {
                  _epcList.add(formattedEpc);
                });
                Navigator.pop(context);
              },
              child: const Text('Simulate GS1 Scan'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addEpcClass() {
    showDialog(
      context: context,
      builder: (context) {
        String epcClass = '';
        return AlertDialog(
          title: const Text('Add EPC Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'EPC Class',
                  hintText: 'Enter EPC class value',
                ),
                onChanged: (value) {
                  epcClass = value;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Format: urn:epc:idpat:sgtin:CompanyPrefix.ItemReference.*',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (epcClass.isNotEmpty) {
                  setState(() {
                    _epcClassList.add(epcClass);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addQuantity() {
    showDialog(
      context: context,
      builder: (context) {
        String epcClass = '';
        double quantity = 0;
        String? uom;
        return AlertDialog(
          title: const Text('Add Quantity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'EPC Class',
                  hintText: 'Enter EPC class',
                ),
                onChanged: (value) {
                  epcClass = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity value',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = double.tryParse(value) ?? 0;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Unit of Measure (optional)',
                  hintText: 'E.g., KGM, EA, CS',
                ),
                onChanged: (value) {
                  uom = value.isNotEmpty ? value : null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (epcClass.isNotEmpty && quantity > 0) {
                  setState(() {
                    _quantityList.add(
                      types.QuantityElement(
                        epcClass: epcClass,
                        quantity: quantity,
                        uom: uom,
                      ),
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addIlmd() {
    showDialog(
      context: context,
      builder: (context) {
        String key = '';
        String value = '';
        return AlertDialog(
          title: const Text('Add Instance/Lot Master Data (ILMD)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Key',
                  hintText: 'Enter key',
                ),
                onChanged: (val) {
                  key = val;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Value',
                  hintText: 'Enter value',
                ),
                onChanged: (val) {
                  value = val;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (key.isNotEmpty && value.isNotEmpty) {
                  setState(() {
                    _ilmd[key] = value;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addSource() {
    showDialog(
      context: context,
      builder: (context) {
        String type = 'owning_party';
        String id = '';
        return AlertDialog(
          title: const Text('Add Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Source Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'owning_party',
                    child: Text('Owning Party'),
                  ),
                  DropdownMenuItem(
                    value: 'possessing_party',
                    child: Text('Possessing Party'),
                  ),
                  DropdownMenuItem(value: 'location', child: Text('Location')),
                ],
                onChanged: (value) {
                  type = value!;
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'GLN or Identifier',
                  hintText: 'e.g., 0614141000005',
                ),
                onChanged: (value) {
                  id = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (id.isNotEmpty) {
                  setState(() {
                    _sourceList.add(
                      types.SourceDestination(type: type, id: id),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addDestination() {
    showDialog(
      context: context,
      builder: (context) {
        String type = 'owning_party';
        String id = '';
        return AlertDialog(
          title: const Text('Add Destination'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(
                  labelText: 'Destination Type',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'owning_party',
                    child: Text('Owning Party'),
                  ),
                  DropdownMenuItem(
                    value: 'possessing_party',
                    child: Text('Possessing Party'),
                  ),
                  DropdownMenuItem(value: 'location', child: Text('Location')),
                ],
                onChanged: (value) {
                  type = value!;
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'GLN or Identifier',
                  hintText: 'e.g., 0614141000005',
                ),
                onChanged: (value) {
                  id = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (id.isNotEmpty) {
                  setState(() {
                    _destinationList.add(
                      types.SourceDestination(type: type, id: id),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  /// Mark for required fields
  Widget _buildRequiredIndicator() {
    return const Text(
      ' *',
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    );
  }

  /// Build validation status icon for form fields
  Widget _buildValidationStatus(String fieldName) {
    final error = getFieldError(fieldName);

    if (error != null && error.isNotEmpty) {
      return const Icon(Icons.error_outline, color: Colors.red, size: 20);
    } else if (hasFieldBeenValidated(fieldName)) {
      return const Icon(
        Icons.check_circle_outline,
        color: Colors.green,
        size: 20,
      );
    }

    return const SizedBox.shrink();
  }

  /// Check if a field is mandatory based on current EPCIS version and action
  bool _isFieldMandatory(String fieldName) {
    final bool isEpcis20 = _epcisVersion == EPCISVersion.v2_0;

    // Base mandatory fields for all EPCIS versions and actions
    final List<String> alwaysMandatory = [
      'action',
      'eventTime',
      'eventTimeZone',
    ];

    if (alwaysMandatory.contains(fieldName)) {
      return true;
    }

    // Check for fields that are always mandatory based on GS1 EPCIS standard
    if (['businessStep', 'disposition'].contains(fieldName)) {
      return true;
    }

    // Object identification is always required (either epcList or quantityList)
    if (fieldName == 'epcList' || fieldName == 'quantityList') {
      // Required if the other list is empty - one of them must have values
      return (_epcList.isEmpty && _quantityList.isEmpty);
    }

    // Fields required for ADD action (commissioning)
    if (_action == 'ADD') {
      if (fieldName == 'ilmd') {
        return true;
      }
      // Lot number is mandatory for commissioning events in pharmaceutical track and trace
      if (fieldName == 'lotNumber') {
        return true;
      }
      // For commissioning, bizData might be considered mandatory
      if (fieldName == 'bizData') {
        return false; // Set to true if required by your business rules
      }
    }

    // Fields required for OBSERVE action
    if (_action == 'OBSERVE') {
      if (fieldName == 'readPointGLN') {
        return true;
      }
    }

    // Location information
    if (fieldName == 'businessLocationGLN') {
      // Business location is always recommended and typically required
      return true;
    }

    // Fields specific to EPCIS 2.0
    if (isEpcis20) {
      if (fieldName == 'readPointGLN') {
        return true; // Read point is mandatory in EPCIS 2.0
      }

      if (fieldName == 'certificationInfo') {
        // certificationInfo is recommended for EPCIS 2.0 but not strictly required
        return false; // Set to true if you want to make it mandatory
      }

      if (fieldName == 'sensorElementList') {
        // Optional unless your business rules require it
        return false;
      }
    }

    return false;
  }

  /// Parse GLN from various formats (GS1, URI, etc.)
  String _parseGLNToCode(String gln) {
    // Remove any whitespace
    final cleanGLN = gln.trim();

    // Use GS1Utils to extract GLN code from various formats
    try {
      final result = GS1Utils.extractGLNCode(cleanGLN);
      if (result != null && result.isNotEmpty) {
        return result;
      }
    } catch (e) {
      // Fall back to manual parsing
    }

    // Check if it's already a standard GS1 format (13 digits)
    if (RegExp(r'^\d{13}$').hasMatch(cleanGLN)) {
      return cleanGLN;
    }

    // Check if it has dots (company prefix format like "1234567.89012")
    if (cleanGLN.contains('.') && !cleanGLN.startsWith('urn:')) {
      try {
        // Parse company prefix.location format
        final parts = cleanGLN.split('.');
        if (parts.length >= 2) {
          final companyPrefix = parts[0];
          final locationRef = parts[1].padLeft(5, '0');

          if (companyPrefix.length >= 7 && companyPrefix.length <= 10) {
            final glnWithoutCheck = companyPrefix + locationRef;
            final checkDigit = GS1Utils.calculateGS1CheckDigit(glnWithoutCheck);
            return glnWithoutCheck + checkDigit;
          }
        }
      } catch (e) {
        // If parsing fails, use as-is
      }
    }

    // Default to using as-is (might be already valid or will be validated later)
    return cleanGLN;
  }

  // Helper functions for converting sensor data and certification info will be implemented as needed

  // Methods for source/destination, sensor data, etc. would be added here
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    // Additional validation - need at least one EPC, EPC class, or quantity
    if (_epcList.isEmpty && _epcClassList.isEmpty && _quantityList.isEmpty) {
      setState(() {
        _errorMessage =
            'Per GS1 standard, you must add at least one EPC, EPC class, or quantity to identify the objects';
      });
      return;
    }

    // Validate ILMD for ADD events (commissioning)
    if (_action == 'ADD' && _ilmd.isEmpty) {
      setState(() {
        _errorMessage =
            'Instance/Lot Master Data (ILMD) is required for ADD (commissioning) events according to GS1 standard. Please add lot number.';
      });
      return;
    }

    // Additional validation checks that could cause 409 errors
    if (_action == 'ADD' &&
        (_lotNumber == null || _lotNumber!.trim().isEmpty)) {
      setState(() {
        _errorMessage =
            'Lot number is required for commissioning events (ADD action)';
      });
      return;
    }

    // Validate GLN formats before sending
    if (_businessLocationGLN != null && _businessLocationGLN!.isNotEmpty) {
      try {
        final parsedGLN = _parseGLNToCode(_businessLocationGLN!);
        if (parsedGLN.length != 13 ||
            !RegExp(r'^\d{13}$').hasMatch(parsedGLN)) {
          setState(() {
            _errorMessage =
                'Invalid Business Location GLN format: $_businessLocationGLN';
          });
          return;
        }
      } catch (e) {
        setState(() {
          _errorMessage =
              'Invalid Business Location GLN format: ${e.toString()}';
        });
        return;
      }
    }

    if (_readPointGLN != null && _readPointGLN!.isNotEmpty) {
      try {
        final parsedGLN = _parseGLNToCode(_readPointGLN!);
        if (parsedGLN.length != 13 ||
            !RegExp(r'^\d{13}$').hasMatch(parsedGLN)) {
          setState(() {
            _errorMessage = 'Invalid Read Point GLN format: $_readPointGLN';
          });
          return;
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Invalid Read Point GLN format: ${e.toString()}';
        });
        return;
      }
    }

    // Validate using the validation service before saving
    setState(() {
      _isLoading = true;
      _validating = true;
      _errorMessage = null;
      _validationErrors = [];
    });

    try {
      // Generate unique event ID for validation
      final eventId = 'event_${DateTime.now().millisecondsSinceEpoch}';
      final recordTime = DateTime.now();

      // Create an object event model for validation
      final objectEvent = ObjectEvent(
        eventId: eventId,
        recordTime: recordTime,
        eventTime: _eventTime,
        eventTimeZone: _eventTimeZone,
        epcisVersion: _epcisVersion,
        action: _action,
        disposition: _disposition,
        businessStep: _businessStep,
        readPoint: _readPointGLN != null ? GLN.fromCode(_readPointGLN!) : null,
        businessLocation: _businessLocationGLN != null
            ? GLN.fromCode(_businessLocationGLN!)
            : null,
        bizData: _bizData.isNotEmpty
            ? Map<String, String>.from(_bizData)
            : null,
        epcList: _epcList.isNotEmpty ? List<String>.from(_epcList) : null,
        epcClassList: _epcClassList.isNotEmpty
            ? List<String>.from(_epcClassList)
            : null,
        quantityList: _quantityList.isNotEmpty
            ? List<types.QuantityElement>.from(_quantityList)
            : null,
        ilmd: _ilmd.isNotEmpty ? Map<String, dynamic>.from(_ilmd) : null,
        sourceList: _sourceList.isNotEmpty
            ? List<types.SourceDestination>.from(_sourceList)
            : null,
        destinationList: _destinationList.isNotEmpty
            ? List<types.SourceDestination>.from(_destinationList)
            : null,
        persistentDisposition: _persistentDisposition,
        sensorElementList: _sensorElementList.isNotEmpty
            ? _sensorElementList
            : null,
        certificationInfo: _certificationInfoList.isNotEmpty
            ? _certificationInfoList
            : null,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _validating = false;
        _errorMessage = 'Error creating event: ${e.toString()}';
      });
      return;
    }

    // Get the validation provider and validate the event created above
    final validationProvider = context.read<ValidationCubit>();

    try {
      if (_action == null || _action!.isEmpty) {
        setState(() {
          _isLoading = false;
          _validating = false;
          _errorMessage = 'Action is required.';
        });
        return;
      }

      if (_businessStep == null || _businessStep!.isEmpty) {
        setState(() {
          _isLoading = false;
          _validating = false;
          _errorMessage = 'Business step is required.';
        });
        return;
      }

      if (_disposition == null || _disposition!.isEmpty) {
        setState(() {
          _isLoading = false;
          _validating = false;
          _errorMessage = 'Disposition is required.';
        });
        return;
      }

      if (_readPointGLN == null || _readPointGLN!.isEmpty) {
        setState(() {
          _isLoading = false;
          _validating = false;
          _errorMessage = 'Read point GLN is required.';
        });
        return;
      }

      GLN readPoint;
      try {
        readPoint = GLN.fromCode(_readPointGLN!);
      } catch (_) {
        setState(() {
          _isLoading = false;
          _validating = false;
          _errorMessage = 'Read point GLN is invalid.';
        });
        return;
      }

      // Check whether to use epcList or quantityList based on schema oneOf constraint
      // The schema requires one or the other, not both
      final bool useEpcList = _epcList.isNotEmpty;
      // If both are populated, we need to choose one based on schema requirements
      final bool hasQuantity = _quantityList.isNotEmpty;

      if (!useEpcList && !hasQuantity) {
        setState(() {
          _isLoading = false;
          _validating = false;
          _errorMessage = 'Provide either EPC List or Quantity List.';
        });
        return;
      }

      // Log decision for debugging
      print(
        "Schema decision: useEpcList=$useEpcList, hasQuantity=$hasQuantity",
      );
      // Force a clear choice when both are present - prefer epcList in this case
      if (useEpcList && hasQuantity) {
        print(
          "Both epcList and quantityList present - using epcList for schema validation",
        );
      }

      final eventToValidate = ObjectEvent(
        eventId: 'event_${DateTime.now().millisecondsSinceEpoch}',
        recordTime: DateTime.now(),
        eventTime: _eventTime,
        eventTimeZone: _eventTimeZone,
        // Always set EPCIS version to 2.0 to match schema requirement
        epcisVersion: EPCISVersion.v2_0,
        action: _action,
        disposition: _disposition,
        businessStep: _businessStep,
        readPoint: readPoint,
        businessLocation: _businessLocationGLN != null
            ? GLN.fromCode(_businessLocationGLN!)
            : null,
        bizData: _bizData.isNotEmpty
            ? Map<String, String>.from(_bizData)
            : null,
        // For the schema's oneOf constraint, only include either epcList or quantityList
        epcList: useEpcList ? List<String>.from(_epcList) : null,
        epcClassList: _epcClassList.isNotEmpty
            ? List<String>.from(_epcClassList)
            : null,
        quantityList: (!useEpcList && _quantityList.isNotEmpty)
            ? List<types.QuantityElement>.from(_quantityList)
            : null,
        ilmd: _ilmd.isNotEmpty ? Map<String, dynamic>.from(_ilmd) : null,
        sourceList: _sourceList.isNotEmpty
            ? List<types.SourceDestination>.from(_sourceList)
            : null,
        destinationList: _destinationList.isNotEmpty
            ? List<types.SourceDestination>.from(_destinationList)
            : null,
        persistentDisposition: _persistentDisposition,
        sensorElementList: _sensorElementList.isNotEmpty
            ? _sensorElementList
            : null,
        certificationInfo: _certificationInfoList.isNotEmpty
            ? _certificationInfoList
            : null,
      );

      // Debug the event payload before validation
      _debugObjectEvent(eventToValidate);

      final result = await validationProvider.validateObjectEvent(
        eventToValidate,
      );

      if (!result) {
        // Extract and show validation errors
        setState(() {
          _isLoading = false;
          _validating = false;
        });

        // Print the full validation response
        print('\n======== VALIDATION RESPONSE ========');
        print(
          'Validation response: ${validationProvider.state.lastValidationResult}',
        );
        print('Validation error: ${validationProvider.state.error}');
        print('======================================\n');

        // Extract error messages from the response
        final errors = _extractErrorMessages(
          validationProvider.state.lastValidationResult,
        );
        _validationErrors = errors;

        // If no specific errors but we have a general error, add it
        if (errors.isEmpty && validationProvider.state.error != null) {
          _validationErrors = [validationProvider.state.error!];
        }

        // If still no errors, add a generic message with the response details
        if (_validationErrors.isEmpty) {
          final responseJson =
              validationProvider.state.lastValidationResult?.toString() ??
              'No response data';
          _validationErrors = [
            'Validation failed with status 409: Enhanced validation failed',
            'Response: $responseJson',
            'This may indicate a schema validation error or missing required fields.',
          ];
        }

        if (_validationErrors.isNotEmpty) {
          // Display errors in a dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Validation Errors'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show the errors
                    ...errors
                        .map(
                          (error) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),

                    // Add helpful troubleshooting tips for 409 errors
                    if (errors.any(
                      (error) =>
                          error.contains('409') ||
                          error.contains('Enhanced validation failed'),
                    )) ...[
                      const Divider(height: 20),
                      const Text(
                        'Troubleshooting Tips:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Ensure all required fields are filled'),
                      const Text('• Check GLN formats (13 digits)'),
                      const Text('• Verify EPC format if using EPCs'),
                      const Text('• For ADD action: lot number is required'),
                      const Text('• Ensure proper business step format (CBV)'),
                      const Text(
                        '• Check that only one of EPC List or Quantity List is used',
                      ),
                    ],
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
        } else if (validationProvider.state.error != null) {
          setState(() {
            _errorMessage = validationProvider.state.error;
          });
        }
        return;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _validating = false;
        _errorMessage = 'Error validating event: ${e.toString()}';
      });
      return;
    }

    // Validation passed, proceed with saving
    setState(() {
      _validating = false;
    });

    // Second try block for handling the actual save operation
    try {
      final cubit = context.read<ObjectEventsCubit>();

      if (widget.event != null) {
        // Update existing event
        final updatedEvent = ObjectEvent(
          id: widget.event!.id,
          eventId: widget.event!.eventId,
          eventTime: _eventTime,
          recordTime: widget.event!.recordTime,
          eventTimeZone: _eventTimeZone,
          epcisVersion: _epcisVersion,
          action: _action,
          disposition: _disposition,
          businessStep: _businessStep,
          readPoint: _readPointGLN != null
              ? GLN.fromCode(_readPointGLN!)
              : null,
          businessLocation: _businessLocationGLN != null
              ? GLN.fromCode(_businessLocationGLN!)
              : null,
          bizData: _bizData.isNotEmpty
              ? Map<String, String>.from(_bizData)
              : null,
          epcList: _epcList.isNotEmpty ? List<String>.from(_epcList) : null,
          epcClassList: _epcClassList.isNotEmpty
              ? List<String>.from(_epcClassList)
              : null,
          quantityList: _quantityList.isNotEmpty
              ? List<types.QuantityElement>.from(_quantityList)
              : null,
          ilmd: _ilmd.isNotEmpty ? Map<String, dynamic>.from(_ilmd) : null,
          sourceList: _sourceList.isNotEmpty
              ? List<types.SourceDestination>.from(_sourceList)
              : null,
          destinationList: _destinationList.isNotEmpty
              ? List<types.SourceDestination>.from(_destinationList)
              : null,
          persistentDisposition: _persistentDisposition,
          sensorElementList: _sensorElementList.isNotEmpty
              ? _sensorElementList
              : null,
          certificationInfo: _certificationInfoList.isNotEmpty
              ? _certificationInfoList
              : null,
        );

        await cubit.updateObjectEvent(updatedEvent);
      } else {
        // Create new event - use generic createObjectEvent method for all actions
        // This ensures all parameters including quantityList are properly handled
        await cubit.createObjectEvent(
          action: _action!,
          bizStep: _businessStep!,
          disposition: _disposition!,
          readPoint: _readPointGLN,
          bizLocation: _businessLocationGLN,
          epcList: _epcList.isNotEmpty ? _epcList : null,
          epcClassList: _epcClassList.isNotEmpty ? _epcClassList : null,
          quantityList: _quantityList.isNotEmpty ? _quantityList : null,
          ilmd: _ilmd,
          bizData: _bizData,
          sourceList: _sourceList,
          destinationList: _destinationList,
          persistentDisposition: _persistentDisposition,
          sensorElementList: _sensorElementList.isNotEmpty
              ? _sensorElementList.map((e) => e.toJson()).toList()
              : null,
          certificationInfo: _certificationInfoList.isNotEmpty
              ? _certificationInfoList.map((c) => c.toJson()).toList()
              : null,
        );
      }

      // Navigate back on success
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Helper method to disable interaction for view-only mode
  Widget _buildReadOnlyText(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value ?? 'Not provided', style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }

  // Helper method to render a list of items in view-only mode
  Widget _buildReadOnlyList(String label, List<String>? items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          if (items == null || items.isEmpty)
            const Text('No items')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map(
                    (item) =>
                        Text('• $item', style: const TextStyle(fontSize: 16)),
                  )
                  .toList(),
            ),
          const Divider(),
        ],
      ),
    );
  }

  // Helper method to render a map of key/value pairs in view-only mode
  Widget _buildReadOnlyMap(String label, Map<String, dynamic>? map) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          if (map == null || map.isEmpty)
            const Text('No items')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: map.entries
                  .map(
                    (entry) => Text(
                      '• ${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                  .toList(),
            ),
          const Divider(),
        ],
      ),
    );
  }

  /// Build EPCIS 2.0 extension sections
  Widget _buildEpcis20ExtensionSections() {
    // Always show EPCIS 2.0 extensions if we have data, regardless of the version
    // This ensures extensions are visible when backend sends v2.0 data
    bool hasSensorData = _sensorElementList.isNotEmpty;
    bool hasCertificationInfo = _certificationInfoList.isNotEmpty;

    // If no EPCIS 2.0 data and not using EPCIS 2.0, don't show the section
    if (!hasSensorData &&
        !hasCertificationInfo &&
        _epcisVersion != EPCISVersion.v2_0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider with EPCIS 2.0 Extensions title
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[400])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'EPCIS 2.0 Extensions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[400])),
            ],
          ),
        ),

        // Sensor Data Section
        Card(
          margin: const EdgeInsets.only(top: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sensor Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                SensorElementWidget(
                  sensorElements: _sensorElementList,
                  onSensorElementsChanged: (elements) {
                    setState(() {
                      _sensorElementList.clear();
                      _sensorElementList.addAll(elements);
                    });
                  },
                  isViewOnly: widget.isViewOnly,
                ),
              ],
            ),
          ),
        ),

        // Certification Info Section
        Card(
          margin: const EdgeInsets.only(top: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Certification Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                CertificationInfoWidget(
                  certifications: _certificationInfoList,
                  onCertificationsChanged: (certifications) {
                    setState(() {
                      _certificationInfoList.clear();
                      _certificationInfoList.addAll(certifications);
                    });
                  },
                  isViewOnly: widget.isViewOnly,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build a validated dropdown form field
  Widget _buildValidatedDropdownField({
    required String fieldName,
    required String labelText,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? helpText,
    String? Function(String?)? validator,
  }) {
    return ValidatedFormField(
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '$labelText is required';
            }
            return null;
          },
      helpText: helpText,
      validateOnChange: true,
      validateOnBlur: true,
      formField: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        items: items,
        onChanged: (val) {
          // Call the provided onChanged function
          onChanged(val);

          // Update validation state
          if (validator != null) {
            final error = validator(val);
            setFieldError(fieldName, error);
          }
        },
      ),
    );
  }

  /// Build a label with mandatory indicator for form fields
  Widget _buildFieldLabel(String label, bool isMandatory) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (isMandatory)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  /// Get field decoration with validation status
  InputDecoration _getFieldDecoration({
    required String fieldName,
    required String label,
    String? hintText,
    bool isMandatory = false,
  }) {
    final error = getFieldError(fieldName);
    final hasBeenValidated = hasFieldBeenValidated(fieldName);

    return InputDecoration(
      hintText: hintText,
      border: const OutlineInputBorder(),
      // Add a red asterisk to the label if the field is mandatory
      label: _buildFieldLabel(label, isMandatory),
      // Show validation status with appropriate icon
      suffixIcon: error != null && error.isNotEmpty
          ? const Icon(Icons.error_outline, color: Colors.red)
          : hasBeenValidated
          ? const Icon(Icons.check_circle_outline, color: Colors.green)
          : null,
      // Show error message if there's an error
      errorText: error,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to update from provider data when in view-only mode
    if (widget.isViewOnly) {
      final state = context.watch<ObjectEventsCubit>().state;

      // Always check if we need to update from provider data
      if (widget.event == null && state.selectedEvent != null) {
        _initializeWithEvent(state.selectedEvent!);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isViewOnly
              ? 'Object Event Details'
              : (widget.event != null
                    ? 'Edit Object Event'
                    : 'Create Object Event'),
        ),
        actions: [
          if (!widget.isViewOnly)
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showHelpDialog,
              tooltip: 'GS1 Object Event Help',
            ),
          // Only show the save button when not in view-only mode
          if (!widget.isViewOnly)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveEvent,
              tooltip: 'Save',
            ),
          // Add a test button for debugging schema issues
          if (!widget.isViewOnly)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: _isLoading ? null : _runSchemaValidationTest,
              tooltip: 'Test Schema',
            ),
        ],
      ),
      body:
          _isLoading ||
              (widget.isViewOnly &&
                  widget.event == null &&
                  context.watch<ObjectEventsCubit>().state.selectedEvent ==
                      null)
          ? const Center(child: AppLoadingIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Display validation errors if any
                    if (_validationErrors.isNotEmpty)
                      ValidationErrorWidget(
                        validationErrors: _validationErrors,
                        onDismiss: () {
                          setState(() {
                            _validationErrors = [];
                          });
                        },
                      ),

                    // Display general error message if any
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _errorMessage = null;
                                });
                              },
                              color: Colors.red.shade700,
                            ),
                          ],
                        ),
                      ),
                    // EPCIS Version
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EPCIS Version',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            DropdownButtonFormField<EPCISVersion>(
                              value: _epcisVersion,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: EPCISVersion.values
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(v.toString()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: widget.isViewOnly
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _epcisVersion = value!;
                                      });
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Event Time
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Event Time (required)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Date & Time: ${_eventTime.toLocal()}',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: widget.isViewOnly
                                      ? null
                                      : _selectEventTime,
                                ),
                              ],
                            ),
                            TextFormField(
                              initialValue: _eventTimeZone,
                              decoration: _getFieldDecoration(
                                fieldName: 'eventTimeZone',
                                label: 'Time Zone',
                                hintText: 'e.g. +01:00',
                                isMandatory: _isFieldMandatory('eventTimeZone'),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  final error =
                                      'Time zone is required by GS1 standard';
                                  setFieldError('eventTimeZone', error);
                                  return error;
                                }
                                setFieldError('eventTimeZone', null);
                                return null;
                              },
                              onChanged: widget.isViewOnly
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _eventTimeZone = value;
                                        // Validate immediately for real-time feedback
                                        validateField('eventTimeZone', value, (
                                          val,
                                        ) {
                                          if (val.isEmpty) {
                                            return 'Time zone is required by GS1 standard';
                                          }
                                          return null;
                                        });
                                      });
                                    },
                              readOnly: widget.isViewOnly,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Action
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Action (required)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            widget.isViewOnly
                                ? _buildReadOnlyText('Action', _action)
                                : DropdownButtonFormField<String>(
                                    value: _action,
                                    decoration: _getFieldDecoration(
                                      fieldName: 'action',
                                      label: 'Action',
                                      hintText: 'Select an action',
                                      isMandatory: _isFieldMandatory('action'),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'ADD',
                                        child: Text('ADD'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'OBSERVE',
                                        child: Text('OBSERVE'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'DELETE',
                                        child: Text('DELETE'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        final error =
                                            'Action is required by GS1 standard (ADD, OBSERVE, or DELETE)';
                                        setFieldError('action', error);
                                        return error;
                                      }
                                      setFieldError('action', null);
                                      return null;
                                    },
                                    onChanged: widget.isViewOnly
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _action = value;
                                              // Mark as valid when a value is selected
                                              markFieldAsValid('action');
                                              // Trigger re-validation of mandatory fields that depend on action
                                              if (mounted) {
                                                Future.delayed(
                                                  const Duration(
                                                    milliseconds: 100,
                                                  ),
                                                  () {
                                                    _formKey.currentState
                                                        ?.validate();
                                                  },
                                                );
                                              }
                                            });
                                          },
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Business Step & Disposition
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Business Context (required)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            if (widget.isViewOnly)
                              _buildReadOnlyText('Business Step', _businessStep)
                            else
                              DropdownButtonFormField<String>(
                                value: _businessStep,
                                decoration: _getFieldDecoration(
                                  fieldName: 'businessStep',
                                  label: 'Business Step',
                                  hintText: 'Select a business step',
                                  isMandatory: _isFieldMandatory(
                                    'businessStep',
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Custom...'),
                                  ),
                                  ..._standardBusinessSteps
                                      .map(
                                        (step) => DropdownMenuItem(
                                          value: step,
                                          child: Text(step.split(':').last),
                                        ),
                                      )
                                      .toList(),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    final error =
                                        'Business Step is required by GS1 standard';
                                    setFieldError('businessStep', error);
                                    return error;
                                  }

                                  // Validate format if not using a standard step
                                  if (!_standardBusinessSteps.contains(value) &&
                                      !value.startsWith(
                                        'urn:epcglobal:cbv:bizstep:',
                                      )) {
                                    final error =
                                        'Business Step should follow the GS1 CBV format';
                                    setFieldError('businessStep', error);
                                    return error;
                                  }

                                  setFieldError('businessStep', null);
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    if (value == null) {
                                      // Show dialog for custom entry
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          String customValue = '';
                                          return AlertDialog(
                                            title: const Text(
                                              'Custom Business Step',
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Enter a custom business step following GS1 CBV format:',
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  autofocus: true,
                                                  decoration: const InputDecoration(
                                                    hintText:
                                                        'urn:epcglobal:cbv:bizstep:custom_step',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  onChanged: (value) {
                                                    customValue = value;
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  if (customValue.isNotEmpty) {
                                                    setState(() {
                                                      _businessStep =
                                                          customValue;
                                                    });
                                                    // Validate the custom value
                                                    validateField(
                                                      'businessStep',
                                                      customValue,
                                                      (value) {
                                                        if (!value.startsWith(
                                                          'urn:epcglobal:cbv:bizstep:',
                                                        )) {
                                                          return 'Business Step should follow the GS1 CBV format';
                                                        }
                                                        return null;
                                                      },
                                                    );
                                                  }
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Save'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      _businessStep = value;
                                      // Mark field as validated when a standard value is selected
                                      markFieldAsValid('businessStep');
                                    }
                                  });
                                },
                              ),
                            const SizedBox(height: 8.0),
                            if (widget.isViewOnly)
                              _buildReadOnlyText('Disposition', _disposition)
                            else
                              DropdownButtonFormField<String>(
                                value: _disposition,
                                decoration: _getFieldDecoration(
                                  fieldName: 'disposition',
                                  label: 'Disposition',
                                  hintText: 'Select a disposition',
                                  isMandatory: _isFieldMandatory('disposition'),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Custom...'),
                                  ),
                                  ..._standardDispositions
                                      .map(
                                        (disp) => DropdownMenuItem(
                                          value: disp,
                                          child: Text(disp.split(':').last),
                                        ),
                                      )
                                      .toList(),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    final error =
                                        'Disposition is required by GS1 standard';
                                    setFieldError('disposition', error);
                                    return error;
                                  }
                                  setFieldError('disposition', null);
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    if (value == null) {
                                      // Show dialog for custom entry
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          String customValue = '';
                                          return AlertDialog(
                                            title: const Text(
                                              'Custom Disposition',
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Enter a custom disposition following GS1 CBV format:',
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  autofocus: true,
                                                  decoration: const InputDecoration(
                                                    hintText:
                                                        'urn:epcglobal:cbv:disp:custom_disposition',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  onChanged: (value) {
                                                    customValue = value;
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  if (customValue.isNotEmpty) {
                                                    setState(() {
                                                      _disposition =
                                                          customValue;
                                                    });
                                                    // Validate the custom value
                                                    validateField(
                                                      'disposition',
                                                      customValue,
                                                      (value) {
                                                        if (!value.startsWith(
                                                          'urn:epcglobal:cbv:disp:',
                                                        )) {
                                                          return 'Disposition should follow the GS1 CBV format';
                                                        }
                                                        return null;
                                                      },
                                                    );
                                                  }
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Save'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      _disposition = value;
                                      // Mark field as validated when a standard value is selected
                                      markFieldAsValid('disposition');
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Lot/Batch Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lot/Batch Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            widget.isViewOnly
                                ? _buildReadOnlyText(
                                    'Lot Number',
                                    _lotNumber ?? 'Not provided',
                                  )
                                : TextFormField(
                                    initialValue: _lotNumber,
                                    decoration: _getFieldDecoration(
                                      fieldName: 'lotNumber',
                                      label: 'Lot Number',
                                      hintText:
                                          'Enter lot/batch number for pharmaceutical tracking',
                                      isMandatory: _isFieldMandatory(
                                        'lotNumber',
                                      ),
                                    ),
                                    validator: (value) {
                                      // Lot number is typically required for ADD action (commissioning)
                                      if (_action == 'ADD' &&
                                          (value == null ||
                                              value.trim().isEmpty)) {
                                        final error =
                                            'Lot number is required for commissioning events (ADD action)';
                                        setFieldError('lotNumber', error);
                                        return error;
                                      }

                                      if (value != null && value.isNotEmpty) {
                                        // Basic validation for lot number format
                                        if (value.trim().length < 2) {
                                          final error =
                                              'Lot number must be at least 2 characters long';
                                          setFieldError('lotNumber', error);
                                          return error;
                                        }

                                        // Check for invalid characters
                                        if (!RegExp(
                                          r'^[A-Za-z0-9\-_\.]+$',
                                        ).hasMatch(value.trim())) {
                                          final error =
                                              'Lot number can only contain letters, numbers, hyphens, underscores, and dots';
                                          setFieldError('lotNumber', error);
                                          return error;
                                        }
                                      }

                                      setFieldError('lotNumber', null);
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _lotNumber = value.trim().isEmpty
                                            ? null
                                            : value.trim();

                                        // Update ILMD with lot number
                                        if (_lotNumber != null &&
                                            _lotNumber!.isNotEmpty) {
                                          _ilmd['lot'] = _lotNumber;
                                        } else {
                                          _ilmd.remove('lot');
                                        }

                                        // Validate immediately for real-time feedback
                                        validateField('lotNumber', value, (
                                          val,
                                        ) {
                                          if (_action == 'ADD' &&
                                              val.trim().isEmpty) {
                                            return 'Lot number is required for commissioning events (ADD action)';
                                          }
                                          if (val.isNotEmpty) {
                                            if (val.trim().length < 2) {
                                              return 'Lot number must be at least 2 characters long';
                                            }
                                            if (!RegExp(
                                              r'^[A-Za-z0-9\-_\.]+$',
                                            ).hasMatch(val.trim())) {
                                              return 'Lot number can only contain letters, numbers, hyphens, underscores, and dots';
                                            }
                                          }
                                          return null;
                                        });
                                      });
                                    },
                                    readOnly: widget.isViewOnly,
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Location Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location Information (required)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            widget.isViewOnly
                                ? _buildReadOnlyText(
                                    'Business Location GLN',
                                    _businessLocationGLN ?? 'Not provided',
                                  )
                                : TextFormField(
                                    initialValue: _businessLocationGLN,
                                    decoration: _getFieldDecoration(
                                      fieldName: 'businessLocationGLN',
                                      label: 'Business Location GLN',
                                      hintText:
                                          'e.g., 0614141.00001.0 or urn:epc:id:sgln:0614141.00001.0',
                                      isMandatory: _isFieldMandatory(
                                        'businessLocationGLN',
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_isFieldMandatory(
                                            'businessLocationGLN',
                                          ) &&
                                          (value == null || value.isEmpty)) {
                                        final error =
                                            'Business Location GLN is required by GS1 standard';
                                        setFieldError(
                                          'businessLocationGLN',
                                          error,
                                        );
                                        return error;
                                      }

                                      if (value != null && value.isNotEmpty) {
                                        try {
                                          // Use the enhanced GLN parsing method
                                          final parsedGLN = _parseGLNToCode(
                                            value,
                                          );

                                          // Validate the parsed GLN format
                                          if (parsedGLN.length != 13 ||
                                              !RegExp(
                                                r'^\d{13}$',
                                              ).hasMatch(parsedGLN)) {
                                            final error =
                                                'Invalid GLN format. Expected 13 digits or valid GS1 format.';
                                            setFieldError(
                                              'businessLocationGLN',
                                              error,
                                            );
                                            return error;
                                          }

                                          // Mark as valid if parsing succeeded
                                          setFieldError(
                                            'businessLocationGLN',
                                            null,
                                          );
                                          return null;
                                        } catch (e) {
                                          final error =
                                              'Invalid GLN format: ${e.toString()}';
                                          setFieldError(
                                            'businessLocationGLN',
                                            error,
                                          );
                                          return error;
                                        }
                                      }

                                      setFieldError(
                                        'businessLocationGLN',
                                        null,
                                      );
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isEmpty) {
                                          _businessLocationGLN = null;
                                        } else {
                                          try {
                                            // Parse and store the GLN code
                                            _businessLocationGLN =
                                                _parseGLNToCode(value);
                                            // Validate immediately for real-time feedback
                                            validateField(
                                              'businessLocationGLN',
                                              value,
                                              (val) {
                                                if (_isFieldMandatory(
                                                      'businessLocationGLN',
                                                    ) &&
                                                    val.isEmpty) {
                                                  return 'Business Location GLN is required by GS1 standard';
                                                }
                                                if (val.isNotEmpty) {
                                                  final parsedGLN =
                                                      _parseGLNToCode(val);
                                                  if (parsedGLN.length != 13 ||
                                                      !RegExp(
                                                        r'^\d{13}$',
                                                      ).hasMatch(parsedGLN)) {
                                                    return 'Invalid GLN format. Expected 13 digits or valid GS1 format.';
                                                  }
                                                }
                                                return null;
                                              },
                                            );
                                          } catch (e) {
                                            _businessLocationGLN =
                                                value; // Store original if parsing fails
                                            setFieldError(
                                              'businessLocationGLN',
                                              'Invalid GLN format',
                                            );
                                          }
                                        }
                                      });
                                    },
                                  ),
                            const SizedBox(height: 8.0),
                            widget.isViewOnly
                                ? _buildReadOnlyText(
                                    'Read Point GLN',
                                    _readPointGLN ?? 'Not provided',
                                  )
                                : TextFormField(
                                    controller: TextEditingController(
                                      text: _readPointGLN,
                                    ),
                                    decoration: _getFieldDecoration(
                                      fieldName: 'readPointGLN',
                                      label: 'Read Point GLN',
                                      hintText:
                                          'e.g., 0614141.00777.0 or urn:epc:id:sgln:0614141.00777.0',
                                      isMandatory: _isFieldMandatory(
                                        'readPointGLN',
                                      ),
                                    ),
                                    validator: (value) {
                                      // Check if field is mandatory
                                      if (_isFieldMandatory('readPointGLN') &&
                                          (value == null || value.isEmpty)) {
                                        final error =
                                            'Read Point GLN is required for EPCIS 2.0';
                                        setFieldError('readPointGLN', error);
                                        return error;
                                      }

                                      if (value != null && value.isNotEmpty) {
                                        try {
                                          // Use the enhanced GLN parsing method
                                          final parsedGLN = _parseGLNToCode(
                                            value,
                                          );

                                          // Validate the parsed GLN format
                                          if (parsedGLN.length != 13 ||
                                              !RegExp(
                                                r'^\d{13}$',
                                              ).hasMatch(parsedGLN)) {
                                            final error =
                                                'Invalid GLN format. Expected 13 digits or valid GS1 format.';
                                            setFieldError(
                                              'readPointGLN',
                                              error,
                                            );
                                            return error;
                                          }

                                          // Mark as valid if parsing succeeded
                                          setFieldError('readPointGLN', null);
                                          return null;
                                        } catch (e) {
                                          final error =
                                              'Invalid GLN format: ${e.toString()}';
                                          setFieldError('readPointGLN', error);
                                          return error;
                                        }
                                      }

                                      setFieldError('readPointGLN', null);
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isEmpty) {
                                          _readPointGLN = null;
                                        } else {
                                          try {
                                            // Parse and store the GLN code
                                            _readPointGLN = _parseGLNToCode(
                                              value,
                                            );
                                            // Validate immediately for real-time feedback
                                            validateField('readPointGLN', value, (
                                              val,
                                            ) {
                                              if (_isFieldMandatory(
                                                    'readPointGLN',
                                                  ) &&
                                                  val.isEmpty) {
                                                return 'Read Point GLN is required for EPCIS 2.0';
                                              }
                                              if (val.isNotEmpty) {
                                                final parsedGLN =
                                                    _parseGLNToCode(val);
                                                if (parsedGLN.length != 13 ||
                                                    !RegExp(
                                                      r'^\d{13}$',
                                                    ).hasMatch(parsedGLN)) {
                                                  return 'Invalid GLN format. Expected 13 digits or valid GS1 format.';
                                                }
                                              }
                                              return null;
                                            });
                                          } catch (e) {
                                            _readPointGLN =
                                                value; // Store original if parsing fails
                                            setFieldError(
                                              'readPointGLN',
                                              'Invalid GLN format',
                                            );
                                          }
                                        }
                                      });
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // EPCs (Serialized Items)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'EPCs (Serialized Items - at least one object identifier required)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                if (!widget.isViewOnly)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.add_circle),
                                        onPressed: _addEpc,
                                        tooltip: 'Add EPC',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.format_list_bulleted,
                                        ),
                                        onPressed: _bulkAddEpcs,
                                        tooltip: 'Bulk Add EPCs',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.autorenew),
                                        onPressed: _generateEpc,
                                        tooltip: 'Generate EPC',
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            if (_epcList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'No EPCs added. Add at least one EPC for single items.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _epcList.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_epcList[index]),
                                    trailing: widget.isViewOnly
                                        ? null
                                        : IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                _epcList.removeAt(index);
                                              });
                                            },
                                          ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // EPC Classes (Class-Level Identifiers)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'EPC Classes (if not using EPCs)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle),
                                  onPressed: _addEpcClass,
                                  tooltip: 'Add EPC Class',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            if (_epcClassList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'No EPC classes added. Add EPC classes for class-level identification.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _epcClassList.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_epcClassList[index]),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          _epcClassList.removeAt(index);
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Quantities
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Quantities',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle),
                                  onPressed: _addQuantity,
                                  tooltip: 'Add Quantity',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            if (_quantityList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'No quantities added. Add quantities for class-level identification with amount.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _quantityList.length,
                                itemBuilder: (context, index) {
                                  final quantity = _quantityList[index];
                                  return ListTile(
                                    title: Text(
                                      '${quantity.quantity} ${quantity.uom ?? ""}',
                                    ),
                                    subtitle: Text(
                                      'EPC Class: ${quantity.epcClass}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          _quantityList.removeAt(index);
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Source List (EPCIS 2.0)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Source List (EPCIS 2.0)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                if (!widget.isViewOnly)
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: _addSource,
                                    tooltip: 'Add Source',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            if (_sourceList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'No sources added. Sources identify the origin of products in the supply chain.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _sourceList.length,
                                itemBuilder: (context, index) {
                                  final source = _sourceList[index];
                                  return ListTile(
                                    title: Text(
                                      source.type
                                          .replaceAll('_', ' ')
                                          .toUpperCase(),
                                    ),
                                    subtitle: Text('ID: ${source.id}'),
                                    trailing: widget.isViewOnly
                                        ? null
                                        : IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                _sourceList.removeAt(index);
                                              });
                                            },
                                          ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Destination List (EPCIS 2.0)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Destination List (EPCIS 2.0)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                if (!widget.isViewOnly)
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: _addDestination,
                                    tooltip: 'Add Destination',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            if (_destinationList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'No destinations added. Destinations identify where products are going in the supply chain.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _destinationList.length,
                                itemBuilder: (context, index) {
                                  final destination = _destinationList[index];
                                  return ListTile(
                                    title: Text(
                                      destination.type
                                          .replaceAll('_', ' ')
                                          .toUpperCase(),
                                    ),
                                    subtitle: Text('ID: ${destination.id}'),
                                    trailing: widget.isViewOnly
                                        ? null
                                        : IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                _destinationList.removeAt(
                                                  index,
                                                );
                                              });
                                            },
                                          ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Event Summary
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Event Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Action: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: _action ?? 'Not selected'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Business Step: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _businessStep ?? 'Not selected',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Disposition: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _disposition ?? 'Not selected',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Location: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        _businessLocationGLN ?? 'Not selected',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Objects: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        [
                                          if (_epcList.isNotEmpty)
                                            '${_epcList.length} EPC(s)',
                                          if (_epcClassList.isNotEmpty)
                                            '${_epcClassList.length} EPC Class(es)',
                                          if (_quantityList.isNotEmpty)
                                            '${_quantityList.length} Quantity Item(s)',
                                        ].join(', ').isEmpty
                                        ? 'None'
                                        : [
                                            if (_epcList.isNotEmpty)
                                              '${_epcList.length} EPC(s)',
                                            if (_epcClassList.isNotEmpty)
                                              '${_epcClassList.length} EPC Class(es)',
                                            if (_quantityList.isNotEmpty)
                                              '${_quantityList.length} Quantity Item(s)',
                                          ].join(', '),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            if (_sourceList.isNotEmpty)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Sources: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _sourceList
                                          .map((s) => '${s.type}:${s.id}')
                                          .join(', '),
                                    ),
                                  ],
                                ),
                              ),
                            if (_sourceList.isNotEmpty)
                              const SizedBox(height: 4.0),
                            if (_destinationList.isNotEmpty)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Destinations: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _destinationList
                                          .map((d) => '${d.type}:${d.id}')
                                          .join(', '),
                                    ),
                                  ],
                                ),
                              ),
                            if (_destinationList.isNotEmpty)
                              const SizedBox(height: 4.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Time: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${_eventTime.toLocal()} (${_eventTimeZone})',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32.0),

                    // EPCIS 2.0 Extensions
                    _buildEpcis20ExtensionSections(),

                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: widget.isViewOnly
          ? null // No bottom button for view-only mode
          : BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: Text(
                    widget.event != null
                        ? 'Update Object Event'
                        : 'Create Object Event',
                  ),
                ),
              ),
            ),
    );
  }

  // These helper methods are kept for reference but not used directly
  /*
  List<Map<String, dynamic>> _sensorElementListToMapList(List<SensorElement> elements) {
    return elements.map((element) => element.toJson()).toList();
  }
  
  List<Map<String, dynamic>> _certificationInfoListToMapList(List<CertificationInfo> certifications) {
    return certifications.map((cert) => cert.toJson()).toList();
  }
  */

  /// Convert Map list to SensorElement list
  List<SensorElement> _mapListToSensorElementList(List<dynamic> maps) {
    final result = <SensorElement>[];

    for (final element in maps) {
      try {
        if (element is SensorElement) {
          result.add(element);
        } else if (element is Map<String, dynamic>) {
          result.add(SensorElement.fromJson(element));
        } else if (element is Map) {
          result.add(
            SensorElement.fromJson(Map<String, dynamic>.from(element)),
          );
        } else {
          // Return a default sensor element for non-map types
          result.add(SensorElement(measurements: []));
        }
      } catch (e) {
        // Add an empty sensor element to maintain list structure
        result.add(SensorElement(measurements: []));
      }
    }

    return result;
  }

  /// Convert Map list to CertificationInfo list
  List<CertificationInfo> _mapListToCertificationInfoList(List<dynamic> maps) {
    final result = <CertificationInfo>[];

    for (final map in maps) {
      try {
        if (map is CertificationInfo) {
          result.add(map);
        } else if (map is Map<String, dynamic>) {
          final certInfo = CertificationInfo.fromJson(map);
          result.add(certInfo);
        } else if (map is Map) {
          final typedMap = Map<String, dynamic>.from(map);
          result.add(CertificationInfo.fromJson(typedMap));
        }
      } catch (e) {
        // Silently handle errors, no debug logging needed in production
      }
    }

    return result;
  }

  /// Extract error messages from validation response
  List<String> _extractErrorMessages(Map<String, dynamic>? response) {
    final List<String> errorMessages = [];

    if (response == null) return errorMessages;

    // Debug print for development
    print('Validation response details: $response');

    // Check for the new error format with categories
    if (response.containsKey('errors')) {
      final errors = response['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        // Extract schema errors
        if (errors.containsKey('schema')) {
          final schemaErrors = errors['schema'] as List<dynamic>? ?? [];
          for (final error in schemaErrors) {
            errorMessages.add('Schema: $error');
          }
        }

        // Extract business rule errors
        if (errors.containsKey('businessRule')) {
          final businessRuleErrors =
              errors['businessRule'] as List<dynamic>? ?? [];
          for (final error in businessRuleErrors) {
            errorMessages.add('Business Rule: $error');
          }
        }

        // Extract reference data errors
        if (errors.containsKey('referenceData')) {
          final referenceDataErrors =
              errors['referenceData'] as List<dynamic>? ?? [];
          for (final error in referenceDataErrors) {
            errorMessages.add('Reference Data: $error');
          }
        }

        // Extract other errors
        if (errors.containsKey('other')) {
          final otherErrors = errors['other'] as List<dynamic>? ?? [];
          for (final error in otherErrors) {
            errorMessages.add('Other: $error');
          }
        }
      }
    }
    // Fallback to the old format
    else if (response.containsKey('validationErrors')) {
      final validationErrors =
          response['validationErrors'] as List<dynamic>? ?? [];
      for (final error in validationErrors) {
        if (error is String) {
          errorMessages.add(error);
        } else if (error is Map<String, dynamic>) {
          errorMessages.add(error.toString());
        } else {
          errorMessages.add(error.toString());
        }
      }
    }
    // Check for single error message
    else if (response.containsKey('error')) {
      final error = response['error'];
      errorMessages.add(error.toString());
    }
    // Check for message field
    else if (response.containsKey('message')) {
      final message = response['message'];
      errorMessages.add(message.toString());
    }

    // Check for status + message combination (409 error case)
    if (response.containsKey('status') && response.containsKey('message')) {
      final status = response['status'];
      final message = response['message'];
      if (status == 409) {
        errorMessages.add('HTTP $status: $message');

        // If this is the enhanced validation failure, add helpful context
        if (message.toString().contains('Enhanced validation failed')) {
          errorMessages.add(
            'Common causes: Missing required fields, invalid GLN/EPC formats, or schema validation errors',
          );
          errorMessages.add(
            'Please check that all required fields are filled and properly formatted',
          );
        }
      }
    }

    // If still no errors, try to extract any error-like information
    if (errorMessages.isEmpty) {
      response.forEach((key, value) {
        if (key.toLowerCase().contains('error') ||
            key.toLowerCase().contains('message')) {
          errorMessages.add('$key: $value');
        }
      });
    }

    return errorMessages;
  }

  /// Print debug info for the object event before saving
  void _debugObjectEvent(ObjectEvent event) {
    // Print a formatted version of the event payload
    print('\n======== OBJECT EVENT PAYLOAD ========');
    print('Event ID: ${event.eventId}');
    print('Event Type: ObjectEvent');
    print('Event Time: ${event.eventTime}');
    print('Record Time: ${event.recordTime}');
    print('Time Zone: ${event.eventTimeZone}');
    // Print actual string value that will be sent to the backend
    if (event.epcisVersion == EPCISVersion.v1_3) {
      print('EPCIS Version: 1.3');
    } else {
      print('EPCIS Version: 2.0');
    }
    print('Action: ${event.action}');
    print('Business Step: ${event.businessStep}');
    print('Disposition: ${event.disposition}');
    print('Read Point: ${event.readPoint?.glnCode}');
    print('Business Location: ${event.businessLocation?.glnCode}');

    // Debug the key fields that are causing schema validation issues
    print('\n---- Schema Validation Fields ----');
    print(
      'epcList: ${event.epcList != null ? "present (${event.epcList!.length} items)" : "null"}',
    );
    print(
      'quantityList: ${event.quantityList != null ? "present (${event.quantityList!.length} items)" : "null"}',
    );

    // Debug certification info (making sure it's an array)
    if (event.certificationInfo != null) {
      print(
        'certificationInfo: present (${event.certificationInfo!.length} items)',
      );
      print(
        'certificationInfo format: ${event.certificationInfo!.map((c) => c.toJson()).toList()}',
      );
    } else {
      print('certificationInfo: null');
    }

    if (event.epcList != null && event.epcList!.isNotEmpty) {
      print('\nEPCs: ${event.epcList!.length} items');
      for (final epc in event.epcList!.take(3)) {
        print('  - $epc');
      }
      if (event.epcList!.length > 3) {
        print('  - ... (${event.epcList!.length - 3} more)');
      }
    }

    if (event.ilmd != null && event.ilmd!.isNotEmpty) {
      print('\nILMD: ${event.ilmd!.length} items');
      event.ilmd!.forEach((key, value) {
        print('  - $key: $value');
      });
    }

    // Print the exact JSON that will be sent to backend
    print('\n---- JSON PAYLOAD TO BACKEND ----');
    try {
      final jsonPayload = event.toJson();
      print('Full JSON: $jsonPayload');
    } catch (e) {
      print('Error serializing to JSON: $e');
    }

    print('=====================================\n');
  }

  /// Test different event formats to debug schema validation issues
  Future<void> _runSchemaValidationTest() async {
    setState(() {
      _isLoading = true;
      _validating = true;
      _errorMessage = null;
      _validationErrors = [];
    });

    try {
      final validationProvider = context.read<ValidationCubit>();

      // Test with minimal event to identify core schema requirements
      final minimalEvent = ObjectEvent(
        eventId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        recordTime: DateTime.now(),
        eventTime: DateTime.now().subtract(const Duration(seconds: 5)),
        eventTimeZone: '+00:00',
        epcisVersion: EPCISVersion.v2_0,
        action: 'OBSERVE',
        // Using the oneOf constraint - include only epcList
        epcList: ['urn:epc:id:sgtin:0614141.107346.1000'],
        readPoint: GLN.fromCode('1234567890128'),
        // Always include a certification info object
        // Always send as array of certification info objects
        certificationInfo: [
          CertificationInfo(
            certificateId: "test-cert",
            certificationStandard: "test-standard",
            certificationAgency: "test-agency",
          ),
        ],
      );

      print("\n======== TESTING MINIMAL EVENT ========");
      _debugObjectEvent(minimalEvent);
      final minimalResult = await validationProvider.validateObjectEvent(
        minimalEvent,
      );
      print("Minimal event validation result: $minimalResult");

      // If minimal test failed, try with required fields only
      if (!minimalResult) {
        print("\n======== VALIDATION ERRORS ========");
      }

      // Show results in UI
      setState(() {
        _isLoading = false;
        _validating = false;
      });

      // Show test results dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Schema Validation Test Results'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minimal event test: ${minimalResult ? "PASSED" : "FAILED"}',
                ),
                if (!minimalResult)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Errors: ${validationProvider.state.error ?? "Unknown error"}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
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
    } catch (e) {
      setState(() {
        _isLoading = false;
        _validating = false;
        _errorMessage = 'Error in validation test: ${e.toString()}';
      });
    }
  }
}
