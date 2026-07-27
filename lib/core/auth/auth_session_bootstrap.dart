import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

/// Runs once at app start so auth settles without routing through `/splash`.
///
/// Splash delay applies only on genuine cold start (`/` or `/splash`). Refresh
/// of a deep link uses no artificial delay so the browser URL stays put.
Future<void> bootstrapAuthSession() async {
  final auth = getIt<AuthCubit>();
  final dio = getIt<DioService>();

  if (auth.state.status != AuthStatus.initial) return;

  await dio.warmAuthTokenFromStorage();

  try {
    await auth.checkAuth(minSplashDelay: _startupSplashDelay());
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

Duration _startupSplashDelay() {
  if (kIsWeb) {
    var path = Uri.base.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    if (path.isEmpty ||
        path == '/' ||
        path == Constants.splashRoute) {
      return const Duration(milliseconds: 1700);
    }
    return Duration.zero;
  }
  // Native cold start always shows splash branding.
  return const Duration(milliseconds: 1700);
}
