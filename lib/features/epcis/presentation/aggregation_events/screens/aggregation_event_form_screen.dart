import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validation_error_widget.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/data/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_pharma_rules_text.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_reference_data_checker.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_missing_reference_dialog.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_parent_pack_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_pharma_rules_panel.dart';
import 'package:traqtrace_app/shared/widgets/gln_selector.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart' as epcis_models;
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';

import '../../../mixins/event_form_validation_mixin.dart'
    show showValidationErrors;

class _QuantityRowControllers {
  _QuantityRowControllers()
      : epcClass = TextEditingController(),
        quantity = TextEditingController(),
        uom = TextEditingController();

  final TextEditingController epcClass;
  final TextEditingController quantity;
  final TextEditingController uom;

  void dispose() {
    epcClass.dispose();
    quantity.dispose();
    uom.dispose();
  }
}

/// Screen for creating a new aggregation event.
class AggregationEventFormScreen extends StatefulWidget {
  /// When true, shown inside the split-view create pane (no route pop on save).
  final bool embedded;

  final VoidCallback? onEmbeddedActionSuccess;

  const AggregationEventFormScreen({
    Key? key,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  }) : super(key: key);

  @override
  State<AggregationEventFormScreen> createState() => _AggregationEventFormScreenState();
}

class _AggregationEventFormScreenState extends State<AggregationEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _validationErrors = [];
  
  // Form fields
  String _selectedAction = 'ADD';
  final _parentEPCController = TextEditingController();
  final _childEPCsController = TextEditingController();
  String? _businessStep;
  String? _disposition;
  GLN? _locationGLN;
  String? _locationGlnError;
  AggregationReferenceDataChecker? _referenceDataChecker;
  AggregationPharmaReadinessChecker? _pharmaReadinessChecker;

  // Source and destination lists
  final List<MapEntry<TextEditingController, TextEditingController>> _sourceListControllers = [];
  final List<MapEntry<TextEditingController, TextEditingController>> _destinationListControllers = [];
  
  // Business data key-value pairs
  final List<MapEntry<TextEditingController, TextEditingController>> _bizDataControllers = [];
  final List<_QuantityRowControllers> _quantityRows = [_QuantityRowControllers()];
  bool _useQuantityList = false;
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
    'urn:epcglobal:cbv:disp:retail_sold',           // Object has been sold at retail
    'urn:epcglobal:cbv:disp:expired',               // Object has expired
    'urn:epcglobal:cbv:disp:recalled',              // Object has been recalled
    'urn:epcglobal:cbv:disp:damaged',               // Object is damaged
    'urn:epcglobal:cbv:disp:destroyed',             // Object is destroyed
    'urn:epcglobal:cbv:disp:container_closed',      // Container is closed
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

    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    _eventTimeZoneOffset =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    _businessStep = 'urn:epcglobal:cbv:bizstep:packing';
    _disposition = 'urn:epcglobal:cbv:disp:in_progress';
    _addBizDataField();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _referenceDataChecker ??= AggregationReferenceDataChecker(
      glnService: getIt<GLNService>(),
      gtinService: getIt<GTINService>(),
      sgtinService: getIt<SGTINService>(),
      ssccService: getIt<SSCCService>(),
      referenceDataValidationService: getIt<ReferenceDataValidationService>(),
    );
    _pharmaReadinessChecker ??= AggregationPharmaReadinessChecker(
      glnService: getIt<GLNService>(),
      sgtinService: getIt<SGTINService>(),
      ssccService: getIt<SSCCService>(),
    );
  }

  @override
  void dispose() {
    _parentEPCController.dispose();
    _childEPCsController.dispose();
    for (final row in _quantityRows) {
      row.dispose();
    }
    
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
    if (_locationGLN == null) {
      setState(() => _locationGlnError = 'Please select a location GLN');
    }
    if (!_formKey.currentState!.validate()) return;
    if (_locationGLN == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _validationErrors = [];
    });
    
    try {
      // Get provider for event creation
      final cubit = context.read<AggregationEventsCubit>();
      final validationProvider = context.read<ValidationCubit>();

      final String parentRaw = _parentEPCController.text.trim();
      final String parentEPC = parentRaw.isNotEmpty
          ? EPCFormatter.formatToEPCUri(parentRaw)
          : '';

      List<String> childEPCs = [];
      List<Map<String, Object>>? childQuantityList;

      if (_useQuantityList) {
        childQuantityList = [];
        for (final row in _quantityRows) {
          final epcClass = row.epcClass.text.trim();
          final qtyText = row.quantity.text.trim();
          if (epcClass.isEmpty && qtyText.isEmpty) {
            continue;
          }
          final qty = double.parse(qtyText);
          final entry = <String, Object>{
            'epcClass': epcClass,
            'quantity': qty,
          };
          final uom = row.uom.text.trim();
          if (uom.isNotEmpty) {
            entry['uom'] = uom;
          }
          childQuantityList.add(entry);
        }
        if (_selectedAction != 'DELETE' && childQuantityList.isEmpty) {
          setState(() => _isLoading = false);
          _errorMessage = 'Add at least one child quantity row';
          return;
        }
      } else {
        final List<String> rawChildEPCs = _childEPCsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        childEPCs = rawChildEPCs
            .map((epc) => EPCFormatter.formatToEPCUri(epc))
            .toList();
        if (_selectedAction != 'DELETE' && childEPCs.isEmpty) {
          setState(() => _isLoading = false);
          _errorMessage = 'At least one child EPC is required';
          return;
        }
      }
      
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
      
      final String businessStep = _businessStep ?? '';
      final String disposition = _disposition ?? '';
      final String locationGLN = _locationGLN!.glnCode;

      if (_referenceDataChecker != null) {
        final missing = await _referenceDataChecker!.findMissing(
          locationGlnCode: locationGLN,
          parentEpcUri: parentEPC.isNotEmpty ? parentEPC : null,
          childEpcUris: _useQuantityList || _selectedAction == 'DELETE'
              ? const []
              : childEPCs,
        );
        if (missing.isNotEmpty) {
          setState(() => _isLoading = false);
          if (mounted) {
            await AggregationMissingReferenceDialog.show(context, missing);
          }
          return;
        }
      }

      if (_pharmaReadinessChecker != null && _selectedAction == 'ADD') {
        final pharmaIssues = await _pharmaReadinessChecker!.findIssues(
          eventLocationGln: locationGLN,
          action: _selectedAction,
          parentEpcUri: parentEPC.isNotEmpty ? parentEPC : null,
          childEpcUris: _useQuantityList ? const [] : childEPCs,
        );
        if (pharmaIssues.isNotEmpty) {
          setState(() => _isLoading = false);
          if (mounted) {
            await AggregationPharmaIssuesDialog.show(context, pharmaIssues);
          }
          return;
        }
      }

      final eventToValidate = AggregationEvent(
        eventId: 'event_${DateTime.now().millisecondsSinceEpoch}',
        eventTime: _eventTime,
        recordTime: DateTime.now(),
        eventTimeZone: _eventTimeZoneOffset,
        epcisVersion: epcis_models.EPCISVersion.v2_0,
        action: _selectedAction,
        businessStep: businessStep,
        disposition: disposition,
        readPoint: GLN.fromCode(locationGLN),
        businessLocation: GLN.fromCode(locationGLN),
        bizData: bizData.isNotEmpty ? bizData : null,
        parentID: parentEPC.isNotEmpty ? parentEPC : '',
        childEPCs: _useQuantityList ? const [] : childEPCs,
        childQuantityList: childQuantityList,
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

      if (_useQuantityList || _selectedAction == 'OBSERVE') {
        await cubit.createAggregationEvent(eventToValidate);
      } else if (_selectedAction == 'ADD') {
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
          childEPCs: childEPCs.isEmpty ? null : childEPCs,
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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aggregation event created'),
          backgroundColor: Colors.green,
        ),
      );
      if (widget.embedded) {
        widget.onEmbeddedActionSuccess?.call();
      } else {
        Navigator.pop(context, true);
      }
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
          ].contains(d)).toList();
      
      case 'urn:epcglobal:cbv:bizstep:unpacking':
        return _standardDispositions.where((d) => 
          [
            'urn:epcglobal:cbv:disp:in_progress',
            'urn:epcglobal:cbv:disp:non_sellable_other',
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
            'urn:epcglobal:cbv:disp:retail_sold',
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
          '• container_closed: The container is sealed\n'
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
    final formBody = SingleChildScrollView(
              padding: EdgeInsets.all(
                widget.embedded ? context.gutter : 16.0,
              ),
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
                    const AggregationPharmaRulesPanel(),
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
                    
                    AggregationParentPackSection(
                      action: _selectedAction,
                      initialParentEpc: _parentEPCController.text.isEmpty
                          ? null
                          : _parentEPCController.text,
                      onParentEpcChanged: (epc) =>
                          _parentEPCController.text = epc,
                    ),
                    const SizedBox(height: 16.0),
                    
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Use class-level quantities'),
                      subtitle: const Text(
                        'childQuantityList (EPC class + quantity) instead of instance child EPCs',
                      ),
                      value: _useQuantityList,
                      onChanged: (value) => setState(() => _useQuantityList = value),
                    ),
                    const SizedBox(height: 8.0),
                    if (!_useQuantityList) ...[
                      TextFormField(
                        controller: _childEPCsController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: _selectedAction == 'DELETE'
                              ? 'Child EPCs (optional)'
                              : 'Child EPCs *',
                          border: const OutlineInputBorder(),
                          hintText:
                              'SGTIN URIs, (01)…(21)… barcodes, or Digital Link',
                          helperText: _selectedAction == 'DELETE'
                              ? 'Leave empty to unpack all children from parent'
                              : AggregationPharmaRulesText.childEpcsHint,
                          suffixIcon: const Tooltip(
                            message: 'Contained items (typically SGTINs)',
                            child: Icon(Icons.help_outline, size: 16),
                          ),
                        ),
                        validator: (value) =>
                            AggregationEventFormValidators.validateChildEpcList(
                          value,
                          _selectedAction,
                        ),
                      ),
                    ] else ...[
                      ..._quantityRows.asMap().entries.map((entry) {
                        final index = entry.key;
                        final row = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Quantity #${index + 1}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    if (_quantityRows.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                        onPressed: () => setState(() {
                                          row.dispose();
                                          _quantityRows.removeAt(index);
                                        }),
                                      ),
                                  ],
                                ),
                                TextFormField(
                                  controller: row.epcClass,
                                  decoration: const InputDecoration(
                                    labelText: 'EPC class *',
                                    hintText: 'urn:epc:idpat:sgtin:….*',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  validator: _selectedAction == 'DELETE'
                                      ? null
                                      : AggregationEventFormValidators
                                          .validateEpcClass,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: row.quantity,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Quantity *',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        validator: _selectedAction == 'DELETE'
                                            ? null
                                            : AggregationEventFormValidators
                                                .validateQuantity,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: row.uom,
                                        decoration: const InputDecoration(
                                          labelText: 'UoM',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: () => setState(
                          () => _quantityRows.add(_QuantityRowControllers()),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add quantity row'),
                      ),
                    ],
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
                    
                    GLNSelector(
                      label: 'Location GLN *',
                      hintText: AggregationPharmaRulesText.locationHint,
                      initialValue: _locationGLN,
                      isRequired: true,
                      errorText: _locationGlnError,
                      onChanged: (gln) => setState(() {
                        _locationGLN = gln;
                        _locationGlnError = null;
                      }),
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
                    SizedBox(
                      width: double.infinity,
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
                              : const Text('Create Event'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

    if (widget.embedded) {
      return Gs1MasterDataDetailScaffold(
        embedded: true,
        title: AggregationEventUiConstants.splitCreateHeader,
        showSaveAction: true,
        onSave: _isLoading ? null : _saveAggregationEvent,
        saveEnabled: !_isLoading,
        body: formBody,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Aggregation Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () => _showFullHelpScreen(context),
          ),
        ],
      ),
      body: formBody,
    );
  }
}
