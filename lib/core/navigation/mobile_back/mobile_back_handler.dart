import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_navigation.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/navigation/mobile_back/mobile_back_exit_guard.dart';
import 'package:traqtrace_app/core/navigation/mobile_back/mobile_back_platform.dart';

/// Shared back-navigation rules for iOS/Android (used by the root dispatcher).
class MobileBackHandler {
  MobileBackHandler({
    required this.router,
    MobileBackExitGuard? exitGuard,
  }) : _exitGuard = exitGuard ?? MobileBackExitGuard();

  final GoRouter router;
  final MobileBackExitGuard _exitGuard;

  /// Returns `true` when the event was consumed and the OS must not exit.
  Future<bool> handle() async {
    if (!isIosOrAndroidApp) return false;

    // Prefer GoRouter's stack so we never pop the shell container by mistake.
    if (router.canPop()) {
      router.pop();
      _exitGuard.reset();
      return true;
    }

    final path = router.routerDelegate.currentConfiguration.uri.path;
    if (_isHomePath(path)) {
      final context = rootNavigatorKey.currentContext;
      if (context == null || !context.mounted) return true;
      final shouldExit = _exitGuard.registerPrompt(context);
      if (shouldExit) {
        await _exitGuard.exitApp();
      }
      return true;
    }

    if (_shouldReturnToHome(path)) {
      _exitGuard.reset();
      router.go(Constants.homeRoute);
      return true;
    }

    // Splash / auth: allow the platform to finish the activity.
    return false;
  }

  bool _isHomePath(String path) =>
      path == Constants.homeRoute || path == '${Constants.homeRoute}/';

  bool _shouldReturnToHome(String path) {
    if (_isHomePath(path)) return false;
    if (path.isEmpty || path == '/') return false;
    if (path == Constants.splashRoute) return false;
    if (path == Constants.loginRoute ||
        path == Constants.registerRoute ||
        path == Constants.checkEmailRoute ||
        path == Constants.forgotPasswordRoute ||
        path == Constants.resetPasswordRoute ||
        path == Constants.authResetPasswordRoute ||
        path == Constants.verifyEmailRoute ||
        path == Constants.verifyEmailAliasRoute) {
      return false;
    }
    return true;
  }
}
