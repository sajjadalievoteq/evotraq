import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_required_indicator.dart';

class ObjectEventFormFieldDecoration {
  ObjectEventFormFieldDecoration._();

  static Widget buildFieldLabel(
    BuildContext context,
    String label,
    bool isMandatory,
  ) {
    return objectEventFormFieldLabel(context, label, isMandatory);
  }

  static Widget buildRequiredIndicator(BuildContext context) {
    return const ObjectEventFormRequiredIndicator();
  }

  static Widget buildValidationStatus({
    required String fieldName,
    required ObjectEventFormValidationContext validation,
  }) {
    final error = validation.getFieldError(fieldName);

    if (error != null && error.isNotEmpty) {
      return const Icon(Icons.error_outline, color: Colors.red, size: 20);
    } else if (validation.hasFieldBeenValidated(fieldName)) {
      return const Icon(
        Icons.check_circle_outline,
        color: Colors.green,
        size: 20,
      );
    }

    return const SizedBox.shrink();
  }

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
      label: buildFieldLabel(context, label, isMandatory),
      suffixIcon: error != null && error.isNotEmpty
          ? const Icon(Icons.error_outline, color: Colors.red)
          : hasBeenValidated
          ? const Icon(Icons.check_circle_outline, color: Colors.green)
          : null,
      errorText: error,
    );
  }
}
