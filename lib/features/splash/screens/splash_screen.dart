import 'dart:async';

import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/auth/auth_session_bootstrap.dart';
import 'package:traqtrace_app/core/bootstrap/app_startup.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';
import 'package:traqtrace_app/features/splash/native_splash_dismiss.dart';
import 'package:traqtrace_app/features/splash/screens/widgets/splash_content.dart';
import 'package:traqtrace_app/features/splash/splash_assets.dart';

/// The only animated branding splash. Runs Hive/DI and auth bootstrap when
/// [startupRoute] and [onReady] are provided, then hands off to [GoRouter].
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.startupRoute,
    this.onReady,
    this.onError,
  });

  final String? startupRoute;
  final VoidCallback? onReady;

  final void Function(Object error, StackTrace stackTrace)? onError;

  bool get _bootstrapsApp => startupRoute != null && onReady != null;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _warmupStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => dismissNativeSplash());
    if (widget._bootstrapsApp) {
      unawaited(_bootstrap());
    }
  }

  Future<void> _bootstrap() async {
    try {
      await initializeApplication(startupRoute: widget.startupRoute!);
      await bootstrapAuthSession();
      if (!mounted) return;
      widget.onReady!();
    } catch (error, stackTrace) {
      widget.onError?.call(error, stackTrace);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_warmupStarted) {
      _warmupStarted = true;
      unawaited(precacheSplashAssets(context).catchError((_) {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final size = MediaQuery.sizeOf(context);
    final displayHeight = size.height > 0 ? size.height : 800.0;
    final iconSize = (displayHeight * 0.1).clamp(64.0, 88.0);
    final logoSize = (displayHeight * 0.055).clamp(40.0, 52.0);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SizedBox.expand(
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
      ),
    );
  }
}
