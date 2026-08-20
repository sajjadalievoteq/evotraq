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
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_event_mapper.dart';
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

import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/object_event_form_actions.dart';

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
  State<ObjectEventFormScreen> createState() => ObjectEventFormScreenState();
}

class ObjectEventFormScreenState extends State<ObjectEventFormScreen> {
  List<dynamic> validationErrors = [];
  final formKey = GlobalKey<FormState>();

  late DateTime eventTime;
  late String eventTimeZone;
  String? action;
  String? businessStep;
  String? disposition;
  GLN? readPoint;
  GLN? businessLocation;

  final List<String> epcList = [];
  final List<String> epcClassList = [];
  final List<types.QuantityElement> quantityList = [];
  final Map<String, String> bizData = {};
  final List<types.SourceDestination> sourceList = [];
  final List<types.SourceDestination> destinationList = [];
  String? persistentDisposition;

  final List<SensorElement> sensorElementList = [];
  final List<CertificationInfo> certificationInfoList = [];
  final Map<String, Object> ilmd = {};

  EPCISVersion epcisVersion = EPCISVersion.v2_0;

  String epcisVersionString() =>
      epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3';

  bool isLoading = false;
  String? errorMessage;
  String? queryItemDisposition;

  ObjectEventFormValidationContext get _validationContext =>
      ObjectEventFormValidationContext(
        getFieldError: getFieldError,
        hasFieldBeenValidated: hasFieldBeenValidated,
        setFieldError: setFieldError,
        markFieldAsValid: markFieldAsValid,
        validateField: validateField,
      );

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _initializeWithEvent(widget.event!);
    } else {
      eventTime = DateTime.now();
      final offset = DateTime.now().timeZoneOffset;
      final hours = offset.inHours.abs();
      final minutes = (offset.inMinutes.abs() % 60);
      final sign = offset.isNegative ? '-' : '+';
      eventTimeZone =
          '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      action = 'ADD';
      if (widget.currentItemDisposition != null) {
        applyDispositionContextActions();
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
          queryItemDisposition = queryParams['currentItemDisposition'];
          applyDispositionContextActions();
        });
      }
      if (queryParams.containsKey('bizStep')) {
        setState(() {
          final bizStep = queryParams['bizStep']!;
          businessStep = CbvVocabularyFormatter.formatBizStep(
            epcisVersionString(),
            bizStep.startsWith(CbvVocabularyFormatter.bizStepUrnPrefix)
                ? bizStep
                : '${CbvVocabularyFormatter.bizStepUrnPrefix}$bizStep',
          );
          syncIlmdState();
        });
      }
      if (queryParams.containsKey('action')) {
        setState(() {
          action = queryParams['action']!;
        });
      }
      if (queryParams.containsKey('epcs')) {
        setState(() {
          epcList.addAll(
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
    eventTime = event.eventTime;
    eventTimeZone = event.eventTimeZone;
    action = event.action;
    epcisVersion = event.epcisVersion ?? EPCISVersion.v1_3;
    businessStep = event.businessStep != null
        ? CbvVocabularyFormatter.formatBizStep(
            epcisVersionString(),
            event.businessStep!,
          )
        : null;
    disposition = event.disposition != null
        ? CbvVocabularyFormatter.formatDisposition(
            epcisVersionString(),
            event.disposition!,
          )
        : null;
    readPoint = event.readPoint;
    businessLocation = event.businessLocation;

    if (event.epcList != null) epcList.addAll(event.epcList!);
    if (event.epcClassList != null) epcClassList.addAll(event.epcClassList!);
    if (event.quantityList != null) quantityList.addAll(event.quantityList!);
    if (event.ilmd != null) {
      ilmd.addAll(Map<String, Object>.from(event.ilmd!));
    }
    if (event.bizData != null) bizData.addAll(event.bizData!);
    if (event.sourceList != null) sourceList.addAll(event.sourceList!);
    if (event.destinationList != null) {
      destinationList.addAll(event.destinationList!);
    }
    if (event.persistentDisposition != null) {
      persistentDisposition = event.persistentDisposition;
    }
    if (event.sensorElementList != null) {
      try {
        sensorElementList.addAll(
          ObjectEventFormEventMapper.mapListToSensorElementList(
            event.sensorElementList!,
          ),
        );
      } catch (_) {
        sensorElementList.clear();
      }
    }
    if (event.certificationInfo != null) {
      certificationInfoList.addAll(
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
      body: isLoading || isLoadingViewOnly
          ? const Center(child: AppLoadingIndicator())
          : BlocBuilder<ValidationCubit, ValidationState>(
              builder: (context, _) => Form(
                key: formKey,
                child: Column(
                  children: [
                    if (errorMessage != null || validationErrors.isNotEmpty)
                      const SizedBox(height: 16.0),
                    if (validationErrors.isNotEmpty)
                      ValidationErrorWidget(
                        validationErrors: validationErrors,
                        onDismiss: () => setState(() => validationErrors = []),
                      ),
                    if (errorMessage != null)
                      ObjectEventFormErrorBanner(
                        message: errorMessage!,
                        onDismiss: () => setState(() => errorMessage = null),
                      ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: context.padding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (allowedActionsForItemState().isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ObjectEventFormErrorBanner(
                                  message:
                                      'This item is in a terminal state (inactive or destroyed). No further EPCIS events can be recorded.',
                                  onDismiss: () {},
                                ),
                              ),
                            ObjectEventFormEpcisVersionSection(
                              epcisVersion: epcisVersion,
                              isViewOnly: widget.isViewOnly,
                              onChanged: (v) => setState(() {
                                epcisVersion = v;
                                formatCbvFieldsForVersion(v);
                              }),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormEventTimeSection(
                              eventTime: eventTime,
                              eventTimeZone: eventTimeZone,
                              isViewOnly: widget.isViewOnly,
                              isTimeZoneMandatory: isMandatory(
                                'eventTimeZone',
                              ),
                              validation: _validationContext,
                              onSelectEventTime: selectEventTime,
                              onTimeZoneChanged: (v) =>
                                  setState(() => eventTimeZone = v),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormActionSection(
                              action: action,
                              allowedActions: allowedActionsForItemState(),
                              isViewOnly: widget.isViewOnly,
                              isMandatory: isMandatory('action'),
                              validation: _validationContext,
                              onChanged: onActionChanged,
                              onRevalidateForm: () => Future.delayed(
                                const Duration(milliseconds: 100),
                                () => formKey.currentState?.validate(),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            CbvBizStepDispositionPicker(
                              action: action,
                              initialBizStep: businessStep,
                              initialDisposition: disposition,
                              epcisVersion: epcisVersion,
                              isViewOnly: widget.isViewOnly,
                              isBizStepMandatory: isMandatory('businessStep'),
                              isDispositionMandatory: isMandatory(
                                'disposition',
                              ),
                              validation: _validationContext,
                              onBizStepChanged: onBusinessStepChanged,
                              onDispositionChanged: (v) =>
                                  setState(() => disposition = v),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormLocationSection(
                              businessLocation: businessLocation,
                              readPoint: readPoint,
                              isViewOnly: widget.isViewOnly,
                              isBusinessLocationMandatory: isMandatory(
                                'businessLocationGLN',
                              ),
                              isReadPointMandatory: isMandatory(
                                'readPointGLN',
                              ),
                              validation: _validationContext,
                              onBusinessLocationChanged: (v) =>
                                  setState(() => businessLocation = v),
                              onReadPointChanged: (v) =>
                                  setState(() => readPoint = v),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormEpcsSection(
                              epcList: epcList,
                              isViewOnly: widget.isViewOnly,
                              action: action,
                              businessStep: businessStep,
                              quantityListEmpty: quantityList.isEmpty,
                              onChanged: (epcs) => setState(() {
                                epcList
                                  ..clear()
                                  ..addAll(epcs);
                                syncIlmdState();
                              }),
                            ),
                            if (shouldShowIlmdSection()) ...[
                              const SizedBox(height: 16.0),
                              ObjectEventFormIlmdSection(
                                ilmd: ilmd,
                                isViewOnly: widget.isViewOnly,
                                action: action,
                                businessStep: businessStep,
                                epcList: epcList,
                                onChanged: (ilmd) => setState(() {
                                  ilmd
                                    ..clear()
                                    ..addAll(ilmd);
                                }),
                              ),
                            ],
                            const SizedBox(height: 16.0),
                            ObjectEventFormEpcClassesSection(
                              epcClassList: epcClassList,
                              isViewOnly: widget.isViewOnly,
                              onChanged: (classes) => setState(() {
                                epcClassList
                                  ..clear()
                                  ..addAll(classes);
                              }),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormQuantitiesSection(
                              quantityList: quantityList,
                              isViewOnly: widget.isViewOnly,
                              action: action,
                              businessStep: businessStep,
                              epcListEmpty: epcList.isEmpty,
                              onChanged: (quantities) => setState(() {
                                quantityList
                                  ..clear()
                                  ..addAll(quantities);
                              }),
                            ),
                            ObjectEventFormSourceListSection(
                              sourceList: sourceList,
                              isViewOnly: widget.isViewOnly,
                              onChanged: (sources) => setState(() {
                                sourceList
                                  ..clear()
                                  ..addAll(sources);
                              }),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormDestinationListSection(
                              destinationList: destinationList,
                              isViewOnly: widget.isViewOnly,
                              action: action,
                              businessStep: businessStep,
                              epcListEmpty: epcList.isEmpty,
                              quantityListEmpty: quantityList.isEmpty,
                              epcList: epcList,
                              onChanged: (destinations) => setState(() {
                                destinationList
                                  ..clear()
                                  ..addAll(destinations);
                              }),
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormEventSummarySection(
                              action: action,
                              businessStep: businessStep,
                              disposition: disposition,
                              businessLocation: businessLocation,
                              epcList: epcList,
                              epcClassList: epcClassList,
                              quantityList: quantityList,
                              sourceList: sourceList,
                              destinationList: destinationList,
                              eventTime: eventTime,
                              eventTimeZone: eventTimeZone,
                            ),
                            const SizedBox(height: 16.0),
                            ObjectEventFormEpcis20ExtensionsSection(
                              epcisVersion: epcisVersion,
                              sensorElementList: sensorElementList,
                              certificationInfoList: certificationInfoList,
                              isViewOnly: widget.isViewOnly,
                              onSensorElementsChanged: (elements) =>
                                  setState(() {
                                    sensorElementList
                                      ..clear()
                                      ..addAll(elements);
                                  }),
                              onCertificationsChanged: (certs) => setState(() {
                                certificationInfoList
                                  ..clear()
                                  ..addAll(certs);
                              }),
                            ),
                            const SizedBox(height: 16.0),
                            if (!widget.isViewOnly &&
                                allowedActionsForItemState().isNotEmpty)
                              CustomElevatedButton(
                                onPressed: isLoading ? null : saveEvent,
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
