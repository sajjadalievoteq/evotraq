import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/utils/auth_email_validator.dart';

enum AuthInputFieldType { email, password, username, text }

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

  String _defaultPrefixAsset() {
    switch (widget.type) {
      case AuthInputFieldType.password:
        return AppAssets.iconLock;
      case AuthInputFieldType.email:
        return AppAssets.iconMail;
      case AuthInputFieldType.username:
        return AppAssets.iconUser;
      default:
        return AppAssets.iconInfo;
    }
  }

  Widget _svgIcon(String asset, {double size = 22}) {
    final themeColor = context.colors.textMuted;
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        themeColor.withOpacity(0.75),
        BlendMode.srcIn,
      ),
      placeholderBuilder: (_) => SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
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

  String? _defaultValidator(String? value) {
    switch (widget.type) {
      case AuthInputFieldType.email:
        return AuthEmailValidator.validate(value);
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
      child: widget.prefixAsset != null
          ? _svgIcon(widget.prefixAsset!, size: 22)
          : (widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 22)
                : _svgIcon(_defaultPrefixAsset(), size: 22)),
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
        icon: _svgIcon(
          _obscureText ? AppAssets.iconEyeOff : AppAssets.iconEye,
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
      focusNode: widget.focusNode,
      obscureText: widget.type == AuthInputFieldType.password
          ? _obscureText
          : false,
      enabled: widget.enabled,
      keyboardType: _getKeyboardType(),
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
