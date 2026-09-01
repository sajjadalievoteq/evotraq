import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:traqtrace_app/core/web/url_strategy_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/url_strategy_web.dart';
import 'package:traqtrace_app/traq_trace_app.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Web hot-restart removes the HTML splash immediately; deferring the first
  // Flutter frame with nothing underneath causes a blank white screen.
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }
  configureUrlStrategy();
  runApp(const TraqTraceApp());
}
