import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';
import 'package:traqtrace_app/features/splash/screens/Splash/utils/splash_navigation_utils.dart';
import 'package:traqtrace_app/features/splash/screens/Splash/widgets/splash_content.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;
  bool _initialized = false;
  bool _canNavigate = false;
  bool _assetsReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _precacheAndInit();
    }
  }

  Future<void> _precacheAndInit() async {
    await Future.wait([
      precacheImage(const AssetImage(AppAssets.traqBackgroundPng), context)
          .catchError((_) {}),
      precacheImage(const AssetImage(AppAssets.logo), context)
          .catchError((_) {}),
    ]);

    if (!mounted) return;
    setState(() => _assetsReady = true);

    await _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authCubit = context.read<AuthCubit>();
    final authCheck = authCubit.checkAuth();
    final minDelay = Future.delayed(const Duration(seconds: 2));

    try {
      await Future.wait([authCheck, minDelay])
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Auth check took too long or failed: $e');
    } finally {
      // Guarantee a terminal auth state so the router never stays on splash.
      final status = authCubit.state.status;
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        await authCubit.sessionExpired();
      }
      if (mounted) {
        setState(() => _canNavigate = true);
        _checkAndNavigate(authCubit.state);
      }
    }
  }

  void _checkAndNavigate(AuthState state) {
    if (!_canNavigate || _navigated || !mounted) return;

    final pendingLocation = resolveSplashPendingLocation(context);
    if (state.status == AuthStatus.authenticated) {
      _go(pendingLocation ?? Constants.homeRoute);
    } else if (state.status == AuthStatus.unauthenticated) {
      _go(Constants.loginRoute);
    }
  }

  void _go(String location) {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go(location);
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
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) => _checkAndNavigate(state),
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
