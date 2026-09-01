import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:traqtrace_app/core/web/native_web_splash.dart';

/// Idempotent handoff from the OS / HTML splash to Flutter UI.
void dismissNativeSplash() {
  FlutterNativeSplash.remove();
  dismissNativeWebSplash();
}
