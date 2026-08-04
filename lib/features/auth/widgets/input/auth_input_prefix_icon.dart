import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_svg_icon.dart';

class AuthInputPrefixIcon extends StatelessWidget {
  const AuthInputPrefixIcon({
    super.key,
    required this.prefixAsset,
    this.prefixIcon,
  });

  final String prefixAsset;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: prefixIcon != null
          ? Icon(prefixIcon, size: 22)
          : AuthInputSvgIcon(asset: prefixAsset, size: 22),
    );
  }
}
