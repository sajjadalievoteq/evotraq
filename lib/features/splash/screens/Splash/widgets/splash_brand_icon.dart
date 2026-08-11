import 'package:flutter/material.dart';
export 'splash_brand_icon_tilt.dart';
import 'package:traqtrace_app/features/splash/screens/Splash/widgets/splash_brand_icon_tilt.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SplashBrandIcon extends StatelessWidget {
  const SplashBrandIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          AppAssets.logo,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return TraqIcon(
              AppAssets.iconBrokenImage,
              size: size * 0.7,
              color: c.primary,
            );
          },
        ),
      ),
    );
  }
}

/// Subtle looping lean: tilt clockwise on [Alignment.bottomRight], then settle.
