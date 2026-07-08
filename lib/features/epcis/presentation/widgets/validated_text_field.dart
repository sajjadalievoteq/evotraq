import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validated_form_field.dart';

class ValidatedTextField extends StatefulWidget {
  final TextEditingController? controller;

  final InputDecoration decoration;

  final String? Function(String?)? validator;

  final String? helpText;

  final bool validateOnChange;

  final bool validateOnBlur;

  final bool readOnly;

  final Function(String)? onChanged;

  final TextInputType? keyboardType;

  final bool initiallyValidated;

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
