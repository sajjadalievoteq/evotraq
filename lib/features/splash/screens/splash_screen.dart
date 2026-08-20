import 'dart:async';

import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';
import 'package:traqtrace_app/features/splash/screens/widgets/splash_content.dart';

/// Cold-start branding only. Auth bootstrap runs at app level so deep-link
/// refresh never routes through this screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initialized = false;
  bool _assetsReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      unawaited(_precacheAssets());
    }
  }

  Future<void> _precacheAssets() async {
    await Future.wait([
      precacheImage(const AssetImage(AppAssets.traqBackgroundPng), context)
          .catchError((_) {}),
      precacheImage(const AssetImage(AppAssets.logo), context)
          .catchError((_) {}),
    ]);

    if (!mounted) return;
    setState(() => _assetsReady = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final size = MediaQuery.sizeOf(context);
    final displayHeight = size.height > 0 ? size.height : 800.0;
    final iconSize = (displayHeight * 0.1).clamp(64.0, 88.0);
    final logoSize = (displayHeight * 0.055).clamp(40.0, 52.0);

    if (!_assetsReady) {
      return Scaffold(
        backgroundColor: c.background,
        body: const SizedBox.expand(),
      );
    }

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: CardWithBackgroundWidget(
          isPrimary: false,
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SplashContent(
                iconSize: iconSize,
                logoSize: logoSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
