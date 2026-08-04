import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class AuthInputSvgIcon extends StatelessWidget {
  const AuthInputSvgIcon({
    super.key,
    required this.asset,
    this.size = 22,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
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
}
