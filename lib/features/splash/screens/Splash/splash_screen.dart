import 'dart:async';

import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';
import 'package:traqtrace_app/features/splash/screens/Splash/widgets/splash_content.dart';






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
      unawaited(_runStartupAuthCheck());
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

  
  
  
  
  
  Future<void> _runStartupAuthCheck() async {
    final auth = getIt<AuthCubit>();
    final dio = getIt<DioService>();

    
    if (auth.state.status != AuthStatus.initial) return;

    
    await dio.warmAuthTokenFromStorage();

    try {
      
      await auth.checkAuth(
        minSplashDelay: const Duration(milliseconds: 1700),
      );
    } catch (e) {
      debugPrint('Startup checkAuth failed: $e');
    }

    
    final status = auth.state.status;
    if (status == AuthStatus.initial || status == AuthStatus.loading) {
      await auth.sessionExpired();
    }

    
    if (auth.state.isAuthenticated) {
      dio.markAuthSettled();
    }
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
