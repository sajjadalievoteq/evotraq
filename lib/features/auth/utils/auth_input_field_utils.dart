import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/auth/utils/auth_email_validator.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_field_type.dart';

abstract final class AuthInputFieldUtils {
  static TextInputType keyboardType(AuthInputFieldType type) {
    switch (type) {
      case AuthInputFieldType.email:
        return TextInputType.emailAddress;
      case AuthInputFieldType.password:
        return TextInputType.visiblePassword;
      default:
        return TextInputType.text;
    }
  }

  static String? defaultValidator(
    AuthInputFieldType type,
    String labelText,
    String? value,
  ) {
    switch (type) {
      case AuthInputFieldType.email:
        return AuthEmailValidator.validate(value);
      default:
        if (value == null || value.isEmpty) {
          return 'Please enter ${labelText.toLowerCase()}';
        }
        return null;
    }
  }

  static String defaultPrefixAsset(AuthInputFieldType type) {
    switch (type) {
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
}
