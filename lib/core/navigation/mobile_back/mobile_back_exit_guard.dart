import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';

/// Double-back-to-exit timing for the home route on mobile.
class MobileBackExitGuard {
  MobileBackExitGuard({
    this.confirmWindow = const Duration(seconds: 2),
    this.message = 'Press back again to exit',
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration confirmWindow;
  final String message;
  final DateTime Function() _now;

  DateTime? _lastPromptAt;

  /// Returns `true` if the app should exit now.
  bool registerPrompt(BuildContext context) {
    final now = _now();
    final last = _lastPromptAt;
    if (last != null && now.difference(last) <= confirmWindow) {
      _lastPromptAt = null;
      return true;
    }

    _lastPromptAt = now;
    context.showInfo(message, duration: confirmWindow);
    return false;
  }

  void reset() => _lastPromptAt = null;

  Future<void> exitApp() => SystemNavigator.pop();
}
