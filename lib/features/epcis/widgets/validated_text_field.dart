import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_form_field.dart';

/// A text field with built-in progressive validation display.
///
/// This widget wraps a standard TextFormField but adds real-time validation feedback
/// including visual indicators (icons) for valid/invalid states. It is designed to work
/// with the ValidationNotification system to provide immediate user feedback.
///
/// Use this component for all text input fields that require validation in non-FormBuilder forms,
/// particularly in GS1 and EPCIS related screens.
class ValidatedTextField extends StatefulWidget {
  /// Controller for the text field
  final TextEditingController? controller;

  /// Decoration for the text field
  final InputDecoration decoration;

  /// Validator function that returns an error string or null if valid
  final String? Function(String?)? validator;

  /// Help text to display below the field
  final String? helpText;

  /// Whether to validate on text change (true by default)
  final bool validateOnChange;

  /// Whether to validate when field loses focus (true by default)
  final bool validateOnBlur;

  /// Whether the field is read only (disables editing)
  final bool readOnly;

  /// Callback when value changes
  final Function(String)? onChanged;

  /// Text input type (e.g., number, email, etc.)
  final TextInputType? keyboardType;

  /// Whether the field should be validated immediately on display
  final bool initiallyValidated;

  /// Constructor
  const ValidatedTextField({
    Key? key,
    this.controller,
    this.decoration = const InputDecoration(),
    this.validator,
    this.helpText,
    this.validateOnChange = true,
    this.validateOnBlur = true,
    this.readOnly = false,
    this.onChanged,
    this.keyboardType,
    this.initiallyValidated = false,
  }) : super(key: key);

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValidatedFormField(
      focusNode: _focusNode,
      validator: widget.validator ?? (_) => null,
      helpText: widget.helpText,
      validateOnChange: widget.validateOnChange,
      validateOnBlur: widget.validateOnBlur,
      initiallyValidated: widget.initiallyValidated,
      formField: Builder(
        builder: (context) {
          return TextFormField(
            focusNode: _focusNode,
            controller: widget.controller,
            decoration: widget.decoration,
            readOnly: widget.readOnly,
            keyboardType: widget.keyboardType,
            onChanged: (value) {
              ValidationNotification(value).dispatch(context);
              widget.onChanged?.call(value);
            },
            validator: widget.validator,
          );
        },
      ),
    );
  }
}
