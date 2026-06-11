import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';

/// Field label and [InputDecoration] helpers with validation status icons.
class ObjectEventFormFieldDecoration {
  ObjectEventFormFieldDecoration._();

  static Widget buildFieldLabel(String label, bool isMandatory) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (isMandatory)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  static Widget buildRequiredIndicator() {
    return const Text(
      ' *',
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    );
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
      label: buildFieldLabel(label, isMandatory),
      suffixIcon: error != null && error.isNotEmpty
          ? const Icon(Icons.error_outline, color: Colors.red)
          : hasBeenValidated
          ? const Icon(Icons.check_circle_outline, color: Colors.green)
          : null,
      errorText: error,
    );
  }
}
