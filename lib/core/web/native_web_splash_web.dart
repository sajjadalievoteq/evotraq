import 'dart:js' as js;

void dismissNativeWebSplash() {
  try {
    js.context.callMethod('removeSplashFromWeb');
  } catch (_) {}
}