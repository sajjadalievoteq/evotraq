import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gs1_field_barcode_scan.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart' as epcis_models;
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/data/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_quantity_row_controllers.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_reference_data_checker.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_body.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_error_dialog.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_help_dialog.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_missing_reference_dialog.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utils/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';
import 'package:world_countries/helpers.dart';

import '../../../../../../core/widgets/traq_app_bar.dart';
import '../../../../mixins/event_form_validation_mixin.dart'
    show showValidationErrors;

class AggregationEventFormScreen extends StatefulWidget {
  const AggregationEventFormScreen({
    super.key,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  });

  final bool embedded;
  final VoidCallback? onEmbeddedActionSuccess;

  @override
  State<AggregationEventFormScreen> createState() =>
      _AggregationEventFormScreenState();
}

class _AggregationEventFormScreenState extends State<AggregationEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _validationErrors = [];

  String _selectedAction = 'ADD';
  final _parentEPCController = TextEditingController();
  final List<TextEditingController> _childEpcControllers = [];
  String? _businessStep;
  String? _disposition;
  GLN? _locationGLN;
  String? _locationGlnError;
  AggregationReferenceDataChecker? _referenceDataChecker;
  AggregationPharmaReadinessChecker? _pharmaReadinessChecker;

  final List<MapEntry<TextEditingController, TextEditingController>>
      _sourceListControllers = [];
  final List<MapEntry<TextEditingController, TextEditingController>>
      _destinationListControllers = [];
  final List<MapEntry<TextEditingController, TextEditingController>>
      _bizDataControllers = [];
  final List<AggregationEventFormQuantityRowControllers> _quantityRows = [
    AggregationEventFormQuantityRowControllers(),
  ];
  bool _useQuantityList = false;
  DateTime _eventTime = DateTime.now();
  String _eventTimeZoneOffset = '+00:00';
  Timer? _timer;
  bool _isManualTime = false;

  @override
  void initState() {
    super.initState();

    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    _eventTimeZoneOffset =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    _childEpcControllers.add(TextEditingController());
    _addBizDataField();

    _startClock();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isManualTime) {
        setState(() {
          _eventTime = DateTime.now();
        });
      }
    });
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
    _timer?.cancel();
    _parentEPCController.dispose();
    for (final c in _childEpcControllers) {
      c.dispose();
    }
    for (final row in _quantityRows) {
      row.dispose();
    }
    for (final entry in _bizDataControllers) {
      entry.key.dispose();
      entry.value.dispose();
    }
    for (final entry in _sourceListControllers) {
      entry.key.dispose();
      entry.value.dispose();
    }
    for (final entry in _destinationListControllers) {
      entry.key.dispose();
      entry.value.dispose();
    }
    super.dispose();
  }

  void _addChildEpc([String value = '']) {
    setState(
      () => _childEpcControllers.add(TextEditingController(text: value)),
    );
  }

  void _removeChildEpc(int index) {
    setState(() {
      _childEpcControllers.removeAt(index).dispose();
    });
  }

  Future<void> _scanAndAddChildEpc() async {
    final value =
        await Gs1FieldBarcodeScan.scan(context, Gs1FieldScanKind.sgtin);
    if (value != null && value.isNotEmpty && mounted) {
      _addChildEpc(value);
    }
  }

  void _addQuantityRow() {
    setState(
      () => _quantityRows.add(AggregationEventFormQuantityRowControllers()),
    );
  }

  void _removeQuantityRow(
    int index,
    AggregationEventFormQuantityRowControllers row,
  ) {
    setState(() {
      row.dispose();
      _quantityRows.removeAt(index);
    });
  }

  void _addBizDataField() {
    setState(() {
      _bizDataControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void _removeBizDataField(int index) {
    setState(() {
      final entry = _bizDataControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  void _addSourceEntry() {
    setState(() {
      _sourceListControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void _removeSourceEntry(int index) {
    setState(() {
      final entry = _sourceListControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  void _addDestinationEntry() {
    setState(() {
      _destinationListControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void _removeDestinationEntry(int index) {
    setState(() {
      final entry = _destinationListControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  List<Map<String, dynamic>> _getSourceList() {
    final sourceList = <Map<String, dynamic>>[];
    for (final entry in _sourceListControllers) {
      final type = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (type.isNotEmpty && value.isNotEmpty) {
        sourceList.add({'type': type, 'source': value});
      }
    }
    return sourceList;
  }

  List<Map<String, dynamic>> _getDestinationList() {
    final destinationList = <Map<String, dynamic>>[];
    for (final entry in _destinationListControllers) {
      final type = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (type.isNotEmpty && value.isNotEmpty) {
        destinationList.add({'type': type, 'destination': value});
      }
    }
    return destinationList;
  }

  Future<void> _selectEventTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && mounted) {
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_eventTime),
      );

      if (timePicked != null) {
        setState(() {
          _isManualTime = true;
          _timer?.cancel();
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
      final cubit = context.read<AggregationEventsCubit>();
      final validationProvider = context.read<ValidationCubit>();

      final parentRaw = _parentEPCController.text.trim();
      final parentEPC = parentRaw.isNotEmpty
          ? EPCFormatter.formatToEPCUri(parentRaw) ?? parentRaw
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
          _errorMessage = 'Add at least one item quantity row';
          return;
        }
      } else {
        childEPCs = _childEpcControllers
            .map((c) => c.text.trim())
            .where((e) => e.isNotEmpty)
            .map((epc) => EPCFormatter.formatToEPCUri(epc) ?? epc)
            .toList();
        if (_selectedAction != 'DELETE' && childEPCs.isEmpty) {
          setState(() => _isLoading = false);
          _errorMessage = 'At least one item EPC is required';
          return;
        }
      }

      final bizData = <String, String>{};
      for (final entry in _bizDataControllers) {
        final key = entry.key.text.trim();
        final value = entry.value.text.trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          bizData[key] = value;
        }
      }

      final sourceList = _getSourceList();
      final destinationList = _getDestinationList();
      final businessStep = _businessStep ?? '';
      final disposition = _disposition ?? '';
      final locationGLN = _locationGLN!.glnCode;

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

      final isValid =
          await validationProvider.validateAggregationEvent(eventToValidate);

      if (!isValid) {
        final validationResult = validationProvider.state.lastValidationResult;
        final extractedErrors = validationProvider.validationErrors
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();

        setState(() {
          _isLoading = false;
          _validationErrors = extractedErrors;
          if (_validationErrors.isEmpty) {
            _errorMessage = validationProvider.state.error ??
                validationResult?['error']?.toString() ??
                'Aggregation event validation failed. Check business step, '
                    'disposition, parent/item EPCs, and location GLN.';
          }
        });

        if (_validationErrors.isNotEmpty) {
          showValidationErrors(context, _validationErrors);
        } else if (mounted && _errorMessage != null) {
          await AggregationEventFormErrorDialog.show(
            context,
            errorMessage: _errorMessage!,
          );
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

  context.showSuccess('Aggregation event created');
      if (widget.embedded) {
        widget.onEmbeddedActionSuccess?.call();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) {
        await AggregationEventFormErrorDialog.show(
          context,
          errorMessage: _errorMessage!,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formBody = AggregationEventFormBody(
      formKey: _formKey,
      validationErrors: _validationErrors,
      onDismissValidationErrors: () => setState(() => _validationErrors = []),
      errorMessage: _errorMessage,
      onDismissErrorMessage: () => setState(() => _errorMessage = null),
      selectedAction: _selectedAction,
      onActionChanged: (value) => setState(() => _selectedAction = value!),
      eventTime: _eventTime,
      onSelectEventTime: _selectEventTime,
      businessStep: _businessStep,
      disposition: _disposition,
      onBizStepChanged: (v) => setState(() => _businessStep = v),
      onDispositionChanged: (v) => setState(() => _disposition = v),
      initialParentEpc: _parentEPCController.text.isEmpty
          ? null
          : _parentEPCController.text,
      onParentEpcChanged: (epc) => _parentEPCController.text = epc,
      useQuantityList: _useQuantityList,
      onUseQuantityListChanged: (v) => setState(() => _useQuantityList = v),
      childEpcControllers: _childEpcControllers,
      onAddChildEpc: _addChildEpc,
      onRemoveChildEpc: _removeChildEpc,
      onScanAndAddChildEpc: _scanAndAddChildEpc,
      quantityRows: _quantityRows,
      onAddQuantityRow: _addQuantityRow,
      onRemoveQuantityRow: _removeQuantityRow,
      locationGLN: _locationGLN,
      locationGlnError: _locationGlnError,
      onLocationChanged: (gln) => setState(() {
        _locationGLN = gln;
        _locationGlnError = null;
      }),
      sourceListControllers: _sourceListControllers,
      onAddSourceEntry: _addSourceEntry,
      onRemoveSourceEntry: _removeSourceEntry,
      destinationListControllers: _destinationListControllers,
      onAddDestinationEntry: _addDestinationEntry,
      onRemoveDestinationEntry: _removeDestinationEntry,
      bizDataControllers: _bizDataControllers,
      onAddBizDataField: _addBizDataField,
      onRemoveBizDataField: _removeBizDataField,
      onSave: _saveAggregationEvent,
      isLoading: _isLoading,
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
      appBar: TraqAppBar(
        context,
        title: const Text('Create Aggregation Event'),
      ),
      body: formBody,
    );
  }
}
