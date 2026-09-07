import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_background_texture.dart';
import 'package:traqtrace_app/features/splash/native_splash_colors.dart';
import 'package:traqtrace_app/features/splash/native_splash_dismiss.dart';

/// Branded startup screen shown while the initial session is resolved.
class TraqSplashScreen extends StatefulWidget {
  const TraqSplashScreen({super.key});

  @override
  State<TraqSplashScreen> createState() => _TraqSplashScreenState();
}

class _TraqSplashScreenState extends State<TraqSplashScreen> {
  static const double _lockupMaxWidth = 280;
  static const double _lockupWidthFraction = 0.55;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => dismissNativeSplash());
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final background = NativeSplashColors.forBrightness(brightness);
    final lockup = brightness == Brightness.dark
        ? AppAssets.splashLockupDark
        : AppAssets.splashLockupLight;

    return ColoredBox(
      color: background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const TraqBackgroundTexture(),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth * _lockupWidthFraction)
                    .clamp(120.0, _lockupMaxWidth)
                    .toDouble();
                return Image.asset(
                  lockup,
                  width: width,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  semanticLabel: 'traq by EVOTEQ',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
