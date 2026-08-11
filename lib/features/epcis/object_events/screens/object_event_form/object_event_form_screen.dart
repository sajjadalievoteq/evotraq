import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/sensor_element.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_constants.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_event_mapper.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_mandatory_fields.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_save_handler.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_form_error_banner.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/cbv_biz_step_disposition_picker.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_action_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_destination_list_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_epc_classes_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_epcis20_extensions_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_epcis_version_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_epcs_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_event_summary_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_event_time_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_ilmd_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_location_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_quantities_section.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_form_source_list_section.dart';
import 'package:traqtrace_app/features/epcis/widgets/validation_error_widget.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';

part 'object_event_form_actions.dart';

class ObjectEventFormScreen extends StatefulWidget {
  final ObjectEvent? event;

  final bool isViewOnly;

  final bool embedded;

  final VoidCallback? onEmbeddedActionSuccess;

  final String? currentItemDisposition;

  const ObjectEventFormScreen({
    Key? key,
    this.event,
    this.isViewOnly = false,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
    this.currentItemDisposition,
  }) : super(key: key);

  @override
  State<ObjectEventFormScreen> createState() => _ObjectEventFormScreenState();
}

class _ObjectEventFormScreenState extends State<ObjectEventFormScreen> {
  List<dynamic> _validationErrors = [];
  final _formKey = GlobalKey<FormState>();

  late DateTime _eventTime;
  late String _eventTimeZone;
  String? _action;
  String? _businessStep;
  String? _disposition;
  GLN? _readPoint;
  GLN? _businessLocation;

  final List<String> _epcList = [];
  final List<String> _epcClassList = [];
  final List<types.QuantityElement> _quantityList = [];
  final Map<String, String> _bizData = {};
  final List<types.SourceDestination> _sourceList = [];
  final List<types.SourceDestination> _destinationList = [];
  String? _persistentDisposition;

  final List<SensorElement> _sensorElementList = [];
  final List<CertificationInfo> _certificationInfoList = [];
  final Map<String, Object> _ilmd = {};

  EPCISVersion _epcisVersion = EPCISVersion.v2_0;

  String _epcisVersionString() =>
      _epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3';

  bool _isLoading = false;
  String? _errorMessage;
  String? _queryItemDisposition;

  ObjectEventFormValidationContext get _validationContext =>
      ObjectEventFormValidationContext(
        getFieldError: _getFieldError,
        hasFieldBeenValidated: _hasFieldBeenValidated,
        setFieldError: _setFieldError,
        markFieldAsValid: _markFieldAsValid,
        validateField: _validateField,
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
      if (widget.currentItemDisposition != null) {
        _applyDispositionContextActions();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.event == null) {
      final queryParams = GoRouter.of(
        context,
      ).routeInformationProvider.value.uri.queryParameters;

      if (queryParams.containsKey('currentItemDisposition')) {
        setState(() {
          _queryItemDisposition = queryParams['currentItemDisposition'];
          _applyDispositionContextActions();
        });
      }
      if (queryParams.containsKey('bizStep')) {
        setState(() {
          final bizStep = queryParams['bizStep']!;
          _businessStep = CbvVocabularyFormatter.formatBizStep(
            _epcisVersionString(),
            bizStep.startsWith(CbvVocabularyFormatter.bizStepUrnPrefix)
                ? bizStep
                : '${CbvVocabularyFormatter.bizStepUrnPrefix}$bizStep',
          );
          _syncIlmdState();
        });
      }
      if (queryParams.containsKey('action')) {
        setState(() {
          _action = queryParams['action']!;
        });
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
    _epcisVersion = event.epcisVersion ?? EPCISVersion.v1_3;
    _businessStep = event.businessStep != null
        ? CbvVocabularyFormatter.formatBizStep(
            _epcisVersionString(),
            event.businessStep!,
          )
        : null;
    _disposition = event.disposition != null
        ? CbvVocabularyFormatter.formatDisposition(
            _epcisVersionString(),
            event.disposition!,
          )
        : null;
    _readPoint = event.readPoint;
    _businessLocation = event.businessLocation;

    if (event.epcList != null) _epcList.addAll(event.epcList!);
    if (event.epcClassList != null) _epcClassList.addAll(event.epcClassList!);
    if (event.quantityList != null) _quantityList.addAll(event.quantityList!);
    if (event.ilmd != null) {
      _ilmd.addAll(Map<String, Object>.from(event.ilmd!));
    }
    if (event.bizData != null) _bizData.addAll(event.bizData!);
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isViewOnly) {
      final state = context.watch<ObjectEventsCubit>().state;
      if (widget.event == null && state.selectedEvent != null) {
        _initializeWithEvent(state.selectedEvent!);
      }
    }

    final isLoadingViewOnly =
        widget.isViewOnly &&
        widget.event == null &&
        context.watch<ObjectEventsCubit>().state.selectedEvent == null;

    return Scaffold(
      body: _isLoading || isLoadingViewOnly
          ? const Center(child: AppLoadingIndicator())
          : BlocBuilder<ValidationCubit, ValidationState>(
              builder: (context, _) => Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_errorMessage != null || _validationErrors.isNotEmpty)
                      const SizedBox(height: 16.0),
                    if (_validationErrors.isNotEmpty)
                      ValidationErrorWidget(
                        validationErrors: _validationErrors,
                        onDismiss: () => setState(() => _validationErrors = []),
                      ),
                    if (_errorMessage != null)
                      ObjectEventFormErrorBanner(
                        message: _errorMessage!,
                        onDismiss: () => setState(() => _errorMessage = null),
                      ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: context.padding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_allowedActionsForItemState().isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ObjectEventFormErrorBanner(
                                  message:
                                      'This item is in a terminal state (inactive or destroyed). No further EPCIS events can be recorded.',
                                  onDismiss: () {},
                                ),
                              ),
                            ObjectEventFormEpcisVersionSection(
                              epcisVersion: _epcisVersion,
                              isViewOnly: widget.isViewOnly,
                              onChanged: (v) => setState(() {
                                _epcisVersion = v;
                                _formatCbvFieldsForVersion(v);
                              }),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormEventTimeSection(
                              eventTime: _eventTime,
                              eventTimeZone: _eventTimeZone,
                              isViewOnly: widget.isViewOnly,
                              isTimeZoneMandatory: _isMandatory(
                                'eventTimeZone',
                              ),
                              validation: _validationContext,
                              onSelectEventTime: _selectEventTime,
                              onTimeZoneChanged: (v) =>
                                  setState(() => _eventTimeZone = v),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormActionSection(
                              action: _action,
                              allowedActions: _allowedActionsForItemState(),
                              isViewOnly: widget.isViewOnly,
                              isMandatory: _isMandatory('action'),
                              validation: _validationContext,
                              onChanged: _onActionChanged,
                              onRevalidateForm: () => Future.delayed(
                                const Duration(milliseconds: 100),
                                () => _formKey.currentState?.validate(),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            CbvBizStepDispositionPicker(
                              action: _action,
                              initialBizStep: _businessStep,
                              initialDisposition: _disposition,
                              epcisVersion: _epcisVersion,
                              isViewOnly: widget.isViewOnly,
                              isBizStepMandatory: _isMandatory('businessStep'),
                              isDispositionMandatory: _isMandatory(
                                'disposition',
                              ),
                              validation: _validationContext,
                              onBizStepChanged: _onBusinessStepChanged,
                              onDispositionChanged: (v) =>
                                  setState(() => _disposition = v),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormLocationSection(
                              businessLocation: _businessLocation,
                              readPoint: _readPoint,
                              isViewOnly: widget.isViewOnly,
                              isBusinessLocationMandatory: _isMandatory(
                                'businessLocationGLN',
                              ),
                              isReadPointMandatory: _isMandatory(
                                'readPointGLN',
                              ),
                              validation: _validationContext,
                              onBusinessLocationChanged: (v) =>
                                  setState(() => _businessLocation = v),
                              onReadPointChanged: (v) =>
                                  setState(() => _readPoint = v),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormEpcsSection(
                              epcList: _epcList,
                              isViewOnly: widget.isViewOnly,
                              action: _action,
                              businessStep: _businessStep,
                              quantityListEmpty: _quantityList.isEmpty,
                              onChanged: (epcs) => setState(() {
                                _epcList
                                  ..clear()
                                  ..addAll(epcs);
                                _syncIlmdState();
                              }),
                            ),
                            if (_shouldShowIlmdSection()) ...[
                              const SizedBox(height: 16.0),
                              ObjectEventFormIlmdSection(
                                ilmd: _ilmd,
                                isViewOnly: widget.isViewOnly,
                                action: _action,
                                businessStep: _businessStep,
                                epcList: _epcList,
                                onChanged: (ilmd) => setState(() {
                                  _ilmd
                                    ..clear()
                                    ..addAll(ilmd);
                                }),
                              ),
                            ],
                            const SizedBox(height: 16.0),
                            ObjectEventFormEpcClassesSection(
                              epcClassList: _epcClassList,
                              isViewOnly: widget.isViewOnly,
                              onChanged: (classes) => setState(() {
                                _epcClassList
                                  ..clear()
                                  ..addAll(classes);
                              }),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormQuantitiesSection(
                              quantityList: _quantityList,
                              isViewOnly: widget.isViewOnly,
                              action: _action,
                              businessStep: _businessStep,
                              epcListEmpty: _epcList.isEmpty,
                              onChanged: (quantities) => setState(() {
                                _quantityList
                                  ..clear()
                                  ..addAll(quantities);
                              }),
                            ),
                            ObjectEventFormSourceListSection(
                              sourceList: _sourceList,
                              isViewOnly: widget.isViewOnly,
                              onChanged: (sources) => setState(() {
                                _sourceList
                                  ..clear()
                                  ..addAll(sources);
                              }),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormDestinationListSection(
                              destinationList: _destinationList,
                              isViewOnly: widget.isViewOnly,
                              action: _action,
                              businessStep: _businessStep,
                              epcListEmpty: _epcList.isEmpty,
                              quantityListEmpty: _quantityList.isEmpty,
                              epcList: _epcList,
                              onChanged: (destinations) => setState(() {
                                _destinationList
                                  ..clear()
                                  ..addAll(destinations);
                              }),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormEventSummarySection(
                              action: _action,
                              businessStep: _businessStep,
                              disposition: _disposition,
                              businessLocation: _businessLocation,
                              epcList: _epcList,
                              epcClassList: _epcClassList,
                              quantityList: _quantityList,
                              sourceList: _sourceList,
                              destinationList: _destinationList,
                              eventTime: _eventTime,
                              eventTimeZone: _eventTimeZone,
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormEpcis20ExtensionsSection(
                              epcisVersion: _epcisVersion,
                              sensorElementList: _sensorElementList,
                              certificationInfoList: _certificationInfoList,
                              isViewOnly: widget.isViewOnly,
                              onSensorElementsChanged: (elements) =>
                                  setState(() {
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
                            if (!widget.isViewOnly &&
                                _allowedActionsForItemState().isNotEmpty)
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
                  ],
                ),
              ),
            ),
    );
  }
}
