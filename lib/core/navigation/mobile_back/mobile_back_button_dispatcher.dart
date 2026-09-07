import 'package:flutter/widgets.dart';
import 'package:traqtrace_app/core/navigation/mobile_back/mobile_back_handler.dart';
import 'package:traqtrace_app/core/navigation/mobile_back/mobile_back_platform.dart';

/// Intercepts the OS back button before GoRouter can report "unhandled"
/// (which finishes the Android activity on a single-page stack).
class MobileBackButtonDispatcher extends RootBackButtonDispatcher {
  MobileBackButtonDispatcher(this._handler);

  final MobileBackHandler _handler;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    if (!isIosOrAndroidApp) {
      return super.invokeCallback(defaultValue);
    }

    final handled = await _handler.handle();
    if (handled) return true;

    return super.invokeCallback(defaultValue);
  }
}
