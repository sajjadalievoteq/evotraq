import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';

import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import '../../../core/config/constants.dart';

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
      // Precache images first — before any other async work — so the
      // background and logo are in the image cache when _assetsReady flips
      // to true and CardWithBackgroundWidget / Image.asset first render.
      _precacheAndInit();
    }
  }

  Future<void> _precacheAndInit() async {
    // Precache both assets before revealing the splash UI.
    await Future.wait([
      precacheImage(const AssetImage(AppAssets.traqBackgroundPng), context)
          .catchError((_) {}),
      precacheImage(const AssetImage(AppAssets.logo), context)
          .catchError((_) {}),
    ]);

    if (!mounted) return;
    setState(() => _assetsReady = true);

    // Now kick off auth + vocabulary + minimum display time in parallel.
    await _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authCheck = context.read<AuthCubit>().checkAuth();
    final minDelay = Future.delayed(const Duration(seconds: 2));

    try {
      await Future.wait([
        authCheck,
        context.read<CbvVocabularyCubit>().loadVocabulary(),
        minDelay,
      ]).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Auth check or vocabulary load took too long or failed: $e');
    } finally {
      if (mounted) {
        setState(() => _canNavigate = true);
        final authState = context.read<AuthCubit>().state;
        _checkAndNavigate(authState);
      }
    }
  }

  void _checkAndNavigate(AuthState state) {
    if (!_canNavigate || _navigated || !mounted) return;

    final pendingLocation = _resolvePendingLocation(context);
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

  String? _resolvePendingLocation(BuildContext context) {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    if (from == null || from.isEmpty || from == Constants.splashRoute) {
      return null;
    }

    final parsed = Uri.tryParse(from);
    if (parsed == null || parsed.path == Constants.splashRoute) {
      return null;
    }

    return parsed.toString();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final primary = c.primary;
    final size = MediaQuery.sizeOf(context);
    final displayHeight = size.height > 0 ? size.height : 800.0;

    // Before assets are in the image cache, render a plain background that
    // matches the card so there is no visible first-frame flash.
    if (!_assetsReady) {
      return Scaffold(backgroundColor: c.background, body: const SizedBox.expand());
    }

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) => _checkAndNavigate(state),
          child: CardWithBackgroundWidget(
            isPrimary: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: displayHeight * 0.1,
                      height: displayHeight * 0.1,
                      child: Image.asset(
                        AppAssets.logo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return TraqIcon(
                            AppAssets.iconBrokenImage,
                            size: 64,
                            color: primary,
                          );
                        },
                      ),
                    ),
                    Text(
                      'traq',
                      style: TextStyle(
                        height: 0,
                        fontSize: displayHeight * 0.08,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: primary,
                      ),
                    ),
                    Text(
                      'Preparing your workspace...',
                      style: TextStyle(
                        fontSize: 14,
                        color: c.textSecondary.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: 22),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: primary.withOpacity(
                            Theme.of(context).brightness == Brightness.dark
                                ? 0.18
                                : 0.12,
                          ),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
