import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/utils/auth_input_field_utils.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_field_type.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_prefix_icon.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_suffix_icon.dart';

class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final AuthInputFieldType type;
  final String? Function(String?)? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final String? prefixAsset;
  final Widget? suffixIcon;
  final String? hintText;
  final String? helperText;
  final Color? helperTextColor;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.type = AuthInputFieldType.text,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.prefixIcon,
    this.prefixAsset,
    this.suffixIcon,
    this.hintText,
    this.helperText,
    this.helperTextColor,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == AuthInputFieldType.password;
  }

  @override
  Widget build(BuildContext context) {
    final showPasswordToggle =
        widget.suffixIcon == null &&
        widget.type == AuthInputFieldType.password;
    final hasSuffix = widget.suffixIcon != null || showPasswordToggle;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.type == AuthInputFieldType.password
          ? _obscureText
          : false,
      enabled: widget.enabled,
      keyboardType: AuthInputFieldUtils.keyboardType(widget.type),
      autofillHints: switch (widget.type) {
        AuthInputFieldType.email => const [AutofillHints.email],
        AuthInputFieldType.username => const [AutofillHints.username],
        _ => null,
      },
      autocorrect: widget.type == AuthInputFieldType.email ? false : true,
      enableSuggestions: widget.type == AuthInputFieldType.email ? false : true,
      textCapitalization:
          widget.type == AuthInputFieldType.email ||
              widget.type == AuthInputFieldType.password ||
              widget.type == AuthInputFieldType.username
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: AuthInputPrefixIcon(
          prefixIcon: widget.prefixIcon,
          prefixAsset:
              widget.prefixAsset ??
              AuthInputFieldUtils.defaultPrefixAsset(widget.type),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: hasSuffix
            ? AuthInputSuffixIcon(
                obscureText: _obscureText,
                showPasswordToggle: showPasswordToggle,
                onToggleObscure: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                suffixIcon: widget.suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        helperText: widget.helperText,
        helperStyle: widget.helperText == null
            ? null
            : TextStyle(color: widget.helperTextColor),
      ),
      validator: widget.validator ??
          (value) => AuthInputFieldUtils.defaultValidator(
                widget.type,
                widget.labelText,
                value,
              ),
    );
  }
}
