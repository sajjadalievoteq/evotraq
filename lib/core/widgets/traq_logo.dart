import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class TraqLogo extends StatelessWidget {
  const TraqLogo({
    super.key,
    required this.size,
    this.assetPath = AppAssets.logo,
  });

  final double size;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return TraqIcon(
            AppAssets.iconBrokenImage,
            size: size * 0.7,
            color: c.primary,
          );
        },
      ),
    );
  }
}
