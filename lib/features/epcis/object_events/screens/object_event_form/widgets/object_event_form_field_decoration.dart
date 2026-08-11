import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_form_required_indicator.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class ObjectEventFormFieldDecoration {
  ObjectEventFormFieldDecoration._();

  static InputDecoration getFieldDecoration({
    required BuildContext context,
    required String fieldName,
    required String label,
    required ObjectEventFormValidationContext validation,
    String? hintText,
    bool isMandatory = false,
  }) {
    final error = validation.getFieldError(fieldName);
    final hasBeenValidated = validation.hasFieldBeenValidated(fieldName);

    return InputDecoration(
      hintText: hintText,
      border: const OutlineInputBorder(),
      label: ObjectEventFormFieldLabel(label: label, isMandatory: isMandatory),
      suffixIcon: error != null && error.isNotEmpty
          ? TraqIcon(
              AppAssets.iconAlert,
              color: AppColorMapper.errorColor(context),
            )
          : hasBeenValidated
          ? TraqIcon(
              AppAssets.iconCheck,
              color: AppColorMapper.successColor(context),
            )
          : null,
      errorText: error,
    );
  }
}
