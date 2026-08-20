import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:traqtrace_app/features/epcis/cubit/transformation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/features/epcis/widgets/help_widgets/transformation_event_form_help.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_form_body.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_form_content.dart';

import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/transformation_event_form_actions.dart';

class TransformationEventFormScreen extends StatefulWidget {
  final TransformationEvent? event;

  final String? transformationEventId;

  const TransformationEventFormScreen({
    Key? key,
    this.event,
    this.transformationEventId,
  }) : super(key: key);

  @override
  State<TransformationEventFormScreen> createState() =>
      TransformationEventFormScreenState();
}

class TransformationEventFormScreenState
    extends State<TransformationEventFormScreen> {
  final formKey = GlobalKey<FormState>();
  late DateTime eventTime;
  String eventTimeZoneOffset = '+00:00';
  Map<String, String> bizData = {};

  String? _lastKnownGLNCode;

  bool isLoading = false;
  bool isEdit = false;
  bool hasTriedToSubmit = false;
  Timer? _validationTimer;

  final transformationIdController = TextEditingController();
  final inputEpcsController = TextEditingController();
  final outputEpcsController = TextEditingController();
  final bizStepController = TextEditingController();
  final dispositionController = TextEditingController();
  final locationGLNController = TextEditingController();

  final certificateNumberController = TextEditingController();
  final certificationStandardController = TextEditingController();
  final certificationAgencyController = TextEditingController();
  final certificationTypeController = TextEditingController();

  void _setFieldError(String fieldName, String? error) {
    context.read<ValidationCubit>().setFieldError(fieldName, error);
  }

  @override
  void initState() {
    super.initState();

    eventTime = DateTime.now();
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    eventTimeZoneOffset = "${offset.isNegative ? '-' : '+'}$hours:$minutes";

    transformationIdController.addListener(_clearFieldErrors);
    inputEpcsController.addListener(_clearFieldErrors);
    outputEpcsController.addListener(_clearFieldErrors);
    bizStepController.addListener(_clearFieldErrors);
    dispositionController.addListener(_clearFieldErrors);
    locationGLNController.addListener(_clearFieldErrors);

    isEdit = widget.event != null || widget.transformationEventId != null;
    context.read<CbvVocabularyCubit>().loadVocabulary();

    if (isEdit && widget.event != null) {
      _initializeWithEvent(widget.event!);
    } else if (isEdit && widget.transformationEventId != null) {
      _loadEventData();
    }
  }

  Future<void> _loadEventData() async {
    setState(() => isLoading = true);

    try {
      final event = await context
          .read<TransformationEventsCubit>()
          .getTransformationEventById(widget.transformationEventId!);

      print('==== Event Data Received ====');
      print('Event ID: ${event.id}');
      print('Event Type: Transformation');
      print('Business Step: ${event.businessStep}');
      print('Disposition: ${event.disposition}');
      print('Business Location: ${event.businessLocation}');
      print('Biz Data: ${event.bizData}');
      print('===========================');

      _initializeWithEvent(event);

      if (event.bizData == null) {
        await tryRestoreGLNFromBackend(event.eventId);
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        context.showError('Error loading event: ${error.toString()}');
      }
    }
  }

  void _initializeWithEvent(TransformationEvent event) {
    eventTime = event.eventTime;
    eventTimeZoneOffset = event.eventTimeZone;
    transformationIdController.text = event.transformationID;
    inputEpcsController.text = event.inputEPCList.join(', ');
    outputEpcsController.text = event.outputEPCList.join(', ');

    if (event.businessStep != null && event.businessStep!.isNotEmpty) {
      if (event.businessStep!.contains(':')) {
        final parts = event.businessStep!.split(':');
        bizStepController.text = parts.last;
      } else {
        bizStepController.text = event.businessStep!;
      }

      print('Setting business step to: ${bizStepController.text}');
    }

    if (event.disposition != null && event.disposition!.isNotEmpty) {
      if (event.disposition!.contains(':')) {
        final parts = event.disposition!.split(':');
        dispositionController.text = parts.last;
      } else {
        dispositionController.text = event.disposition!;
      }

      print('Setting disposition to: ${dispositionController.text}');
    }
    String? glnCode;

    if (event.businessLocation != null) {
      if (event.businessLocation is Map &&
          (event.businessLocation as Map).containsKey('glnCode')) {
        glnCode = (event.businessLocation as Map)['glnCode']?.toString();
      } else {
        try {
          final dynamic location = event.businessLocation;
          final dynamic locationGlnCode = location.glnCode;
          if (locationGlnCode != null) {
            glnCode = locationGlnCode.toString();
          }
        } catch (e) {
          print(
            'Error accessing GLN code from business location: ${e.toString()}',
          );
        }
      }
    }

    if (glnCode == null && event.bizData != null) {
      final possibleKeys = [
        'locationGLNCode',
        'glnCode',
        'businessLocationGLN',
        'bizLocationGLN',
      ];
      for (final key in possibleKeys) {
        if (event.bizData!.containsKey(key) && event.bizData![key] != null) {
          glnCode = event.bizData![key];
          print('Found GLN code in bizData with key $key: $glnCode');

          _lastKnownGLNCode = glnCode;

          break;
        }
      }
    }

    if (glnCode == null && _lastKnownGLNCode != null) {
      glnCode = _lastKnownGLNCode;
      print('Using cached GLN code: $glnCode (bizData was null in response)');
    }

    if (glnCode != null) {
      locationGLNController.text = glnCode;
    } else {
      print('No GLN code found in event data');
    }

    bizData = event.bizData != null ? Map.from(event.bizData!) : {};

    if (event.certificationInfo != null &&
        event.certificationInfo!.isNotEmpty) {
      final firstCert = event.certificationInfo!.first;
      certificateNumberController.text = firstCert.certificateId ?? '';
      certificationStandardController.text =
          firstCert.certificationStandard ?? '';
      certificationAgencyController.text = firstCert.certificationAgency ?? '';
      certificationTypeController.text = firstCert.certificationType ?? '';
    }
  }

  void _clearFieldErrors() {
    if (hasTriedToSubmit) {
      _validationTimer?.cancel();

      _validationTimer = Timer(const Duration(milliseconds: 500), () {
        if (formKey.currentState != null && mounted) {
          formKey.currentState!.validate();
        }
      });
    }

    context.read<ValidationCubit>().clearValidation();
  }

  @override
  void dispose() {
    _validationTimer?.cancel();

    transformationIdController.removeListener(_clearFieldErrors);
    inputEpcsController.removeListener(_clearFieldErrors);
    outputEpcsController.removeListener(_clearFieldErrors);
    bizStepController.removeListener(_clearFieldErrors);
    dispositionController.removeListener(_clearFieldErrors);
    locationGLNController.removeListener(_clearFieldErrors);

    transformationIdController.dispose();
    inputEpcsController.dispose();
    outputEpcsController.dispose();
    bizStepController.dispose();
    dispositionController.dispose();
    locationGLNController.dispose();
    certificateNumberController.dispose();
    certificationStandardController.dispose();
    certificationAgencyController.dispose();
    certificationTypeController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(child: TransformationEventFormHelp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Transformation Event' : 'New Transformation Event',
        ),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconInfo),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body: isLoading && isEdit
          ? const Center(child: AppLoadingIndicator())
          : TransformationEventFormContent(
              onShowHelp: _showHelpDialog,
              form: TransformationEventFormBody(
                formKey: formKey,
                hasTriedToSubmit: hasTriedToSubmit,
                transformationIdController: transformationIdController,
                inputEpcsController: inputEpcsController,
                outputEpcsController: outputEpcsController,
                bizStepController: bizStepController,
                dispositionController: dispositionController,
                locationGlnController: locationGLNController,
                certificateNumberController: certificateNumberController,
                certificationStandardController:
                    certificationStandardController,
                certificationAgencyController: certificationAgencyController,
                certificationTypeController: certificationTypeController,
                eventTime: eventTime,
                validDispositions:
                    getValidDispositionsForCurrentBusinessStep(),
                onFieldError: _setFieldError,
                onGenerateSampleInput: generateSampleInputEPC,
                onGenerateBatchInput: generateBatchInputEPCs,
                onGenerateSampleOutput: generateSampleOutputEPC,
                onGenerateBatchOutput: generateBatchOutputEPCs,
                onBusinessStepChanged: (value) {
                  setState(() {
                    bizStepController.text = value;
                    dispositionController.text = '';
                  });
                },
                onDispositionChanged: (value) {
                  setState(() => dispositionController.text = value);
                },
                onEventTimeChanged: (value) {
                  setState(() => eventTime = value);
                },
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: isLoading ? null : saveEvent,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? 'UPDATE' : 'SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
