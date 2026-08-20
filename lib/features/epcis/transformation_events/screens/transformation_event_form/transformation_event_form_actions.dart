import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/transformation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/transformation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_generator.dart';
import 'package:uuid/uuid.dart';

extension TransformationEventFormActions on TransformationEventFormScreenState {
  Future<void> saveEvent() async {
    setState(() {
      hasTriedToSubmit = true;
    });

    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final cubit = context.read<TransformationEventsCubit>();
      final validationCubit = context.read<ValidationCubit>();

      final inputEpcs = inputEpcsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => EPCFormatter.formatToEPCUri(e) ?? e)
          .toList();

      final outputEpcs = outputEpcsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => EPCFormatter.formatToEPCUri(e) ?? e)
          .toList();

      final Map<String, String> resolvedBizData = Map.from(bizData);

      final String locationGLN = locationGLNController.text.trim();
      if (locationGLN.isNotEmpty) {
        resolvedBizData['locationGLNCode'] = locationGLN;

        resolvedBizData['businessLocationGLN'] = locationGLN;
        resolvedBizData['bizLocationGLN'] = locationGLN;
      }

      String transformationId = transformationIdController.text;
      if (!transformationId.startsWith('urn:') &&
          !transformationId.startsWith('http://') &&
          !transformationId.startsWith('https://')) {
        transformationId = 'urn:traqtrace:transformation:$transformationId';
      }

      String? bizStep = bizStepController.text.isNotEmpty
          ? bizStepController.text
          : null;
      String? disposition = dispositionController.text.isNotEmpty
          ? dispositionController.text
          : null;

      GLN? businessLocationGLN;
      GLN? readPointGLN;
      if (locationGLN.isNotEmpty) {
        businessLocationGLN = GLN.fromCode(locationGLN);
        readPointGLN = GLN.fromCode(locationGLN);
      }

      List<CertificationInfo>? certificationInfo;
      if (certificateNumberController.text.isNotEmpty ||
          certificationStandardController.text.isNotEmpty ||
          certificationAgencyController.text.isNotEmpty ||
          certificationTypeController.text.isNotEmpty) {
        certificationInfo = [
          CertificationInfo(
            certificateId: certificateNumberController.text.isNotEmpty
                ? certificateNumberController.text
                : null,
            certificationStandard:
                certificationStandardController.text.isNotEmpty
                ? certificationStandardController.text
                : null,
            certificationAgency: certificationAgencyController.text.isNotEmpty
                ? certificationAgencyController.text
                : null,
            certificationType: certificationTypeController.text.isNotEmpty
                ? certificationTypeController.text
                : null,
          ),
        ];
      }

      final event = TransformationEvent(
        id: isEdit ? widget.event?.id : null,
        eventId: isEdit ? widget.event?.eventId ?? '' : const Uuid().v4(),
        eventTime: eventTime,
        recordTime: DateTime.now(),
        eventTimeZoneOffset: eventTimeZoneOffset,
        bizStep: bizStep,
        disposition: disposition,
        readPoint: readPointGLN,
        bizLocation: businessLocationGLN,
        bizData: resolvedBizData,
        transformationID: transformationId,
        inputEPCList: inputEpcs,
        outputEPCList: outputEpcs,
        certificationInfo: certificationInfo,
      );

      final isValid = await validationCubit.validateTransformationEvent(event);

      if (!isValid && mounted) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (isEdit && widget.event != null) {
        await cubit.updateTransformationEvent(event);
      } else {
        await cubit.createTransformationEvent(event);
      }

      if (mounted) {
        context.showSuccess(
          'Transformation event ${isEdit ? "updated" : "created"} successfully',
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        context.showError('Error: ${error.toString()}');
      }
    }
  }

  void generateSampleInputEPC() {
    final sgtin = GS1Generator.generateRandomSGTIN('0614141', '107346');
    setState(() {
      final existingEpcs = inputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        inputEpcsController.text = sgtin;
      } else {
        inputEpcsController.text = '$existingEpcs, $sgtin';
      }
    });
  }

  void generateBatchInputEPCs() {
    final batch = GS1Generator.generateBatchSGTINs('0614141', '107346', 3);
    setState(() {
      final existingEpcs = inputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        inputEpcsController.text = batch.join(', ');
      } else {
        inputEpcsController.text = '$existingEpcs, ${batch.join(', ')}';
      }
    });
  }

  void generateSampleOutputEPC() {
    final sgtin = GS1Generator.generateRandomSGTIN('0614141', '207346');
    setState(() {
      final existingEpcs = outputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        outputEpcsController.text = sgtin;
      } else {
        outputEpcsController.text = '$existingEpcs, $sgtin';
      }
    });
  }

  void generateBatchOutputEPCs() {
    final batch = GS1Generator.generateBatchSGTINs('0614141', '207346', 3);
    setState(() {
      final existingEpcs = outputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        outputEpcsController.text = batch.join(', ');
      } else {
        outputEpcsController.text = '$existingEpcs, ${batch.join(', ')}';
      }
    });
  }

  List<String> getValidDispositionsForCurrentBusinessStep() {
    final cbvState = context.read<CbvVocabularyCubit>().state;
    if (cbvState.dispositions.isEmpty) {
      return const [];
    }
    if (bizStepController.text.isEmpty) {
      return cbvState.dispositions.map((item) => item.code).toList();
    }
    final allowedCodes =
        cbvState.bizStepValidDispositions[bizStepController.text];
    if (allowedCodes == null || allowedCodes.isEmpty) {
      return cbvState.dispositions.map((item) => item.code).toList();
    }
    final allowedSet = allowedCodes.toSet();
    return cbvState.dispositions
        .where((item) => allowedSet.contains(item.code))
        .map((item) => item.code)
        .toList();
  }

  Future<void> tryRestoreGLNFromBackend(String eventId) async {
    try {
      print('Trying to restore GLN code for event ID: $eventId');
    } catch (e) {
      print('Failed to restore GLN from backend: ${e.toString()}');
    }
  }
}
