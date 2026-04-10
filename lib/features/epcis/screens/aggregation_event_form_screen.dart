import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_generator.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/features/epcis/widgets/validation_error_widget.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_utils.dart';
import 'package:traqtrace_app/features/epcis/models/sensor_element.dart' as models;
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart' as epcis_models;

import '../mixins/event_form_validation_mixin.dart';

/// Screen for creating or editing an aggregation event
class AggregationEventFormScreen extends StatefulWidget {
  /// The ID of the event to edit, null for creating a new event
  final String? aggregationEventId;

  /// Constructor
  const AggregationEventFormScreen({Key? key, this.aggregationEventId}) : super(key: key);

  @override
  State<AggregationEventFormScreen> createState() => _AggregationEventFormScreenState();
}

class _AggregationEventFormScreenState extends State<AggregationEventFormScreen> with EventFormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _validationErrors = [];
  bool _isEdit = false;
  
  // Form fields
  String _selectedAction = 'ADD';
  final _parentEPCController = TextEditingController();
  final _childEPCsController = TextEditingController();
  String? _businessStep;
  String? _disposition;
  final _locationGLNController = TextEditingController();
  
  // Source and destination lists
  final List<MapEntry<TextEditingController, TextEditingController>> _sourceListControllers = [];
  final List<MapEntry<TextEditingController, TextEditingController>> _destinationListControllers = [];
  
  // Business data key-value pairs
  final List<MapEntry<TextEditingController, TextEditingController>> _bizDataControllers = [];
    DateTime _eventTime = DateTime.now();
  String _eventTimeZoneOffset = "+00:00"; // Use standard ISO 8601 format for timezone
    // GS1 standard business steps relevant for pharmaceutical track and trace
  // Following GS1 Core Business Vocabulary (CBV) standard
  final List<String> _standardBusinessSteps = [
    'urn:epcglobal:cbv:bizstep:commissioning',  // Initial creation of object
    'urn:epcglobal:cbv:bizstep:packing',        // Adding objects to container
    'urn:epcglobal:cbv:bizstep:unpacking',      // Removing objects from container
    'urn:epcglobal:cbv:bizstep:shipping',       // Dispatching objects
    'urn:epcglobal:cbv:bizstep:receiving',      // Accepting objects into facility
    'urn:epcglobal:cbv:bizstep:accepting',      // Accepting ownership
    'urn:epcglobal:cbv:bizstep:storing',        // Putting objects in storage
    'urn:epcglobal:cbv:bizstep:loading',        // Loading for transport
    'urn:epcglobal:cbv:bizstep:unloading',      // Unloading from transport
    'urn:epcglobal:cbv:bizstep:decommissioning',// End of product life
    'urn:epcglobal:cbv:bizstep:destroying',     // Destroying or waste
    'urn:epcglobal:cbv:bizstep:inspecting',     // Quality inspection
    'urn:epcglobal:cbv:bizstep:dispensing',     // Dispensing for use
  ];
  
  // GS1 standard dispositions relevant for pharmaceutical track and trace
  // Following GS1 Core Business Vocabulary (CBV) standard
  final List<String> _standardDispositions = [
    'urn:epcglobal:cbv:disp:active',                // Object is active or in use
    'urn:epcglobal:cbv:disp:in_progress',           // Process is occurring
    'urn:epcglobal:cbv:disp:in_transit',            // Object is in transit
    'urn:epcglobal:cbv:disp:sold',                  // Object has been sold
    'urn:epcglobal:cbv:disp:expired',               // Object has expired
    'urn:epcglobal:cbv:disp:recalled',              // Object has been recalled
    'urn:epcglobal:cbv:disp:damaged',               // Object is damaged
    'urn:epcglobal:cbv:disp:destroyed',             // Object is destroyed
    'urn:epcglobal:cbv:disp:container_closed',      // Container is closed
    'urn:epcglobal:cbv:disp:container_open',        // Container is open
    'urn:epcglobal:cbv:disp:dispensed',             // Object has been dispensed
    'urn:epcglobal:cbv:disp:disposed',              // Object has been disposed
    'urn:epcglobal:cbv:disp:encoded',               // RFID tag has been encoded
    'urn:epcglobal:cbv:disp:returned',              // Object has been returned
    'urn:epcglobal:cbv:disp:sellable_accessible',   // Object can be sold
    'urn:epcglobal:cbv:disp:sellable_not_accessible', // Object can be sold but not accessible
    'urn:epcglobal:cbv:disp:reserved',              // Object is reserved
    'urn:epcglobal:cbv:disp:unknown',               // Disposition is unknown
  ];
  @override
  void initState() {
    super.initState();
    _isEdit = widget.aggregationEventId != null;
    
    // Format timezone offset in the ISO 8601 format
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    
    // Format as +/-HH:MM
    _eventTimeZoneOffset = '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    
    // Set default values for new events
    if (!_isEdit) {
      // Default business step and disposition for aggregation events
      _businessStep = 'urn:epcglobal:cbv:bizstep:packing';
      _disposition = 'urn:epcglobal:cbv:disp:in_progress';
      
      // Set default location GLN
      _locationGLNController.text = '6290360400006'; // Default demo GLN
    }
    
    if (_isEdit) {
      // Load existing event data if editing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAggregationEvent();
      });
    } else {
      // Add initial business data field for a new event
      _addBizDataField();
    }
  }
    @override
  void dispose() {
    _parentEPCController.dispose();
    _childEPCsController.dispose();
    _locationGLNController.dispose();
    
    for (var entry in _bizDataControllers) {
      entry.key.dispose();
      entry.value.dispose();
    }
    
    for (var entry in _sourceListControllers) {
      entry.key.dispose();
      entry.value.dispose();
    }
    
    for (var entry in _destinationListControllers) {
      entry.key.dispose();
      entry.value.dispose();
    }
    
    super.dispose();
  }
    Future<void> _loadAggregationEvent() async {
    if (widget.aggregationEventId == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final cubit = context.read<AggregationEventsCubit>();
      final event = await cubit.getAggregationEventById(widget.aggregationEventId!);
      
      if (event != null) {
        // Debug info about GLN
        print('Event details - readPoint: ${event.readPoint?.glnCode}');
        print('Event details - businessLocation: ${event.businessLocation?.glnCode}');
        
        setState(() {
          _selectedAction = event.action;
          _parentEPCController.text = event.parentID;
          _childEPCsController.text = event.childEPCs.join(', ');
          _businessStep = event.businessStep;
          _disposition = event.disposition;
          _eventTime = event.eventTime;
          _eventTimeZoneOffset = event.eventTimeZone;
          
          // Set location GLN from multiple possible sources
          if (event.businessLocation != null) {
            _locationGLNController.text = event.businessLocation!.glnCode;
          } else if (event.readPoint != null) {
            _locationGLNController.text = event.readPoint!.glnCode;
          }
          
          // Clear and populate business data
          for (var entry in _bizDataControllers) {
            entry.key.dispose();
            entry.value.dispose();
          }
          _bizDataControllers.clear();
          
          if (event.bizData != null && event.bizData!.isNotEmpty) {
            event.bizData!.forEach((key, value) {
              _bizDataControllers.add(
                MapEntry(
                  TextEditingController(text: key),
                  TextEditingController(text: value),
                ),
              );
            });
          }
          
          // If no biz data was loaded, add an empty field
          if (_bizDataControllers.isEmpty) {
            _addBizDataField();
          }
          
          // Load source list
          for (var entry in _sourceListControllers) {
            entry.key.dispose();
            entry.value.dispose();
          }
          _sourceListControllers.clear();
          
          if (event.sourceList != null && event.sourceList!.isNotEmpty) {
            for (var source in event.sourceList!) {
              _sourceListControllers.add(
                MapEntry(
                  TextEditingController(text: source['type'] ?? ''),
                  TextEditingController(text: source['source'] ?? ''),
                ),
              );
            }
          }
          
          // Load destination list
          for (var entry in _destinationListControllers) {
            entry.key.dispose();
            entry.value.dispose();
          }
          _destinationListControllers.clear();
          
          if (event.destinationList != null && event.destinationList!.isNotEmpty) {
            for (var destination in event.destinationList!) {
              _destinationListControllers.add(
                MapEntry(
                  TextEditingController(text: destination['type'] ?? ''),
                  TextEditingController(text: destination['destination'] ?? ''),
                ),
              );
            }
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Event not found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading event: $e';
      });
      print('Error loading aggregation event: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isEdit = true;
      });
    }
  }
  
  void _addBizDataField() {
    setState(() {
      final keyController = TextEditingController();
      final valueController = TextEditingController();
      _bizDataControllers.add(MapEntry(keyController, valueController));
    });
  }
  
  void _removeBizDataField(int index) {
    setState(() {
      final entry = _bizDataControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }
  
  Future<void> _selectEventTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_eventTime),
      );
      
      if (timePicked != null) {
        setState(() {
          _eventTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }
  
  Future<void> _saveAggregationEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _validationErrors = [];
    });
    
    try {
      // Get provider for event creation
      final cubit = context.read<AggregationEventsCubit>();
      final validationProvider = context.read<ValidationCubit>();

      // Parse parent EPC
      final String parentEPC = EPCFormatter.formatToEPCUri(_parentEPCController.text.trim());
      
      // Each child can be in URN format or GS1 barcode format
      final List<String> rawChildEPCs = _childEPCsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
          
      // Convert any barcode format child EPCs to URN format
      final List<String> childEPCs = rawChildEPCs.map((epc) => EPCFormatter.formatToEPCUri(epc)).toList();
      
      // Parse business data
      final Map<String, String> bizData = {};
      for (var entry in _bizDataControllers) {
        final key = entry.key.text.trim();
        final value = entry.value.text.trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          bizData[key] = value;
        }
      }
      
      // Get source and destination lists
      final sourceList = _getSourceList();
      final destinationList = _getDestinationList();
      
      // Business step, disposition, location
      final String businessStep = _businessStep ?? '';
      final String disposition = _disposition ?? '';
      final String locationGLN = _locationGLNController.text.trim();

      // Create an aggregation event model for validation
      final eventToValidate = AggregationEvent(
        eventId: _isEdit ? widget.aggregationEventId! : 'event_${DateTime.now().millisecondsSinceEpoch}',
        eventTime: _eventTime,
        recordTime: DateTime.now(),
        eventTimeZone: _eventTimeZoneOffset,
        epcisVersion: epcis_models.EPCISVersion.v2_0,
        action: _selectedAction,
        businessStep: businessStep,
        disposition: disposition,
        readPoint: locationGLN.isNotEmpty ? GLN.fromCode(locationGLN) : null,
        businessLocation: locationGLN.isNotEmpty ? GLN.fromCode(locationGLN) : null,
        bizData: bizData.isNotEmpty ? bizData : null,
        parentID: parentEPC,
        childEPCs: childEPCs,
        sourceList: sourceList.isNotEmpty ? sourceList : null,
        destinationList: destinationList.isNotEmpty ? destinationList : null,
      );

      // Perform frontend validation via Cubit
      final isValid = await validationProvider.validateAggregationEvent(eventToValidate);

      if (!isValid) {
        setState(() {
          _isLoading = false;
          _validationErrors = validationProvider.state.lastValidationResult?['validationErrors'] ?? [];
          if (_validationErrors.isEmpty && validationProvider.state.error != null) {
            _errorMessage = validationProvider.state.error;
          }
        });
        
        if (_validationErrors.isNotEmpty) {
          showValidationErrors(context, _validationErrors);
        }
        return;
      }

      print('Proceeding with event creation/update...');

      if (_isEdit) {
        await cubit.updateAggregationEvent(eventToValidate);
      } else {
        // Create new event based on action type
        if (_selectedAction == 'ADD') {
          await cubit.createPackEvent(
            parentEPC: parentEPC,
            childEPCs: childEPCs,
            locationGLN: locationGLN,
            businessStep: businessStep,
            disposition: disposition,
            bizData: bizData,
            sourceList: sourceList.isNotEmpty ? sourceList : null,
            destinationList: destinationList.isNotEmpty ? destinationList : null,
          );
        } else if (_selectedAction == 'DELETE') {
          await cubit.createUnpackEvent(
            parentEPC: parentEPC,
            childEPCs: childEPCs,
            locationGLN: locationGLN,
            businessStep: businessStep,
            disposition: disposition,
            bizData: bizData,
            sourceList: sourceList.isNotEmpty ? sourceList : null,
            destinationList: destinationList.isNotEmpty ? destinationList : null,
          );
        } else {
          await cubit.createAggregationEvent(eventToValidate);
        }
      }      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Aggregation event updated' : 'Aggregation event created'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      // Show detailed error dialog for better user experience
      _showErrorDialog(_errorMessage!);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// Generate a random parent EPC (SSCC for container)
  void _generateParentEPC() {
    setState(() {
      // Use a default company prefix for demo purposes
      final companyPrefix = '0614141';
      final serialReference = (100000 + Random().nextInt(900000)).toString();
      _parentEPCController.text = GS1Generator.generateSSCC(companyPrefix, serialReference);
    });
  }
  
  /// Generate a batch of child EPCs (SGTINs for contained items)
  void _generateChildEPCs([int count = 5]) {
    // Use default company prefix and item reference for demo purposes
    final companyPrefix = '0614141';
    final itemReference = '112345';
    
    final childEPCs = GS1Generator.generateBatchSGTINs(
      companyPrefix, 
      itemReference, 
      count,
      startSerial: 1000 + Random().nextInt(9000)
    );
    
    setState(() {
      _childEPCsController.text = childEPCs.join(', ');
    });
  }
  
  // Helper method to filter dispositions based on selected business step
  List<String> _getRelevantDispositions() {
    // If no business step is selected, return all dispositions
    if (_businessStep == null) {
      return _standardDispositions;
    }
    
    // Filter dispositions based on common business step + disposition combinations
    switch (_businessStep) {
      case 'urn:epcglobal:cbv:bizstep:commissioning':
        return _standardDispositions.where((d) => 
          [
            'urn:epcglobal:cbv:disp:active',
            'urn:epcglobal:cbv:disp:in_progress',
            'urn:epcglobal:cbv:disp:encoded',
          ].contains(d)).toList();
      
      case 'urn:epcglobal:cbv:bizstep:packing':
        return _standardDispositions.where((d) => 
          [
            'urn:epcglobal:cbv:disp:in_progress',
            'urn:epcglobal:cbv:disp:container_closed',
            'urn:epcglobal:cbv:disp:container_open',
          ].contains(d)).toList();
      
      case 'urn:epcglobal:cbv:bizstep:unpacking':
        return _standardDispositions.where((d) => 
          [
            'urn:epcglobal:cbv:disp:in_progress',
            'urn:epcglobal:cbv:disp:container_open',
          ].contains(d)).toList();
      
      case 'urn:epcglobal:cbv:bizstep:shipping':
        return _standardDispositions.where((d) => 
          [
            'urn:epcglobal:cbv:disp:in_transit',
            'urn:epcglobal:cbv:disp:returned',
            'urn:epcglobal:cbv:disp:recalled',
          ].contains(d)).toList();
      
      case 'urn:epcglobal:cbv:bizstep:receiving':
        return _standardDispositions.where((d) => 
          [
            'urn:epcglobal:cbv:disp:in_progress',
            'urn:epcglobal:cbv:disp:sellable_accessible',
            'urn:epcglobal:cbv:disp:sellable_not_accessible',
            'urn:epcglobal:cbv:disp:damaged',
          ].contains(d)).toList();
      
      case 'urn:epcglobal:cbv:bizstep:dispensing':
        return _standardDispositions.where((d) => 
          [
            'urn:epcglobal:cbv:disp:dispensed',
            'urn:epcglobal:cbv:disp:sold',
          ].contains(d)).toList();
      
      case 'urn:epcglobal:cbv:bizstep:destroying':
        return _standardDispositions.where((d) => 
          [
            'urn:epcglobal:cbv:disp:destroyed',
            'urn:epcglobal:cbv:disp:disposed',
          ].contains(d)).toList();
      
      case 'urn:epcglobal:cbv:bizstep:decommissioning':
        return _standardDispositions.where((d) => 
          [
            'urn:epcglobal:cbv:disp:inactive',
            'urn:epcglobal:cbv:disp:expired',
            'urn:epcglobal:cbv:disp:recalled',
            'urn:epcglobal:cbv:disp:damaged',
          ].contains(d)).toList();
      
      default:
        // For all other business steps, return all dispositions
        return _standardDispositions;
    }
  }
    /// Convert a scanned GS1 barcode format to URN format
  /// Supports common GS1 formats including SSCC and SGTIN
  /// 
  /// Examples:
  /// - SSCC: (00)123456789012345678 -> urn:epc:id:sscc:1234567.890123456
  /// - SGTIN: (01)12345678901234(21)123456 -> urn:epc:id:sgtin:1234567.890123.123456
  /// - SGTIN: (01)05415062325810(21)70005188444899 -> urn:epc:id:sgtin:5415062.32581.70005188444899
  String _convertBarcodeToURN(String barcode) {
    // Check if it's already in URN format
    if (barcode.startsWith('urn:')) {
      return barcode;
    }
    
    // Check for SSCC (00) format - used for logistics units/containers
    // Format: (00)NNNNNNNNNNNNNNNNNNN where N is a digit (18 digits)
    final ssccRegex = RegExp(r'\(00\)(\d{18})');
    final ssccMatch = ssccRegex.firstMatch(barcode);
    if (ssccMatch != null) {
      final ssccCode = ssccMatch.group(1)!;
      
      // For SSCC, the company prefix length can vary, but typically we'll use standard mapping
      // Assuming company prefix length of 7 for this example
      final extensionDigit = ssccCode.substring(0, 1);  // Get extension digit
      final companyPrefix = ssccCode.substring(1, 8);   // Take 7 digits for company prefix
      final serialReference = ssccCode.substring(8, 17); // Take the next 9 digits (excluding check digit)
      
      // Format for SSCC URN: urn:epc:id:sscc:<CompanyPrefix>.<SerialReference>
      return 'urn:epc:id:sscc:$companyPrefix.$extensionDigit$serialReference';
    }
    
    // Check for SGTIN (01 + 21) format - used for trade items
    // Format: (01)NNNNNNNNNNNNNN(21)XXXXX where N is a digit (14 digits) and X is alphanumeric
    // Improved regex to better handle different formats like (01)05415062325810(21)70005188444899
    final sgtinRegex = RegExp(r'\(01\)(\d{14})\(21\)([a-zA-Z0-9]+)');
    final sgtinMatch = sgtinRegex.firstMatch(barcode);
    if (sgtinMatch != null) {
      final gtinCode = sgtinMatch.group(1)!;
      final serialNumber = sgtinMatch.group(2)!;
      
      // For GTIN-14, the partition pattern can vary
      // Common pattern is a 7-digit company prefix followed by a 5-digit item reference
      // Extracting company prefix and item reference while handling leading zeros
      final indicator = gtinCode.substring(0, 1);
      
      // Default to 7 digits company prefix, but we could improve this by detecting the company prefix length
      int companyPrefixLength = 7;
      
      // Special case handling for some known company prefixes
      if (gtinCode.startsWith('0541506')) {
        companyPrefixLength = 7; // 7-digit company prefix (5415062)
      } else if (gtinCode.startsWith('061414')) {
        companyPrefixLength = 7; // 7-digit company prefix (0614141)
      }
      
      final companyPrefix = gtinCode.substring(1, companyPrefixLength + 1);
      final itemReferenceStart = companyPrefixLength + 1;
      final itemReferenceEnd = 13; // GTIN-14 has 14 digits, last is check digit
      final itemReference = indicator + gtinCode.substring(itemReferenceStart, itemReferenceEnd);
      
      // Format for SGTIN URN: urn:epc:id:sgtin:<CompanyPrefix>.<ItemReference>.<SerialNumber>
      return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$serialNumber';
    }
    
    // Try alternative format without parentheses
    // Format: 01NNNNNNNNNNNNNN21XXXXX
    final sgtinNoParensRegex = RegExp(r'01(\d{14})21([a-zA-Z0-9]+)');
    final sgtinNoParensMatch = sgtinNoParensRegex.firstMatch(barcode);
    if (sgtinNoParensMatch != null) {
      final gtinCode = sgtinNoParensMatch.group(1)!;
      final serialNumber = sgtinNoParensMatch.group(2)!;
      
      // Default to 7 digits company prefix, but we could improve this by detecting the company prefix length
      int companyPrefixLength = 7;
      final indicator = gtinCode.substring(0, 1);
      final companyPrefix = gtinCode.substring(1, companyPrefixLength + 1);
      final itemReferenceStart = companyPrefixLength + 1;
      final itemReferenceEnd = 13; // GTIN-14 has 14 digits, last is check digit
      final itemReference = indicator + gtinCode.substring(itemReferenceStart, itemReferenceEnd);
      
      return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$serialNumber';
    }
    
    // Support GS1 format with FNC1 character
    if (barcode.contains('\u001D')) {
      // Use the GS1 Parser to handle the complex barcode
      final elements = GS1Generator.parseGS1BarcodeData(barcode);
      
      // If it has SSCC
      if (elements.containsKey('00')) {
        final sscc = elements['00']!;
        final extensionDigit = sscc.substring(0, 1);
        final companyPrefix = sscc.substring(1, 8);
        final serialReference = sscc.substring(8, 17);
        return 'urn:epc:id:sscc:$companyPrefix.$extensionDigit$serialReference';
      }
      
      // If it has GTIN and Serial
      if (elements.containsKey('01') && elements.containsKey('21')) {
        final gtin = elements['01']!;
        final serial = elements['21']!;
        
        // Default to 7 digits company prefix
        int companyPrefixLength = 7;
        final indicator = gtin.substring(0, 1);
        final companyPrefix = gtin.substring(1, companyPrefixLength + 1);
        final itemReferenceStart = companyPrefixLength + 1;
        final itemReferenceEnd = 13; // GTIN-14 has 14 digits, last is check digit
        final itemReference = indicator + gtin.substring(itemReferenceStart, itemReferenceEnd);
        
        return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$serial';
      }
    }
    
    // If it doesn't match known formats, return as is
    return barcode;
  }
  
  // Help content organized by field for the aggregation event form
  final Map<String, Map<String, String>> _helpContent = {
    'overview': {
      'title': 'Aggregation Event Overview',
      'content': 'An Aggregation Event captures the physical relationship between a parent container and its child items. '
          'This is a crucial part of pharmaceutical track and trace systems that enables supply chain visibility '
          'by recording when products are packed together, observed in their containment state, or unpacked.'
    },
    'action': {
      'title': 'Action',
      'content': 'Specifies what happened to the aggregation relationship:\n\n'
          '• ADD: Creates a new parent-child relationship (packing items into a container)\n'
          '• OBSERVE: Records an observation of an existing aggregation without changing it\n'
          '• DELETE: Removes a parent-child relationship (unpacking items from a container)\n\n'
          'According to GS1 EPCIS standards, these actions define how the aggregation event affects the supply chain.'
    },
    'eventTime': {
      'title': 'Event Time',
      'content': 'The date and time when the aggregation event occurred. '
          'This timestamp is crucial for establishing the chronological sequence of events in the supply chain '
          'and is used for traceability queries. The system uses ISO 8601 format with timezone information.'
    },
    'parentEPC': {
      'title': 'Parent EPC',
      'content': 'The Electronic Product Code (EPC) identifying the parent container, typically an SSCC '
          '(Serial Shipping Container Code). In pharmaceutical supply chains, this usually identifies a case, '
          'pallet, tote, or shipping container that contains multiple product items.\n\n'
          'Format examples:\n'
          '• URN format: urn:epc:id:sscc:0614141.1234567890\n'
          '• GS1 barcode format: (00)00614141123456789'
    },
    'childEPCs': {
      'title': 'Child EPCs',
      'content': 'The list of Electronic Product Codes (EPCs) for the items contained within the parent. '
          'In pharmaceutical track and trace, these are typically SGTINs (Serialized Global Trade Item Numbers) '
          'representing individual product packages.\n\n'
          'Format examples:\n'
          '• URN format: urn:epc:id:sgtin:0614141.112345.1234567\n'
          '• GS1 barcode format: (01)00614141123451(21)1234567\n\n'
          'Multiple child EPCs should be separated by commas.'
    },
    'businessStep': {
      'title': 'Business Step',
      'content': 'Identifies the business process step during which the aggregation event took place. '
          'GS1\'s Core Business Vocabulary (CBV) standardizes these values to ensure consistent interpretation '
          'across the supply chain. Common values in pharmaceutical track and trace include:\n\n'
          '• commissioning: Initial creation of the product identifiers\n'
          '• packing: Placing items into a container\n'
          '• shipping: Dispatching containers from a location\n'
          '• receiving: Accepting containers at a location\n'
          '• unpacking: Removing items from a container\n'
          '• dispensing: Providing products to a patient'
    },
    'disposition': {
      'title': 'Disposition',
      'content': 'Indicates the business condition of the objects in the aggregation. The disposition '
          'works together with the business step to provide context for the event. GS1\'s Core Business '
          'Vocabulary (CBV) standardizes these values. Common dispositions include:\n\n'
          '• in_progress: The process is currently happening\n'
          '• in_transit: The items are being transported\n'
          '• container_closed: The container has been sealed\n'
          '• container_open: The container is open and accessible\n'
          '• sellable_accessible: Products are available for sale\n'
          '• dispensed: Products have been provided to a patient'
    },
    'locationGLN': {
      'title': 'Location GLN',
      'content': 'The Global Location Number (GLN) identifying where the aggregation event occurred. '
          'This is a crucial element for traceability as it establishes the physical location context for '
          'the event. In EPCIS, this is typically used for both the readPoint (exact location, like a dock door) '
          'and businessLocation (the broader location, like a warehouse).\n\n'
          'Format example: 0614141000011 (13-digit GLN code)'
    },
    'sourceList': {
      'title': 'Source List',
      'content': 'Identifies the source(s) from which the objects in the event came. '
          'Each source has a type and value. The type identifies what kind of source it is, '
          'while the value is typically a GLN or other identifier for the source.\n\n'
          'Common source types include:\n'
          '• owning_party: The business that owned the items before this event\n'
          '• possessing_party: The business that possessed the items before this event\n'
          '• location: The physical location the items came from\n'
          '• processing_party: The business that processed the items before this event\n\n'
          'Source values are typically in GLN format.'
    },
    'destinationList': {
      'title': 'Destination List',
      'content': 'Identifies the destination(s) to which the objects in the event are going. '
          'Each destination has a type and value. The type identifies what kind of destination it is, '
          'while the value is typically a GLN or other identifier for the destination.\n\n'
          'Common destination types include:\n'
          '• owning_party: The business that will own the items after this event\n'
          '• possessing_party: The business that will possess the items after this event\n'
          '• location: The physical location the items are going to\n'
          '• processing_party: The business that will process the items next\n\n'
          'Destination values are typically in GLN format.'
    },
    'businessData': {
      'title': 'Business Data',
      'content': 'Additional data specific to this event that provides business context beyond '
          'the standard EPCIS fields. This user-defined information can include:\n\n'
          '• Batch/lot information\n'
          '• Purchase order references\n'
          '• Expiration dates\n'
          '• Temperature logs\n'
          '• Quality information\n'
          '• Custom identifiers\n\n'
          'Business data is stored as key-value pairs and can be used for custom queries and reports.'
    }
  };

  /// Show help dialog with detailed information about each field
  void _showHelpDialog(BuildContext context, String field) {
    final helpItem = _helpContent[field];
    if (helpItem == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(helpItem['title'] ?? 'Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(helpItem['content'] ?? ''),
              const SizedBox(height: 16),
              if (field != 'overview') Text(
                'Note: All fields conform to GS1 EPCIS 2.0 standards for pharmaceutical track and trace.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey.shade700),
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
  }
  
  /// Show comprehensive help screen covering all aspects of aggregation events
  void _showFullHelpScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Aggregation Event Help'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Overview Section
                    _buildHelpSection(context, 'overview'),
                    const Divider(),
                    
                    // Field-specific sections
                    _buildHelpSection(context, 'action'),
                    const Divider(),
                    _buildHelpSection(context, 'eventTime'),
                    const Divider(),
                    _buildHelpSection(context, 'parentEPC'),
                    const Divider(),
                    _buildHelpSection(context, 'childEPCs'),
                    const Divider(),
                    _buildHelpSection(context, 'businessStep'),
                    const Divider(),
                    _buildHelpSection(context, 'disposition'),
                    const Divider(),
                    _buildHelpSection(context, 'locationGLN'),
                    const Divider(),
                    _buildHelpSection(context, 'sourceList'),
                    const Divider(),
                    _buildHelpSection(context, 'destinationList'),
                    const Divider(),
                    _buildHelpSection(context, 'businessData'),
                    
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'GS1 Standards Compliance',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'This system implements GS1 EPCIS 2.0 standards with backward compatibility to EPCIS 1.3. '
                            'All identifiers, business vocabulary, and event structures comply with GS1 Core Business '
                            'Vocabulary (CBV) and are designed for pharmaceutical track and trace requirements.',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a help section for a specific field
  Widget _buildHelpSection(BuildContext context, String field) {
    final helpItem = _helpContent[field];
    if (helpItem == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          helpItem['title'] ?? '',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          helpItem['content'] ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  // Add a source entry row
  void _addSourceEntry() {
    setState(() {
      _sourceListControllers.add(
        MapEntry(
          TextEditingController(), // Type
          TextEditingController(), // Value
        ),
      );
    });
  }
  
  // Remove a source entry row
  void _removeSourceEntry(int index) {
    setState(() {
      final entry = _sourceListControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  // Add a destination entry row
  void _addDestinationEntry() {
    setState(() {
      _destinationListControllers.add(
        MapEntry(
          TextEditingController(), // Type
          TextEditingController(), // Value
        ),
      );
    });
  }
  
  // Remove a destination entry row
  void _removeDestinationEntry(int index) {
    setState(() {
      final entry = _destinationListControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }
  
  // Convert source controllers to map format
  List<Map<String, dynamic>> _getSourceList() {
    final sourceList = <Map<String, dynamic>>[];
    for (var entry in _sourceListControllers) {
      final type = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (type.isNotEmpty && value.isNotEmpty) {
        sourceList.add({'type': type, 'source': value});
      }
    }
    return sourceList;
  }
  
  // Convert destination controllers to map format
  List<Map<String, dynamic>> _getDestinationList() {
    final destinationList = <Map<String, dynamic>>[];
    for (var entry in _destinationListControllers) {
      final type = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (type.isNotEmpty && value.isNotEmpty) {
        destinationList.add({'type': type, 'destination': value});
      }
    }
    return destinationList;
  }
  
  // Show a user-friendly error dialog with formatted error messages
  void _showErrorDialog(String errorMessage) {
    if (!mounted) return;
    
    // Check if it's a validation error with our custom formatting
    bool isValidationError = errorMessage.contains('Validation Error:');
    bool needsCommissioning = errorMessage.contains('not been commissioned') || 
                             errorMessage.contains('not commissioned:');
                             
    // Extract parent and child EPCs needing commissioning
    List<String> parentEPCs = [];
    List<String> childEPCs = [];
    List<String> otherErrors = [];
    
    // Parse the error message to extract specific EPCs
    if (needsCommissioning) {
      final lines = errorMessage.split('\n');
      bool collectingParents = false;
      bool collectingChildren = false;
      bool collectingOthers = false;
      
      for (final line in lines) {
        if (line.contains('Parent container not found')) {
          collectingParents = true;
          collectingChildren = false;
          collectingOthers = false;
          continue;
        } else if (line.contains('items have not been commissioned')) {
          collectingParents = false;
          collectingChildren = true;
          collectingOthers = false;
          continue;
        } else if (line.contains('Other issues:')) {
          collectingParents = false;
          collectingChildren = false;
          collectingOthers = true;
          continue;
        }
        
        if (line.trim().startsWith('• ')) {
          final epc = line.trim().substring(2);
          if (collectingParents) {
            parentEPCs.add(epc);
          } else if (collectingChildren) {
            childEPCs.add(epc);
          } else if (collectingOthers) {
            otherErrors.add(epc);
          }
        }
      }
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isValidationError ? Icons.error_outline : Icons.warning_amber_outlined,
                color: isValidationError ? Colors.red[800] : Colors.orange[800],
              ),
              const SizedBox(width: 8),
              Text(
                isValidationError ? 'Validation Error' : 'Error',
                style: TextStyle(
                  color: isValidationError ? Colors.red[800] : Colors.orange[800], 
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isValidationError && needsCommissioning) ...[
                  if (parentEPCs.isNotEmpty) ...[
                    const Text(
                      'Parent container not found in the system:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: parentEPCs.map((epc) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(child: Text(epc, style: const TextStyle(fontFamily: 'monospace'))),
                              ],
                            ),
                          )
                        ).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (childEPCs.isNotEmpty) ...[
                    const Text(
                      'Items not commissioned in the system:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: childEPCs.map((epc) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_outlined, size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Expanded(child: Text(epc, style: const TextStyle(fontFamily: 'monospace'))),
                              ],
                            ),
                          )
                        ).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (otherErrors.isNotEmpty) ...[
                    const Text(
                      'Other issues:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: otherErrors.map((error) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(child: Text(error)),
                              ],
                            ),
                          )
                        ).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Please create a commissioning event for these items first.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ] else ...[
                  // For other errors or if we couldn't parse the validation error
                  Text(
                    errorMessage,
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            // Add button to navigate to commissioning form if the error is about uncommissioned EPCs
            if (needsCommissioning) ...[
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Go to Commissioning Form'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to object event form with commissioning preset
                  // Build query parameters for pre-filling fields
                  final params = {
                    'bizStep': 'commissioning',
                    'action': 'ADD',
                  };
                  
                  // Add EPCs to commission if available
                  final List<String> allEPCs = [...parentEPCs, ...childEPCs];
                  if (allEPCs.isNotEmpty) {
                    params['epcs'] = allEPCs.join(',');
                  }
                  
                  // Construct query string
                  final queryString = params.entries
                      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                      .join('&');
                  
                  GoRouter.of(context).push('/epcis/object-events/new?$queryString');
                },
              ),
              const SizedBox(width: 8),
            ],
            TextButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Aggregation Event' : 'Create Aggregation Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () => _showFullHelpScreen(context),
          ),
        ],
      ),
      body: _isLoading && _isEdit
          ? const Center(child: AppLoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_validationErrors.isNotEmpty)
                      ValidationErrorWidget(
                        validationErrors: _validationErrors,
                        onDismiss: () => setState(() => _validationErrors = []),
                      ),

                    // Information about GS1 barcode support
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'GS1 Barcode Format Support',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () => _showFullHelpScreen(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'Full Help',
                                      style: TextStyle(color: Colors.blue, fontSize: 12.0),
                                    ),
                                    SizedBox(width: 4.0),
                                    Icon(Icons.help_outline, size: 16.0, color: Colors.blue),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            'This form supports both URN format and GS1 barcode format for Parent and Child EPCs:',
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            '• Parent containers (SSCC): (00)123456789012345678',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          const Text(
                            '• Child items (SGTIN): (01)12345678901234(21)123456',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          const Text(
                            '• SGTIN with leading zeros: (01)05415062325810(21)70005188444899',
                            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'All inputs will be automatically converted to URN format when saved.',
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Event Action
                    DropdownButtonFormField<String>(                      decoration: const InputDecoration(
                        labelText: 'Action *',
                        border: OutlineInputBorder(),
                        suffixIcon: Tooltip(
                          message: 'Click the help icon in the app bar for more information',
                          child: Icon(Icons.help_outline, size: 16),
                        ),
                      ),
                      value: _selectedAction,
                      items: ['ADD', 'OBSERVE', 'DELETE']
                          .map((action) => DropdownMenuItem(
                                value: action,
                                child: Text(action),
                              ))
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
                    const SizedBox(height: 16.0),
                    
                    // Event Time
                    InkWell(
                      onTap: _selectEventTime,
                      child: InputDecorator(                      decoration: const InputDecoration(
                        labelText: 'Event Time *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                        helperText: 'When the aggregation event occurred',
                      ),
                        child: Text(
                          DateFormat.yMd().add_Hms().format(_eventTime),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Parent EPC
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _parentEPCController,
                            decoration: const InputDecoration(
                              labelText: 'Parent EPC *',
                              border: OutlineInputBorder(),
                              hintText: 'URN format or GS1 barcode format with parentheses',
                              helperText: 'Example: (00)123456789012345678 or urn:epc:id:sscc:1234567.890123456',
                              suffixIcon: Tooltip(
                                message: 'Identifies the parent container using SSCC',
                                child: Icon(Icons.help_outline, size: 16),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the parent EPC';
                              }
                              
                              // Check format - should be a valid SSCC in either URN or GS1 format
                              if (!value.startsWith('urn:epc:id:sscc:') && !RegExp(r'\(00\)[0-9]{18}').hasMatch(value)) {
                                return 'Parent EPC should be in SSCC format';
                              }
                              
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        IconButton(
                          onPressed: _generateParentEPC,
                          icon: const Icon(Icons.auto_fix_high),
                          tooltip: 'Generate SSCC',
                        ),
                        IconButton(
                          onPressed: () {
                            // Placeholder for barcode scanner integration
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Barcode scanner would open here'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: 'Scan barcode',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Child EPCs
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _childEPCsController,
                            decoration: const InputDecoration(
                              labelText: 'Child EPCs *',
                              border: OutlineInputBorder(),
                              hintText: 'URN format or GS1 barcode format with parentheses',
                              helperText: 'Examples: (01)05415062325810(21)70005188444899 or urn:epc:id:sgtin:5415062.32581.70005188444899',
                              suffixIcon: Tooltip(
                                message: 'Identifies the contained items using SGTINs',
                                child: Icon(Icons.help_outline, size: 16),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter at least one child EPC';
                              }
                              
                              // Check if EPCs are in valid format
                              final epcList = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                              for (final epc in epcList) {
                                if (!epc.startsWith('urn:epc:id:') && !RegExp(r'\(\d+\)').hasMatch(epc)) {
                                  return 'Invalid EPC format: $epc';
                                }
                              }
                              
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () => _generateChildEPCs(5),
                              icon: const Icon(Icons.auto_fix_high),
                              tooltip: 'Generate 5 SGTINs',
                            ),
                            IconButton(
                              onPressed: () => _generateChildEPCs(10),
                              icon: const Icon(Icons.format_list_numbered),
                              tooltip: 'Generate 10 SGTINs',
                            ),
                            IconButton(
                              onPressed: () {
                                // Placeholder for barcode scanner integration
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Barcode scanner would open here'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.qr_code_scanner),
                              tooltip: 'Scan barcode',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),                    // Business Step
                    DropdownButtonFormField<String>(                      decoration: const InputDecoration(
                        labelText: 'Business Step *',
                        border: OutlineInputBorder(),
                        hintText: 'Select a business step',
                        helperText: 'The business process step associated with this event',
                        suffixIcon: Tooltip(
                          message: 'Standard GS1 business steps from Core Business Vocabulary',
                          child: Icon(Icons.help_outline, size: 16),
                        ),
                      ),
                      value: _businessStep,
                      items: _standardBusinessSteps
                          .map((step) => DropdownMenuItem(
                                value: step,
                                child: Tooltip(
                                  message: step,
                                  child: Text(step.split(':').last, 
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ))
                          .toList(),                      onChanged: (value) {
                        setState(() {
                          _businessStep = value;
                          
                          // Reset disposition when business step changes and select a relevant one
                          final relevantDispositions = _getRelevantDispositions();
                          if (!relevantDispositions.contains(_disposition)) {
                            _disposition = relevantDispositions.isNotEmpty 
                              ? relevantDispositions.first 
                              : _standardDispositions.first;
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
                    const SizedBox(height: 16.0),
                    
                    // Disposition
                    DropdownButtonFormField<String>(                      decoration: const InputDecoration(
                        labelText: 'Disposition *',
                        border: OutlineInputBorder(),
                        hintText: 'Select a disposition',
                        helperText: 'The business condition of the objects',
                        suffixIcon: Tooltip(
                          message: 'Standard GS1 dispositions from Core Business Vocabulary',
                          child: Icon(Icons.help_outline, size: 16),
                        ),
                      ),
                      value: _disposition,
                      items: _getRelevantDispositions()
                          .map((disp) => DropdownMenuItem(
                                value: disp,
                                child: Tooltip(
                                  message: disp,
                                  child: Text(disp.split(':').last,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ))
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
                    const SizedBox(height: 16.0),
                    
                    // Location GLN
                    TextFormField(
                      controller: _locationGLNController,
                      decoration: const InputDecoration(
                        labelText: 'Location GLN *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter location GLN code',
                        suffixIcon: Tooltip(
                          message: 'Global Location Number identifying where the event occurred',
                          child: Icon(Icons.help_outline, size: 16),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the location GLN';
                        }
                        
                        // Check if the GLN is in valid format
                        if (!RegExp(r'^[0-9\.]+$').hasMatch(value)) {
                          return 'GLN should contain only digits and dots';
                        }
                        
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Source List
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(
                              'Source List',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            trailing: Tooltip(
                              message: 'Information about the source of goods, such as owning party or possessing party',
                              child: const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                            ),
                            subtitle: const Text(
                              'Sources indicate where the products came from, such as the previous owner or location',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                // Standard source types dropdown
                                if (_sourceListControllers.isEmpty) 
                                  const Text(
                                    'No source information added yet. Click "Add Source" to specify where products are coming from.',
                                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                                  ),
                                
                                // Source List Items
                                ..._sourceListControllers.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final controllers = entry.value;
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    elevation: 0,
                                    color: Colors.grey.shade50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Source #${index + 1}', 
                                                style: const TextStyle(fontWeight: FontWeight.bold)),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                                onPressed: () => _removeSourceEntry(index),
                                                tooltip: 'Remove Source',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          DropdownButtonFormField<String>(
                                            decoration: const InputDecoration(
                                              labelText: 'Source Type *',
                                              border: OutlineInputBorder(),
                                              hintText: 'Select a source type',
                                            ),
                                            value: controllers.key.text.isNotEmpty ? controllers.key.text : null,
                                            items: [
                                              'owning_party',
                                              'possessing_party',
                                              'location',
                                              'processing_party',
                                            ].map((type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(type),
                                            )).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                controllers.key.text = value;
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 8.0),
                                          TextFormField(
                                            controller: controllers.value,
                                            decoration: const InputDecoration(
                                              labelText: 'Source Value *',
                                              hintText: 'e.g., urn:epc:id:sgln:0614141.00001.0',
                                              border: OutlineInputBorder(),
                                              helperText: 'GLN or EPC identifier of the source',
                                            ),
                                            validator: (value) {
                                              if (controllers.key.text.isNotEmpty && (value == null || value.isEmpty)) {
                                                return 'Please enter a source value';
                                              }
                                              
                                              // Check format for URN or GLN
                                              if (value != null && value.isNotEmpty) {
                                                if (!value.startsWith('urn:epc:id:') && !RegExp(r'^[0-9\.]+$').hasMatch(value)) {
                                                  return 'Invalid format. Use URN or GLN format';
                                                }
                                              }
                                              
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                
                                // Add Source Button
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: OutlinedButton.icon(
                                    onPressed: _addSourceEntry,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Source'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24.0),
                    
                    // Destination List
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(
                              'Destination List',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            trailing: Tooltip(
                              message: 'Information about the destination of goods, such as owning party or possessing party',
                              child: const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                            ),
                            subtitle: const Text(
                              'Destinations indicate where the products are going to, such as the next owner or location',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                if (_destinationListControllers.isEmpty) 
                                  const Text(
                                    'No destination information added yet. Click "Add Destination" to specify where products are going to.',
                                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                                  ),
                                
                                // Destination List Items
                                ..._destinationListControllers.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final controllers = entry.value;
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    elevation: 0,
                                    color: Colors.grey.shade50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Destination #${index + 1}', 
                                                style: const TextStyle(fontWeight: FontWeight.bold)),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                                onPressed: () => _removeDestinationEntry(index),
                                                tooltip: 'Remove Destination',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          DropdownButtonFormField<String>(
                                            decoration: const InputDecoration(
                                              labelText: 'Destination Type *',
                                              border: OutlineInputBorder(),
                                              hintText: 'Select a destination type',
                                            ),
                                            value: controllers.key.text.isNotEmpty ? controllers.key.text : null,
                                            items: [
                                              'owning_party',
                                              'possessing_party',
                                              'location',
                                              'processing_party',
                                            ].map((type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(type),
                                            )).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                controllers.key.text = value;
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 8.0),
                                          TextFormField(
                                            controller: controllers.value,
                                            decoration: const InputDecoration(
                                              labelText: 'Destination Value *',
                                              hintText: 'e.g., urn:epc:id:sgln:0614141.00001.0',
                                              border: OutlineInputBorder(),
                                              helperText: 'GLN or EPC identifier of the destination',
                                            ),
                                            validator: (value) {
                                              if (controllers.key.text.isNotEmpty && (value == null || value.isEmpty)) {
                                                return 'Please enter a destination value';
                                              }
                                              
                                              // Check format for URN or GLN
                                              if (value != null && value.isNotEmpty) {
                                                if (!value.startsWith('urn:epc:id:') && !RegExp(r'^[0-9\.]+$').hasMatch(value)) {
                                                  return 'Invalid format. Use URN or GLN format';
                                                }
                                              }
                                              
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                
                                // Add Destination Button
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: OutlinedButton.icon(
                                    onPressed: _addDestinationEntry,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Destination'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24.0),
                      // Business Data
                    Row(
                      children: [
                        const Text(
                          'Business Data',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8.0),
                        Tooltip(
                          message: 'Additional business context for the event (key-value pairs)',
                          child: const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    
                    ..._bizDataControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controllers = entry.value;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controllers.key,
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
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: TextFormField(
                                controller: controllers.value,
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
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeBizDataField(index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 8.0),
                    OutlinedButton.icon(
                      onPressed: _addBizDataField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Business Data'),
                    ),
                    
                    const SizedBox(height: 24.0),
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.red.shade100,
                        width: double.infinity,
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                    
                    // Action buttons
                    Row(
                      children: [
                        if (_isEdit) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Navigate to hierarchy view for parent EPC
                                context.push('/epcis/aggregation-events/hierarchy/${_parentEPCController.text}', 
                                  extra: {'epc': _parentEPCController.text, 'isParent': true});
                              },
                              icon: const Icon(Icons.account_tree),
                              label: const Text('View Hierarchy'),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveAggregationEvent,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20.0,
                                      width: 20.0,
                                      child: CircularProgressIndicator(strokeWidth: 2.0),
                                    )
                                  : Text(_isEdit ? 'Update Event' : 'Create Event'),
                            ),
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
}
