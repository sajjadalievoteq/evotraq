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
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_form_entry_dialogs.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_constants.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_event_mapper.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_validation_response_parser.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
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
