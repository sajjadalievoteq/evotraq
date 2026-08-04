import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_svg_icon.dart';

class AuthInputSuffixIcon extends StatelessWidget {
  const AuthInputSuffixIcon({
    super.key,
    required this.obscureText,
    required this.showPasswordToggle,
    required this.onToggleObscure,
    this.suffixIcon,
  });

  final bool obscureText;
  final bool showPasswordToggle;
  final VoidCallback onToggleObscure;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    if (suffixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, right: 16),
        child: suffixIcon,
      );
    }

    if (!showPasswordToggle) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: IconButton(
        icon: AuthInputSvgIcon(
          asset: obscureText ? AppAssets.iconEyeOff : AppAssets.iconEye,
          size: 22,
        ),
        onPressed: onToggleObscure,
      ),
    );
  }
}
