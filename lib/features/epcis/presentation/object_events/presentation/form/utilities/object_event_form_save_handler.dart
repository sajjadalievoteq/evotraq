import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/sensor_element.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/dialogs/object_event_form_entry_dialogs.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_event_mapper.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_response_parser.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';

/// Holds mutable form field values used during save.
class ObjectEventFormSaveData {
  final DateTime eventTime;
  final String eventTimeZone;
  final String? action;
  final String? businessStep;
  final String? disposition;
  final String? readPointGLN;
  final String? businessLocationGLN;
  final String? lotNumber;
  final List<String> epcList;
  final List<String> epcClassList;
  final List<types.QuantityElement> quantityList;
  final Map<String, dynamic> ilmd;
  final Map<String, String> bizData;
  final List<types.SourceDestination> sourceList;
  final List<types.SourceDestination> destinationList;
  final String? persistentDisposition;
  final List<SensorElement> sensorElementList;
  final List<CertificationInfo> certificationInfoList;
  final EPCISVersion epcisVersion;

  const ObjectEventFormSaveData({
    required this.eventTime,
    required this.eventTimeZone,
    required this.action,
    required this.businessStep,
    required this.disposition,
    required this.readPointGLN,
    required this.businessLocationGLN,
    required this.lotNumber,
    required this.epcList,
    required this.epcClassList,
    required this.quantityList,
    required this.ilmd,
    required this.bizData,
    required this.sourceList,
    required this.destinationList,
    required this.persistentDisposition,
    required this.sensorElementList,
    required this.certificationInfoList,
    required this.epcisVersion,
  });
}

class ObjectEventFormSaveResult {
  final bool success;
  final String? errorMessage;
  final List<dynamic> validationErrors;
  final bool isLoading;
  final bool validating;

  const ObjectEventFormSaveResult({
    required this.success,
    this.errorMessage,
    this.validationErrors = const [],
    this.isLoading = false,
    this.validating = false,
  });
}

/// Handles pre-save validation and persistence for object events.
class ObjectEventFormSaveHandler {
  ObjectEventFormSaveHandler._();

  static Future<ObjectEventFormSaveResult> save({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required ObjectEventFormSaveData data,
    required ObjectEvent? existingEvent,
    required bool embedded,
    required VoidCallback? onEmbeddedActionSuccess,
  }) async {
    if (!formKey.currentState!.validate()) {
      return const ObjectEventFormSaveResult(success: false);
    }

    if (data.epcList.isEmpty &&
        data.epcClassList.isEmpty &&
        data.quantityList.isEmpty) {
      return const ObjectEventFormSaveResult(
        success: false,
        errorMessage:
            'Per GS1 standard, you must add at least one EPC, EPC class, or quantity to identify the objects',
      );
    }

    if (data.action == 'ADD' && data.ilmd.isEmpty) {
      return const ObjectEventFormSaveResult(
        success: false,
        errorMessage:
            'Instance/Lot Master Data (ILMD) is required for ADD (commissioning) events according to GS1 standard. Please add lot number.',
      );
    }

    if (data.action == 'ADD' &&
        (data.lotNumber == null || data.lotNumber!.trim().isEmpty)) {
      return const ObjectEventFormSaveResult(
        success: false,
        errorMessage:
            'Lot number is required for commissioning events (ADD action)',
      );
    }

    final glnError = _validateGlns(
      data.businessLocationGLN,
      data.readPointGLN,
    );
    if (glnError != null) {
      return ObjectEventFormSaveResult(success: false, errorMessage: glnError);
    }

    final validationProvider = context.read<ValidationCubit>();

    try {
      if (data.action == null || data.action!.isEmpty) {
        return const ObjectEventFormSaveResult(
          success: false,
          errorMessage: 'Action is required.',
        );
      }
      if (data.businessStep == null || data.businessStep!.isEmpty) {
        return const ObjectEventFormSaveResult(
          success: false,
          errorMessage: 'Business step is required.',
        );
      }
      if (data.disposition == null || data.disposition!.isEmpty) {
        return const ObjectEventFormSaveResult(
          success: false,
          errorMessage: 'Disposition is required.',
        );
      }
      if (data.readPointGLN == null || data.readPointGLN!.isEmpty) {
        return const ObjectEventFormSaveResult(
          success: false,
          errorMessage: 'Read point GLN is required.',
        );
      }

      GLN readPoint;
      try {
        readPoint = GLN.fromCode(data.readPointGLN!);
      } catch (_) {
        return const ObjectEventFormSaveResult(
          success: false,
          errorMessage: 'Read point GLN is invalid.',
        );
      }

      final bool useEpcList = data.epcList.isNotEmpty;
      final bool hasQuantity = data.quantityList.isNotEmpty;

      if (!useEpcList && !hasQuantity) {
        return const ObjectEventFormSaveResult(
          success: false,
          errorMessage: 'Provide either EPC List or Quantity List.',
        );
      }

      print(
        'Schema decision: useEpcList=$useEpcList, hasQuantity=$hasQuantity',
      );
      if (useEpcList && hasQuantity) {
        print(
          'Both epcList and quantityList present - using epcList for schema validation',
        );
      }

      final eventToValidate = ObjectEvent(
        eventId: 'event_${DateTime.now().millisecondsSinceEpoch}',
        recordTime: DateTime.now(),
        eventTime: data.eventTime,
        eventTimeZone: data.eventTimeZone,
        epcisVersion: EPCISVersion.v2_0,
        action: data.action,
        disposition: data.disposition,
        businessStep: data.businessStep,
        readPoint: readPoint,
        businessLocation: data.businessLocationGLN != null
            ? GLN.fromCode(data.businessLocationGLN!)
            : null,
        bizData: data.bizData.isNotEmpty
            ? Map<String, String>.from(data.bizData)
            : null,
        epcList: useEpcList ? List<String>.from(data.epcList) : null,
        epcClassList: data.epcClassList.isNotEmpty
            ? List<String>.from(data.epcClassList)
            : null,
        quantityList: (!useEpcList && data.quantityList.isNotEmpty)
            ? List<types.QuantityElement>.from(data.quantityList)
            : null,
        ilmd: data.ilmd.isNotEmpty ? Map<String, dynamic>.from(data.ilmd) : null,
        sourceList: data.sourceList.isNotEmpty
            ? List<types.SourceDestination>.from(data.sourceList)
            : null,
        destinationList: data.destinationList.isNotEmpty
            ? List<types.SourceDestination>.from(data.destinationList)
            : null,
        persistentDisposition: data.persistentDisposition,
        sensorElementList: data.sensorElementList.isNotEmpty
            ? data.sensorElementList
            : null,
        certificationInfo: data.certificationInfoList.isNotEmpty
            ? data.certificationInfoList
            : null,
      );

      ObjectEventFormEventMapper.debugObjectEvent(eventToValidate);

      final result = await validationProvider.validateObjectEvent(
        eventToValidate,
      );

      if (!result) {
        print('\n======== VALIDATION RESPONSE ========');
        print(
          'Validation response: ${validationProvider.state.lastValidationResult}',
        );
        print('Validation error: ${validationProvider.state.error}');
        print('======================================\n');

        var errors = ObjectEventFormValidationResponseParser.extractErrorMessages(
          validationProvider.state.lastValidationResult,
        );

        if (errors.isEmpty && validationProvider.state.error != null) {
          errors = [validationProvider.state.error!];
        }

        if (errors.isEmpty) {
          final responseJson =
              validationProvider.state.lastValidationResult?.toString() ??
              'No response data';
          errors = [
            'Validation failed with status 409: Enhanced validation failed',
            'Response: $responseJson',
            'This may indicate a schema validation error or missing required fields.',
          ];
        }

        if (errors.isNotEmpty) {
          await ObjectEventFormEntryDialogs.showValidationErrors(
            context: context,
            errors: errors,
          );
        }

        return ObjectEventFormSaveResult(
          success: false,
          validationErrors: errors,
          errorMessage: validationProvider.state.error,
        );
      }
    } catch (e) {
      return ObjectEventFormSaveResult(
        success: false,
        errorMessage: 'Error validating event: ${e.toString()}',
      );
    }

    try {
      final cubit = context.read<ObjectEventsCubit>();

      if (existingEvent != null) {
        final updatedEvent = ObjectEvent(
          id: existingEvent.id,
          eventId: existingEvent.eventId,
          eventTime: data.eventTime,
          recordTime: existingEvent.recordTime,
          eventTimeZone: data.eventTimeZone,
          epcisVersion: data.epcisVersion,
          action: data.action,
          disposition: data.disposition,
          businessStep: data.businessStep,
          readPoint: data.readPointGLN != null
              ? GLN.fromCode(data.readPointGLN!)
              : null,
          businessLocation: data.businessLocationGLN != null
              ? GLN.fromCode(data.businessLocationGLN!)
              : null,
          bizData: data.bizData.isNotEmpty
              ? Map<String, String>.from(data.bizData)
              : null,
          epcList: data.epcList.isNotEmpty ? List<String>.from(data.epcList) : null,
          epcClassList: data.epcClassList.isNotEmpty
              ? List<String>.from(data.epcClassList)
              : null,
          quantityList: data.quantityList.isNotEmpty
              ? List<types.QuantityElement>.from(data.quantityList)
              : null,
          ilmd: data.ilmd.isNotEmpty ? Map<String, dynamic>.from(data.ilmd) : null,
          sourceList: data.sourceList.isNotEmpty
              ? List<types.SourceDestination>.from(data.sourceList)
              : null,
          destinationList: data.destinationList.isNotEmpty
              ? List<types.SourceDestination>.from(data.destinationList)
              : null,
          persistentDisposition: data.persistentDisposition,
          sensorElementList: data.sensorElementList.isNotEmpty
              ? data.sensorElementList
              : null,
          certificationInfo: data.certificationInfoList.isNotEmpty
              ? data.certificationInfoList
              : null,
        );

        await cubit.updateObjectEvent(updatedEvent);
      } else {
        await cubit.createObjectEvent(
          action: data.action!,
          bizStep: data.businessStep!,
          disposition: data.disposition!,
          readPoint: data.readPointGLN,
          bizLocation: data.businessLocationGLN,
          epcList: data.epcList.isNotEmpty ? data.epcList : null,
          epcClassList: data.epcClassList.isNotEmpty ? data.epcClassList : null,
          quantityList: data.quantityList.isNotEmpty ? data.quantityList : null,
          ilmd: data.ilmd,
          bizData: data.bizData,
          sourceList: data.sourceList,
          destinationList: data.destinationList,
          persistentDisposition: data.persistentDisposition,
          sensorElementList: data.sensorElementList.isNotEmpty
              ? data.sensorElementList.map((e) => e.toJson()).toList()
              : null,
          certificationInfo: data.certificationInfoList.isNotEmpty
              ? data.certificationInfoList.map((c) => c.toJson()).toList()
              : null,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingEvent != null
                ? 'Object event updated'
                : 'Object event created',
          ),
          backgroundColor: Colors.green,
        ),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (embedded) {
          onEmbeddedActionSuccess?.call();
        } else {
          context.pop(true);
        }
      });

      return const ObjectEventFormSaveResult(success: true);
    } catch (e) {
      return ObjectEventFormSaveResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  static String? _validateGlns(
    String? businessLocationGLN,
    String? readPointGLN,
  ) {
    if (businessLocationGLN != null && businessLocationGLN.isNotEmpty) {
      try {
        final parsed = ObjectEventFormValidators.parseGlnToCode(
          businessLocationGLN,
        );
        if (parsed.length != 13 || !RegExp(r'^\d{13}$').hasMatch(parsed)) {
          return 'Invalid Business Location GLN format: $businessLocationGLN';
        }
      } catch (e) {
        return 'Invalid Business Location GLN format: ${e.toString()}';
      }
    }

    if (readPointGLN != null && readPointGLN.isNotEmpty) {
      try {
        final parsed = ObjectEventFormValidators.parseGlnToCode(readPointGLN);
        if (parsed.length != 13 || !RegExp(r'^\d{13}$').hasMatch(parsed)) {
          return 'Invalid Read Point GLN format: $readPointGLN';
        }
      } catch (e) {
        return 'Invalid Read Point GLN format: ${e.toString()}';
      }
    }

    return null;
  }
}
