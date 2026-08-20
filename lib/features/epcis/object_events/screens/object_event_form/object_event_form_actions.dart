import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_save_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/object_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_constants.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_mandatory_fields.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_save_handler.dart';

extension ObjectEventFormActions on ObjectEventFormScreenState {
  String? getFieldError(String fieldName) {
    return context.read<ValidationCubit>().getFieldError(fieldName);
  }

  bool hasFieldBeenValidated(String fieldName) {
    return context.read<ValidationCubit>().hasBeenValidated(fieldName);
  }

  void setFieldError(String fieldName, String? error) {
    context.read<ValidationCubit>().setFieldError(fieldName, error);
  }

  void markFieldAsValid(String fieldName) {
    context.read<ValidationCubit>().markFieldAsValid(fieldName);
  }

  void validateField(
    String fieldName,
    String value,
    String? Function(String) validator,
  ) {
    context.read<ValidationCubit>().validateField(fieldName, value, validator);
  }

  bool isMandatory(String fieldName) =>
      ObjectEventFormMandatoryFields.isFieldMandatory(
        fieldName: fieldName,
        action: action,
        businessStep: businessStep,
        epcListEmpty: epcList.isEmpty,
        quantityListEmpty: quantityList.isEmpty,
        epcList: epcList,
      );

  String? get _effectiveItemDisposition =>
      widget.currentItemDisposition ?? queryItemDisposition;

  List<String> allowedActionsForItemState() {
    final d = _effectiveItemDisposition;
    if (d == null) return objectEventActions;

    if (d.endsWith('inactive') ||
        d.endsWith('destroyed') ||
        d.endsWith('decommissioned')) {
      return [];
    }

    if (d.endsWith('active') ||
        d.endsWith('sellable_accessible') ||
        d.endsWith('sellable_not_accessible') ||
        d.endsWith('in_transit') ||
        d.endsWith('in_progress') ||
        d.endsWith('dispensed') ||
        d.endsWith('retail_sold') ||
        d.endsWith('returned')) {
      return ['OBSERVE', 'DELETE'];
    }

    if (d.endsWith('encoded')) {
      return ['ADD'];
    }

    return objectEventActions;
  }

  void applyDispositionContextActions() {
    final allowed = allowedActionsForItemState();
    if (_effectiveItemDisposition == null || allowed.isEmpty) return;
    if (allowed.length == 1 || !allowed.contains(action)) {
      setState(() => action = allowed.first);
    }
  }

  bool shouldShowIlmdSection() {
    if (action != 'ADD') return false;
    if (!CbvVocabularyFormatter.isBizStepCommissioning(businessStep)) {
      return false;
    }
    return epcList.any(Gs1CanonicalIdentifier.isSgtin);
  }

  void syncIlmdState() {
    if (!shouldShowIlmdSection()) {
      ilmd.clear();
    }
  }

  void formatCbvFieldsForVersion(EPCISVersion version) {
    final versionString = version == EPCISVersion.v2_0 ? '2.0' : '1.3';
    if (businessStep != null) {
      businessStep = CbvVocabularyFormatter.formatBizStep(
        versionString,
        businessStep!,
      );
    }
    if (disposition != null) {
      disposition = CbvVocabularyFormatter.formatDisposition(
        versionString,
        disposition!,
      );
    }
  }

  void onActionChanged(String? newAction) {
    setState(() {
      action = newAction;
      syncIlmdState();
    });
  }

  void onBusinessStepChanged(String? value) {
    setState(() {
      businessStep = value;
      syncIlmdState();
    });
  }

  Future<void> selectEventTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: eventTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(eventTime),
    );
    if (pickedTime == null) return;

    setState(() {
      eventTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> saveEvent() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      validationErrors = [];
    });

    final result = await ObjectEventFormSaveHandler.save(
      context: context,
      formKey: formKey,
      data: ObjectEventFormSaveData(
        eventTime: eventTime,
        eventTimeZone: eventTimeZone,
        action: action,
        businessStep: businessStep,
        disposition: disposition,
        readPointGLN: readPoint?.glnCode,
        businessLocationGLN: businessLocation?.glnCode,
        epcList: epcList,
        epcClassList: epcClassList,
        quantityList: quantityList,
        bizData: bizData,
        sourceList: sourceList,
        destinationList: destinationList,
        persistentDisposition: persistentDisposition,
        sensorElementList: sensorElementList,
        certificationInfoList: certificationInfoList,
        epcisVersion: epcisVersion,
        ilmd: Map<String, Object>.from(ilmd),
      ),
      existingEvent: widget.event,
      embedded: widget.embedded,
      onEmbeddedActionSuccess: widget.onEmbeddedActionSuccess,
    );

    if (!mounted) return;
    setState(() {
      isLoading = false;
      errorMessage = result.errorMessage;
      validationErrors = result.validationErrors;
    });
  }
}
