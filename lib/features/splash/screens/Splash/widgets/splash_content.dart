import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_staggered_entrance.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/splash/screens/Splash/widgets/splash_brand_icon.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({
    super.key,
    required this.iconSize,
    required this.logoSize,
  });

  final double iconSize;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    return TraqStaggeredEntrance(
      slide: TraqEntranceSlide.up,
      duration: TraqAnimationConstants.splashEntrance,
      stagger: TraqAnimationConstants.splashStagger,
      risePx: TraqAnimationConstants.splashRisePx,
      beginScale: TraqAnimationConstants.splashInitialScale,
      children: [
        Align(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SplashBrandIconTilt(
              child: SplashBrandIcon(size: iconSize),
            ),
          ),
        ),
        Align(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'traq',
              style: t.h1.copyWith(
                fontSize: logoSize + 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                height: 1.0,
                color: c.primary,
              ),
            ),
          ),
        ),
        Align(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 36),
            child: Text(
              'Preparing your workspace…',
              textAlign: TextAlign.center,
              style: t.bodySm.copyWith(
                fontSize: 16,
                letterSpacing: 0.15,
                color: c.textMuted,
                height: 1.35,
              ),
            ),
          ),
        ),

      ],
    );
  }
}
