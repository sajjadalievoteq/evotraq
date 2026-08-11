import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:traqtrace_app/features/epcis/cubit/transformation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/features/epcis/widgets/help_widgets/transformation_event_form_help.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_generator.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:uuid/uuid.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_form_body.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_form_content.dart';

part 'transformation_event_form_actions.dart';

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
      _TransformationEventFormScreenState();
}

class _TransformationEventFormScreenState
    extends State<TransformationEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _eventTime;
  String _eventTimeZoneOffset = '+00:00';
  Map<String, String> _bizData = {};

  String? _lastKnownGLNCode;

  bool _isLoading = false;
  bool _isEdit = false;
  bool _hasTriedToSubmit = false;
  Timer? _validationTimer;

  final _transformationIdController = TextEditingController();
  final _inputEpcsController = TextEditingController();
  final _outputEpcsController = TextEditingController();
  final _bizStepController = TextEditingController();
  final _dispositionController = TextEditingController();
  final _locationGLNController = TextEditingController();

  final _certificateNumberController = TextEditingController();
  final _certificationStandardController = TextEditingController();
  final _certificationAgencyController = TextEditingController();
  final _certificationTypeController = TextEditingController();

  void _setFieldError(String fieldName, String? error) {
    context.read<ValidationCubit>().setFieldError(fieldName, error);
  }

  @override
  void initState() {
    super.initState();

    _eventTime = DateTime.now();
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    _eventTimeZoneOffset = "${offset.isNegative ? '-' : '+'}$hours:$minutes";

    _transformationIdController.addListener(_clearFieldErrors);
    _inputEpcsController.addListener(_clearFieldErrors);
    _outputEpcsController.addListener(_clearFieldErrors);
    _bizStepController.addListener(_clearFieldErrors);
    _dispositionController.addListener(_clearFieldErrors);
    _locationGLNController.addListener(_clearFieldErrors);

    _isEdit = widget.event != null || widget.transformationEventId != null;
    context.read<CbvVocabularyCubit>().loadVocabulary();

    if (_isEdit && widget.event != null) {
      _initializeWithEvent(widget.event!);
    } else if (_isEdit && widget.transformationEventId != null) {
      _loadEventData();
    }
  }

  Future<void> _loadEventData() async {
    setState(() => _isLoading = true);

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
        await _tryRestoreGLNFromBackend(event.eventId);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        context.showError('Error loading event: ${error.toString()}');
      }
    }
  }

  void _initializeWithEvent(TransformationEvent event) {
    _eventTime = event.eventTime;
    _eventTimeZoneOffset = event.eventTimeZone;
    _transformationIdController.text = event.transformationID;
    _inputEpcsController.text = event.inputEPCList.join(', ');
    _outputEpcsController.text = event.outputEPCList.join(', ');

    if (event.businessStep != null && event.businessStep!.isNotEmpty) {
      if (event.businessStep!.contains(':')) {
        final parts = event.businessStep!.split(':');
        _bizStepController.text = parts.last;
      } else {
        _bizStepController.text = event.businessStep!;
      }

      print('Setting business step to: ${_bizStepController.text}');
    }

    if (event.disposition != null && event.disposition!.isNotEmpty) {
      if (event.disposition!.contains(':')) {
        final parts = event.disposition!.split(':');
        _dispositionController.text = parts.last;
      } else {
        _dispositionController.text = event.disposition!;
      }

      print('Setting disposition to: ${_dispositionController.text}');
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
      _locationGLNController.text = glnCode;
    } else {
      print('No GLN code found in event data');
    }

    _bizData = event.bizData != null ? Map.from(event.bizData!) : {};

    if (event.certificationInfo != null &&
        event.certificationInfo!.isNotEmpty) {
      final firstCert = event.certificationInfo!.first;
      _certificateNumberController.text = firstCert.certificateId ?? '';
      _certificationStandardController.text =
          firstCert.certificationStandard ?? '';
      _certificationAgencyController.text = firstCert.certificationAgency ?? '';
      _certificationTypeController.text = firstCert.certificationType ?? '';
    }
  }

  void _clearFieldErrors() {
    if (_hasTriedToSubmit) {
      _validationTimer?.cancel();

      _validationTimer = Timer(const Duration(milliseconds: 500), () {
        if (_formKey.currentState != null && mounted) {
          _formKey.currentState!.validate();
        }
      });
    }

    context.read<ValidationCubit>().clearValidation();
  }

  @override
  void dispose() {
    _validationTimer?.cancel();

    _transformationIdController.removeListener(_clearFieldErrors);
    _inputEpcsController.removeListener(_clearFieldErrors);
    _outputEpcsController.removeListener(_clearFieldErrors);
    _bizStepController.removeListener(_clearFieldErrors);
    _dispositionController.removeListener(_clearFieldErrors);
    _locationGLNController.removeListener(_clearFieldErrors);

    _transformationIdController.dispose();
    _inputEpcsController.dispose();
    _outputEpcsController.dispose();
    _bizStepController.dispose();
    _dispositionController.dispose();
    _locationGLNController.dispose();
    _certificateNumberController.dispose();
    _certificationStandardController.dispose();
    _certificationAgencyController.dispose();
    _certificationTypeController.dispose();
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
          _isEdit ? 'Edit Transformation Event' : 'New Transformation Event',
        ),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconInfo),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body: _isLoading && _isEdit
          ? const Center(child: AppLoadingIndicator())
          : TransformationEventFormContent(
              onShowHelp: _showHelpDialog,
              form: TransformationEventFormBody(
                formKey: _formKey,
                hasTriedToSubmit: _hasTriedToSubmit,
                transformationIdController: _transformationIdController,
                inputEpcsController: _inputEpcsController,
                outputEpcsController: _outputEpcsController,
                bizStepController: _bizStepController,
                dispositionController: _dispositionController,
                locationGlnController: _locationGLNController,
                certificateNumberController: _certificateNumberController,
                certificationStandardController:
                    _certificationStandardController,
                certificationAgencyController: _certificationAgencyController,
                certificationTypeController: _certificationTypeController,
                eventTime: _eventTime,
                validDispositions:
                    _getValidDispositionsForCurrentBusinessStep(),
                onFieldError: _setFieldError,
                onGenerateSampleInput: _generateSampleInputEPC,
                onGenerateBatchInput: _generateBatchInputEPCs,
                onGenerateSampleOutput: _generateSampleOutputEPC,
                onGenerateBatchOutput: _generateBatchOutputEPCs,
                onBusinessStepChanged: (value) {
                  setState(() {
                    _bizStepController.text = value;
                    _dispositionController.text = '';
                  });
                },
                onDispositionChanged: (value) {
                  setState(() => _dispositionController.text = value);
                },
                onEventTimeChanged: (value) {
                  setState(() => _eventTime = value);
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
                onPressed: _isLoading ? null : _saveEvent,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'UPDATE' : 'SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
