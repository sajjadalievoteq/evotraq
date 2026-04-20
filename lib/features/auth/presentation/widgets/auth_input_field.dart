import 'package:flutter/material.dart';

enum AuthInputFieldType { email, password, username, text }

class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final AuthInputFieldType type;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
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
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.prefixIcon,
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

  IconData _getPrefixIcon() {
    if (widget.prefixIcon != null) return widget.prefixIcon!;

    switch (widget.type) {
      case AuthInputFieldType.password:
        return Icons.lock;
      case AuthInputFieldType.email:
        return Icons.email;
      case AuthInputFieldType.username:
        return Icons.person;
      default:
        return Icons.text_fields;
    }
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case AuthInputFieldType.email:
        return TextInputType.emailAddress;
      case AuthInputFieldType.password:
        return TextInputType.visiblePassword;
      default:
        return TextInputType.text;
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }
    if (email.contains(' ')) {
      return 'Email address cannot contain spaces';
    }

    final atMatches = '@'.allMatches(email).length;
    if (atMatches != 1) {
      return 'Email address must contain a single @ symbol';
    }

    final parts = email.split('@');
    final localPart = parts.first;
    final domainPart = parts.last;

    if (localPart.isEmpty) {
      return 'Email username is required before @';
    }
    if (domainPart.isEmpty) {
      return 'Email domain is required after @';
    }
    if (localPart.startsWith('.') || localPart.endsWith('.')) {
      return 'Email username cannot start or end with a dot';
    }
    if (localPart.contains('..')) {
      return 'Email username cannot contain consecutive dots';
    }
    if (!domainPart.contains('.')) {
      return 'Email domain must include a dot';
    }
    if (domainPart.startsWith('.') || domainPart.endsWith('.')) {
      return 'Email domain cannot start or end with a dot';
    }
    if (domainPart.contains('..')) {
      return 'Email domain cannot contain consecutive dots';
    }

    final domainLabels = domainPart.split('.');
    if (domainLabels.any((label) => label.isEmpty)) {
      return 'Email domain contains an invalid dot placement';
    }
    if (domainLabels.any(
      (label) => label.startsWith('-') || label.endsWith('-'),
    )) {
      return 'Email domain labels cannot start or end with a hyphen';
    }
    if (domainLabels.last.length < 2) {
      return 'Email domain extension must be at least 2 characters';
    }

    final emailRegex = RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _defaultValidator(String? value) {
    switch (widget.type) {
      case AuthInputFieldType.email:
        return _validateEmail(value);
      default:
        if (value == null || value.isEmpty) {
          return 'Please enter ${widget.labelText.toLowerCase()}';
        }
        return null;
    }
  }

  Widget _buildPrefixIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Icon(_getPrefixIcon(), size: 22),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, right: 16),
        child: widget.suffixIcon,
      );
    }

    if (widget.type != AuthInputFieldType.password) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          size: 22,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.type == AuthInputFieldType.password
          ? _obscureText
          : false,
      enabled: widget.enabled,
      keyboardType: _getKeyboardType(),
      autofillHints: widget.type == AuthInputFieldType.email
          ? const [AutofillHints.email]
          : null,
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
        prefixIcon: _buildPrefixIcon(),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: _buildSuffixIcon(),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        helperText: widget.helperText,
        helperStyle: widget.helperText == null
            ? null
            : TextStyle(color: widget.helperTextColor),
      ),
      validator: widget.validator ?? _defaultValidator,
    );
  }
}
