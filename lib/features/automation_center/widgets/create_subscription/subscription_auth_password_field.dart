import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// A [FormBuilderTextField] with an obscure-text/eye-icon toggle, matching the
/// visual convention used elsewhere in the app for password entry (see
/// `AuthInputField`), but built on `FormBuilderTextField` since this field
/// lives inside a `FormBuilder` (subscription create/edit dialog).
class SubscriptionAuthPasswordField extends StatefulWidget {
  const SubscriptionAuthPasswordField({
    super.key,
    required this.name,
    this.labelText = 'API Password',
    this.hintText,
    this.helperText,
  });

  final String name;
  final String labelText;
  final String? hintText;
  final String? helperText;

  @override
  State<SubscriptionAuthPasswordField> createState() =>
      _SubscriptionAuthPasswordFieldState();
}

class _SubscriptionAuthPasswordFieldState
    extends State<SubscriptionAuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.name,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          tooltip: _obscureText ? 'Show password' : 'Hide password',
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
    );
  }
}
