import 'dart:js' as js;

/// Removes the `flutter_native_splash` HTML overlay from `web/index.html`.
void dismissNativeWebSplash() {
  try {
    js.context.callMethod('removeSplashFromWeb');
  } catch (_) {}
}
