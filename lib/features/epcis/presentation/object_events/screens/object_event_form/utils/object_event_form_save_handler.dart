import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/sensor_element.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_entry_dialogs.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_constants.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_event_mapper.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_validation_response_parser.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';

class ObjectEventFormSaveData {
  final DateTime eventTime;
  final String eventTimeZone;
  final String? action;
  final String? businessStep;
  final String? disposition;
  final String? readPointGLN;
  final String? businessLocationGLN;
  final List<String> epcList;
  final List<String> epcClassList;
  final List<types.QuantityElement> quantityList;
  final Map<String, String> bizData;
  final List<types.SourceDestination> sourceList;
  final List<types.SourceDestination> destinationList;
  final String? persistentDisposition;
  final List<SensorElement> sensorElementList;
  final List<CertificationInfo> certificationInfoList;
  final EPCISVersion epcisVersion;
  final Map<String, Object> ilmd;

  const ObjectEventFormSaveData({
    required this.eventTime,
    required this.eventTimeZone,
    required this.action,
    required this.businessStep,
    required this.disposition,
    required this.readPointGLN,
    required this.businessLocationGLN,
    required this.epcList,
    required this.epcClassList,
    required this.quantityList,
    required this.bizData,
    required this.sourceList,
    required this.destinationList,
    required this.persistentDisposition,
    required this.sensorElementList,
    required this.certificationInfoList,
    required this.epcisVersion,
    required this.ilmd,
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

class ObjectEventFormSaveHandler {
  ObjectEventFormSaveHandler._();

  static ObjectEventFormSaveData _sanitizeData(ObjectEventFormSaveData data) {
    final epcList = data.epcList
        .map((epc) => epc.trim())
        .where((epc) => epc.isNotEmpty)
        .map((epc) => EPCFormatter.formatToEPCUri(epc) ?? epc)
        .toList();
    final epcClassList = data.epcClassList
        .map((epcClass) => epcClass.trim())
        .where((epcClass) => epcClass.isNotEmpty)
        .toList();
    final quantityList = data.quantityList
        .where(
          (quantity) =>
              quantity.epcClass.trim().isNotEmpty && quantity.quantity > 0,
        )
        .toList();
    final sourceList = data.sourceList
        .where((source) => source.id.trim().isNotEmpty)
        .toList();
    final destinationList = data.destinationList
        .where((destination) => destination.id.trim().isNotEmpty)
        .toList();
    final sensorElementList = data.sensorElementList
        .map(
          (sensor) => sensor.copyWith(
            measurements: sensor.measurements
                .where(
                  (measurement) =>
                      measurement.value != null ||
                      measurement.type.trim().isNotEmpty &&
                          measurement.type != 'Temperature' ||
                      measurement.unitOfMeasure?.trim().isNotEmpty == true ||
                      measurement.measurementTime != null,
                )
                .toList(),
          ),
        )
        .where(
          (sensor) =>
              sensor.deviceId?.trim().isNotEmpty == true ||
              sensor.deviceMetadata?.trim().isNotEmpty == true ||
              sensor.time != null ||
              sensor.measurements.isNotEmpty,
        )
        .toList();
    final certificationInfoList = data.certificationInfoList
        .where(
          (certification) =>
              certification.certificationType?.trim().isNotEmpty == true ||
              certification.certificateId?.trim().isNotEmpty == true ||
              certification.certificationStandard?.trim().isNotEmpty == true ||
              certification.certificationAgency?.trim().isNotEmpty == true ||
              certification.documentUrl?.trim().isNotEmpty == true ||
              certification.remarks?.trim().isNotEmpty == true ||
              certification.issueDate != null ||
              certification.expirationDate != null,
        )
        .toList();

    return ObjectEventFormSaveData(
      eventTime: data.eventTime,
      eventTimeZone: data.eventTimeZone,
      action: data.action,
      businessStep: data.businessStep,
      disposition: data.disposition,
      readPointGLN: data.readPointGLN,
      businessLocationGLN: data.businessLocationGLN,
      epcList: epcList,
      epcClassList: epcClassList,
      quantityList: quantityList,
      bizData: data.bizData,
      sourceList: sourceList,
      destinationList: destinationList,
      persistentDisposition: data.persistentDisposition,
      sensorElementList: sensorElementList,
      certificationInfoList: certificationInfoList,
      epcisVersion: data.epcisVersion,
      ilmd: Map<String, Object>.from(data.ilmd),
    );
  }

  static bool _requiresCommissioningIlmd(ObjectEventFormSaveData data) {
    if (data.action != 'ADD') return false;
    if (!CbvVocabularyFormatter.isBizStepCommissioning(data.businessStep)) {
      return false;
    }
    return data.epcList.any((epc) => epc.toLowerCase().contains('sgtin'));
  }

  static Map<String, dynamic>? _ilmdForPayload(Map<String, Object> ilmd) {
    if (ilmd.isEmpty) return null;
    return Map<String, dynamic>.from(ilmd);
  }

  static String _apiExceptionUserMessage(ApiException e) {
    try {
      if (e.responseBody != null && e.responseBody!.isNotEmpty) {
        final decoded = json.decode(e.responseBody!);
        if (decoded is Map) {
          final messages = ObjectEventFormValidationResponseParser
              .extractErrorMessages(Map<String, dynamic>.from(decoded));
          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }
      }
    } catch (_) {
      // Fall through to ApiException message helpers.
    }
    return e.getUserFriendlyMessage();
  }

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

    final sanitized = _sanitizeData(data);

    if (sanitized.epcList.isEmpty &&
        sanitized.epcClassList.isEmpty &&
        sanitized.quantityList.isEmpty) {
      return const ObjectEventFormSaveResult(
        success: false,
        errorMessage:
            'Per GS1 standard, you must add at least one EPC, EPC class, or quantity to identify the objects',
      );
    }

    final glnError = _validateGlns(
      data.businessLocationGLN,
      data.readPointGLN,
    );
    if (glnError != null) {
      return ObjectEventFormSaveResult(success: false, errorMessage: glnError);
    }

    if (_requiresCommissioningIlmd(sanitized)) {
      final expiry =
          sanitized.ilmd[ilmdItemExpirationDateKey]?.toString().trim() ?? '';
      final manufacturer =
          sanitized.ilmd[ilmdManufacturerOfGoodsKey]?.toString().trim() ?? '';
      if (expiry.isEmpty) {
        return const ObjectEventFormSaveResult(
          success: false,
          errorMessage:
              'Item expiration date (cbvmda:itemExpirationDate) is required for pharmaceutical commissioning events.',
        );
      }
      if (manufacturer.isEmpty) {
        return const ObjectEventFormSaveResult(
          success: false,
          errorMessage:
              'Manufacturer of goods (cbvmda:manufacturerOfGoods) is required for pharmaceutical commissioning events.',
        );
      }
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

      final bool useEpcList = sanitized.epcList.isNotEmpty;
      final bool hasQuantity = sanitized.quantityList.isNotEmpty;

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
        epcList: useEpcList ? List<String>.from(sanitized.epcList) : null,
        epcClassList: sanitized.epcClassList.isNotEmpty
            ? List<String>.from(sanitized.epcClassList)
            : null,
        quantityList: (!useEpcList && sanitized.quantityList.isNotEmpty)
            ? List<types.QuantityElement>.from(sanitized.quantityList)
            : null,
        sourceList: sanitized.sourceList.isNotEmpty
            ? List<types.SourceDestination>.from(sanitized.sourceList)
            : null,
        destinationList: sanitized.destinationList.isNotEmpty
            ? List<types.SourceDestination>.from(sanitized.destinationList)
            : null,
        persistentDisposition: data.persistentDisposition,
        sensorElementList: data.sensorElementList.isNotEmpty
            ? data.sensorElementList
            : null,
        certificationInfo: data.certificationInfoList.isNotEmpty
            ? data.certificationInfoList
            : null,
        ilmd: _ilmdForPayload(sanitized.ilmd),
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
          epcList: sanitized.epcList.isNotEmpty
              ? List<String>.from(sanitized.epcList)
              : null,
          epcClassList: sanitized.epcClassList.isNotEmpty
              ? List<String>.from(sanitized.epcClassList)
              : null,
          quantityList: sanitized.quantityList.isNotEmpty
              ? List<types.QuantityElement>.from(sanitized.quantityList)
              : null,
          ilmd: _ilmdForPayload(sanitized.ilmd) ?? existingEvent.ilmd,
          sourceList: sanitized.sourceList.isNotEmpty
              ? List<types.SourceDestination>.from(sanitized.sourceList)
              : null,
          destinationList: sanitized.destinationList.isNotEmpty
              ? List<types.SourceDestination>.from(sanitized.destinationList)
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
          epcList: sanitized.epcList.isNotEmpty ? sanitized.epcList : null,
          epcClassList:
              sanitized.epcClassList.isNotEmpty ? sanitized.epcClassList : null,
          quantityList:
              sanitized.quantityList.isNotEmpty ? sanitized.quantityList : null,
          bizData: data.bizData,
          sourceList: sanitized.sourceList,
          destinationList: sanitized.destinationList,
          persistentDisposition: data.persistentDisposition,
          sensorElementList: data.sensorElementList.isNotEmpty
              ? data.sensorElementList.map((e) => e.toJson()).toList()
              : null,
          certificationInfo: data.certificationInfoList.isNotEmpty
              ? data.certificationInfoList.map((c) => c.toJson()).toList()
              : null,
          ilmd: _ilmdForPayload(sanitized.ilmd),
          epcisVersion: data.epcisVersion == EPCISVersion.v2_0
              ? types.EPCISVersion.v2_0
              : types.EPCISVersion.v1_3,
        );
      }

      context.showSuccess(
        existingEvent != null
            ? 'Object event updated'
            : 'Object event created',
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
    } catch (e, st) {
      if (e is ApiException) {
        final parsed = _apiExceptionUserMessage(e);
        debugPrint(
          '[ObjectEventFormSaveHandler] create ApiException '
          'status=${e.statusCode} message=${e.message}',
        );
        if (e.responseBody != null && e.responseBody!.isNotEmpty) {
          debugPrint(
            '[ObjectEventFormSaveHandler] responseBody: ${e.responseBody}',
          );
        }
        return ObjectEventFormSaveResult(
          success: false,
          errorMessage: parsed,
        );
      }
      debugPrint('[ObjectEventFormSaveHandler] create error: $e');
      debugPrint('[ObjectEventFormSaveHandler] $st');
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
