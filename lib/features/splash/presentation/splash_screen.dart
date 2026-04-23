import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

import '../../../core/config/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthCubit>().checkAuth();
    });
  }

  void _go(String location) {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go(location);
  }

  String? _resolvePendingLocation(BuildContext context) {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    if (from == null || from.isEmpty || from ==  Constants.splashRoute) {
      return null;
    }

    final parsed = Uri.tryParse(from);
    if (parsed == null || parsed.path ==  Constants.splashRoute) {
      return null;
    }

    return parsed.toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(Constants.iconImage), context);
  }

  @override
  Widget build(BuildContext context) {
    final primary = ColorManager.primary(context);
    final pendingLocation = _resolvePendingLocation(context);

    return Scaffold(
      backgroundColor: ColorManager.background(context),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              _go(pendingLocation ?? Constants.homeRoute);
            } else if (state.status == AuthStatus.unauthenticated) {
              _go(Constants.loginRoute);
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Image.asset(
                      Constants.iconImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'evotraq.io',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Preparing your workspace...',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorManager.textSecondary(context).withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        backgroundColor: ColorManager.primaryTrack(context),
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
