import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/sensor_element.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/mixins/event_form_validation_mixin.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/dialogs/object_event_form_entry_dialogs.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/dialogs/object_event_form_epc_dialogs.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_event_mapper.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_mandatory_fields.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_save_handler.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_error_banner.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_action_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_business_context_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_destination_list_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_epc_classes_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_epcis20_extensions_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_epcis_version_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_epcs_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_event_summary_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_event_time_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_location_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_lot_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_quantities_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/sections/object_event_form_source_list_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validation_error_widget.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';

/// Screen for creating or editing Object Events (GS1 EPCIS 2.0).
/// For read-only display use [ObjectEventDetailScreen].
class ObjectEventFormScreen extends StatefulWidget {
  /// Object event to pre-populate for editing; null for creation.
  final ObjectEvent? event;

  /// Whether this is view-only mode (kept for backward-compat; prefer
  /// [ObjectEventDetailScreen] for read-only use).
  final bool isViewOnly;

  /// When true the screen is hosted inside the split-view create pane.
  final bool embedded;

  /// Called when the embedded create/edit succeeds.
  final VoidCallback? onEmbeddedActionSuccess;

  const ObjectEventFormScreen({
    Key? key,
    this.event,
    this.isViewOnly = false,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  }) : super(key: key);

  @override
  State<ObjectEventFormScreen> createState() => _ObjectEventFormScreenState();
}

class _ObjectEventFormScreenState extends State<ObjectEventFormScreen>
    with EventFormValidationMixin<ObjectEventFormScreen> {
  bool _validating = false;
  List<dynamic> _validationErrors = [];
  final _formKey = GlobalKey<FormState>();

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

  final List<SensorElement> _sensorElementList = [];
  final List<CertificationInfo> _certificationInfoList = [];
  EPCISVersion _epcisVersion = EPCISVersion.v2_0;

  bool _isLoading = false;
  String? _errorMessage;

  ObjectEventFormValidationContext get _validationContext =>
      ObjectEventFormValidationContext(
        getFieldError: getFieldError,
        hasFieldBeenValidated: hasFieldBeenValidated,
        setFieldError: setFieldError,
        markFieldAsValid: markFieldAsValid,
        validateField: validateField,
      );

  bool _isMandatory(String fieldName) =>
      ObjectEventFormMandatoryFields.isFieldMandatory(
        fieldName: fieldName,
        epcisVersion: _epcisVersion,
        action: _action,
        epcListEmpty: _epcList.isEmpty,
        quantityListEmpty: _quantityList.isEmpty,
      );

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _initializeWithEvent(widget.event!);
    } else {
      _eventTime = DateTime.now();
      final offset = DateTime.now().timeZoneOffset;
      final hours = offset.inHours.abs();
      final minutes = (offset.inMinutes.abs() % 60);
      final sign = offset.isNegative ? '-' : '+';
      _eventTimeZone =
          '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      _action = 'ADD';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.event == null) {
      final queryParams = GoRouter.of(
        context,
      ).routeInformationProvider.value.uri.queryParameters;

      if (queryParams.containsKey('bizStep')) {
        setState(() {
          final bizStep = queryParams['bizStep']!;
          _businessStep = bizStep.startsWith('urn:epcglobal:cbv:bizstep:')
              ? bizStep
              : 'urn:epcglobal:cbv:bizstep:$bizStep';
        });
      }
      if (queryParams.containsKey('action')) {
        setState(() => _action = queryParams['action']!);
      }
      if (queryParams.containsKey('epcs')) {
        setState(() {
          _epcList.addAll(
            queryParams['epcs']!
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty),
          );
        });
      }
    }
  }

  void _initializeWithEvent(ObjectEvent event) {
    _eventTime = event.eventTime;
    _eventTimeZone = event.eventTimeZone;
    _action = event.action;
    _businessStep = event.businessStep;
    _disposition = event.disposition;
    _readPointGLN = event.readPoint?.glnCode;
    _businessLocationGLN = event.businessLocation?.glnCode;

    if (event.epcList != null) _epcList.addAll(event.epcList!);
    if (event.epcClassList != null) _epcClassList.addAll(event.epcClassList!);
    if (event.quantityList != null) _quantityList.addAll(event.quantityList!);
    if (event.bizData != null) _bizData.addAll(event.bizData!);
    if (event.ilmd != null) {
      _ilmd.addAll(event.ilmd!);
      _lotNumber =
          event.ilmd!['lot']?.toString() ?? event.ilmd!['lotID']?.toString();
    }
    if (event.sourceList != null) _sourceList.addAll(event.sourceList!);
    if (event.destinationList != null) {
      _destinationList.addAll(event.destinationList!);
    }
    if (event.persistentDisposition != null) {
      _persistentDisposition = event.persistentDisposition;
    }
    if (event.sensorElementList != null) {
      try {
        _sensorElementList.addAll(
          ObjectEventFormEventMapper.mapListToSensorElementList(
            event.sensorElementList!,
          ),
        );
      } catch (_) {
        _sensorElementList.clear();
      }
    }
    if (event.certificationInfo != null) {
      _certificationInfoList.addAll(
        ObjectEventFormEventMapper.mapListToCertificationInfoList(
          event.certificationInfo!,
        ),
      );
    }
    _epcisVersion = event.epcisVersion ?? EPCISVersion.v1_3;
    if (mounted) setState(() {});
  }

  Future<void> _selectEventTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _eventTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventTime),
    );
    if (pickedTime == null) return;

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

  void _updateLotNumber(String? value) {
    setState(() {
      _lotNumber = value;
      if (_lotNumber != null && _lotNumber!.isNotEmpty) {
        _ilmd['lot'] = _lotNumber;
      } else {
        _ilmd.remove('lot');
      }
    });
  }

  Future<void> _saveEvent() async {
    setState(() {
      _isLoading = true;
      _validating = true;
      _errorMessage = null;
      _validationErrors = [];
    });

    final result = await ObjectEventFormSaveHandler.save(
      context: context,
      formKey: _formKey,
      data: ObjectEventFormSaveData(
        eventTime: _eventTime,
        eventTimeZone: _eventTimeZone,
        action: _action,
        businessStep: _businessStep,
        disposition: _disposition,
        readPointGLN: _readPointGLN,
        businessLocationGLN: _businessLocationGLN,
        lotNumber: _lotNumber,
        epcList: _epcList,
        epcClassList: _epcClassList,
        quantityList: _quantityList,
        ilmd: _ilmd,
        bizData: _bizData,
        sourceList: _sourceList,
        destinationList: _destinationList,
        persistentDisposition: _persistentDisposition,
        sensorElementList: _sensorElementList,
        certificationInfoList: _certificationInfoList,
        epcisVersion: _epcisVersion,
      ),
      existingEvent: widget.event,
      embedded: widget.embedded,
      onEmbeddedActionSuccess: widget.onEmbeddedActionSuccess,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _validating = false;
      _errorMessage = result.errorMessage;
      _validationErrors = result.validationErrors;
    });
  }

  // Preserved for programmatic / future toolbar use (same as monolithic screen).
  // ignore: unused_element
  void _showHelpDialog() =>
      ObjectEventFormEntryDialogs.showHelpDialog(context: context);

  // ignore: unused_element
  void _addIlmd() => ObjectEventFormEntryDialogs.showAddIlmd(
    context: context,
    onAdd: (key, value) => setState(() => _ilmd[key] = value),
  );

  // ignore: unused_element
  Future<void> _runSchemaValidationTest() async {
    setState(() {
      _isLoading = true;
      _validating = true;
      _errorMessage = null;
      _validationErrors = [];
    });

    try {
      final validationProvider = context.read<ValidationCubit>();
      final minimalEvent = ObjectEvent(
        eventId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        recordTime: DateTime.now(),
        eventTime: DateTime.now().subtract(const Duration(seconds: 5)),
        eventTimeZone: '+00:00',
        epcisVersion: EPCISVersion.v2_0,
        action: 'OBSERVE',
        epcList: ['urn:epc:id:sgtin:0614141.107346.1000'],
        readPoint: GLN.fromCode('1234567890128'),
        certificationInfo: [
          CertificationInfo(
            certificateId: 'test-cert',
            certificationStandard: 'test-standard',
            certificationAgency: 'test-agency',
          ),
        ],
      );

      print('\n======== TESTING MINIMAL EVENT ========');
      ObjectEventFormEventMapper.debugObjectEvent(minimalEvent);
      final minimalResult = await validationProvider.validateObjectEvent(
        minimalEvent,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _validating = false;
      });

      await ObjectEventFormEntryDialogs.showSchemaValidationTestResults(
        context: context,
        passed: minimalResult,
        error: validationProvider.state.error,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _validating = false;
        _errorMessage = 'Error in validation test: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isViewOnly) {
      final state = context.watch<ObjectEventsCubit>().state;
      if (widget.event == null && state.selectedEvent != null) {
        _initializeWithEvent(state.selectedEvent!);
      }
    }

    final isLoadingViewOnly = widget.isViewOnly &&
        widget.event == null &&
        context.watch<ObjectEventsCubit>().state.selectedEvent == null;

    return Scaffold(
      body: _isLoading || isLoadingViewOnly
          ? const Center(child: AppLoadingIndicator())
          : SingleChildScrollView(
              padding: context.padding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_validationErrors.isNotEmpty)
                      ValidationErrorWidget(
                        validationErrors: _validationErrors,
                        onDismiss: () =>
                            setState(() => _validationErrors = []),
                      ),
                    if (_errorMessage != null)
                      ObjectEventFormErrorBanner(
                        message: _errorMessage!,
                        onDismiss: () => setState(() => _errorMessage = null),
                      ),
                    ObjectEventFormEpcisVersionSection(
                      epcisVersion: _epcisVersion,
                      isViewOnly: widget.isViewOnly,
                      onChanged: (v) => setState(() => _epcisVersion = v),
                    ),
                    const SizedBox(height: 16.0),
                    ObjectEventFormEventTimeSection(
                      eventTime: _eventTime,
                      eventTimeZone: _eventTimeZone,
                      isViewOnly: widget.isViewOnly,
                      isTimeZoneMandatory: _isMandatory('eventTimeZone'),
                      validation: _validationContext,
                      onSelectEventTime: _selectEventTime,
                      onTimeZoneChanged: (v) =>
                          setState(() => _eventTimeZone = v),
                    ),
                    const SizedBox(height: 16.0),
                    ObjectEventFormActionSection(
                      action: _action,
                      isViewOnly: widget.isViewOnly,
                      isMandatory: _isMandatory('action'),
                      validation: _validationContext,
                      onChanged: (v) => setState(() => _action = v),
                      onRevalidateForm: () => Future.delayed(
                        const Duration(milliseconds: 100),
                        () => _formKey.currentState?.validate(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ObjectEventFormBusinessContextSection(
                      businessStep: _businessStep,
                      disposition: _disposition,
                      isViewOnly: widget.isViewOnly,
                      isBusinessStepMandatory: _isMandatory('businessStep'),
                      isDispositionMandatory: _isMandatory('disposition'),
                      validation: _validationContext,
                      onBusinessStepChanged: (v) =>
                          setState(() => _businessStep = v),
                      onDispositionChanged: (v) =>
                          setState(() => _disposition = v),
                    ),
                    const SizedBox(height: 16.0),
                    ObjectEventFormLotSection(
                      lotNumber: _lotNumber,
                      action: _action,
                      isViewOnly: widget.isViewOnly,
                      isMandatory: _isMandatory('lotNumber'),
                      validation: _validationContext,
                      onChanged: _updateLotNumber,
                    ),
                    const SizedBox(height: 16.0),
                    ObjectEventFormLocationSection(
                      businessLocationGLN: _businessLocationGLN,
                      readPointGLN: _readPointGLN,
                      isViewOnly: widget.isViewOnly,
                      isBusinessLocationMandatory:
                          _isMandatory('businessLocationGLN'),
                      isReadPointMandatory: _isMandatory('readPointGLN'),
                      validation: _validationContext,
                      onBusinessLocationChanged: (v) =>
                          setState(() => _businessLocationGLN = v),
                      onReadPointChanged: (v) =>
                          setState(() => _readPointGLN = v),
                    ),
                    const SizedBox(height: 16.0),
                    ObjectEventFormEpcsSection(
                      epcList: _epcList,
                      isViewOnly: widget.isViewOnly,
                      onAdd: () => ObjectEventFormEpcDialogs.showAddEpc(
                        context: context,
                        onAdd: (epc) => setState(() => _epcList.add(epc)),
                        onScanBarcode: () =>
                            ObjectEventFormEpcDialogs.showScanBarcode(
                              context: context,
                              onAdd: (epc) =>
                                  setState(() => _epcList.add(epc)),
                            ),
                      ),
                      onBulkAdd: () => ObjectEventFormEpcDialogs.showBulkAddEpcs(
                        context: context,
                        onAddAll: (epcs) =>
                            setState(() => _epcList.addAll(epcs)),
                      ),
                      onGenerate: () =>
                          ObjectEventFormEpcDialogs.showGenerateEpcs(
                            context: context,
                            onGenerate: (epcs) =>
                                setState(() => _epcList.addAll(epcs)),
                          ),
                      onRemove: (i) => setState(() => _epcList.removeAt(i)),
                    ),
                    const SizedBox(height: 16.0),
                    ObjectEventFormEpcClassesSection(
                      epcClassList: _epcClassList,
                      isViewOnly: widget.isViewOnly,
                      onAdd: () => ObjectEventFormEntryDialogs.showAddEpcClass(
                        context: context,
                        onAdd: (c) => setState(() => _epcClassList.add(c)),
                      ),
                      onRemove: (i) =>
                          setState(() => _epcClassList.removeAt(i)),
                    ),
                    const SizedBox(height: 16.0),
                    ObjectEventFormQuantitiesSection(
                      quantityList: _quantityList,
                      isViewOnly: widget.isViewOnly,
                      onAdd: () => ObjectEventFormEntryDialogs.showAddQuantity(
                        context: context,
                        onAdd: (q) => setState(() => _quantityList.add(q)),
                      ),
                      onRemove: (i) =>
                          setState(() => _quantityList.removeAt(i)),
                    ),
                    ObjectEventFormSourceListSection(
                      sourceList: _sourceList,
                      isViewOnly: widget.isViewOnly,
                      onAdd: () => ObjectEventFormEntryDialogs.showAddSource(
                        context: context,
                        onAdd: (s) => setState(() => _sourceList.add(s)),
                      ),
                      onRemove: (i) =>
                          setState(() => _sourceList.removeAt(i)),
                    ),
                    const SizedBox(height: 16.0),
                    ObjectEventFormDestinationListSection(
                      destinationList: _destinationList,
                      isViewOnly: widget.isViewOnly,
                      onAdd: () =>
                          ObjectEventFormEntryDialogs.showAddDestination(
                            context: context,
                            onAdd: (d) =>
                                setState(() => _destinationList.add(d)),
                          ),
                      onRemove: (i) =>
                          setState(() => _destinationList.removeAt(i)),
                    ),
                    const SizedBox(height: 16.0),
                    ObjectEventFormEventSummarySection(
                      action: _action,
                      businessStep: _businessStep,
                      disposition: _disposition,
                      businessLocationGLN: _businessLocationGLN,
                      epcList: _epcList,
                      epcClassList: _epcClassList,
                      quantityList: _quantityList,
                      sourceList: _sourceList,
                      destinationList: _destinationList,
                      eventTime: _eventTime,
                      eventTimeZone: _eventTimeZone,
                    ),
                    const SizedBox(height: 32.0),
                    ObjectEventFormEpcis20ExtensionsSection(
                      epcisVersion: _epcisVersion,
                      sensorElementList: _sensorElementList,
                      certificationInfoList: _certificationInfoList,
                      isViewOnly: widget.isViewOnly,
                      onSensorElementsChanged: (elements) => setState(() {
                        _sensorElementList
                          ..clear()
                          ..addAll(elements);
                      }),
                      onCertificationsChanged: (certs) => setState(() {
                        _certificationInfoList
                          ..clear()
                          ..addAll(certs);
                      }),
                    ),
                    const SizedBox(height: 16.0),
                    if (!widget.isViewOnly)
                      CustomElevatedButton(
                        onPressed: _isLoading ? null : _saveEvent,
                        label: widget.event != null
                            ? 'Update Object Event'
                            : 'Create Object Event',
                      ),
                    SizedBox(height: context.gutter),
                  ],
                ),
              ),
            ),
    );
  }
}
