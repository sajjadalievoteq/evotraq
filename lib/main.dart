import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:traqtrace_app/core/auth/auth_session_bootstrap.dart';
import 'package:traqtrace_app/core/bootstrap/app_startup.dart';
import 'package:traqtrace_app/core/config/platform_startup_route.dart';
import 'package:traqtrace_app/core/web/url_strategy_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/url_strategy_web.dart';
import 'package:traqtrace_app/features/splash/native_splash_dismiss.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/traq_trace_app.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }
  configureUrlStrategy();
  final startupRoute = resolvePlatformStartupRoute();

  try {
    await initializeApplication(startupRoute: startupRoute);
    final initialIsDarkMode = await ThemeCubit.loadThemePreference();
    // Show the branded Flutter splash immediately, then resolve the session
    // while it remains visible. That screen removes the native launch layer.
    runApp(TraqTraceApp(initialIsDarkMode: initialIsDarkMode));
    await bootstrapAuthSession();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'application startup',
      ),
    );
    runApp(_StartupFailureApp(error: error));
    WidgetsBinding.instance.addPostFrameCallback((_) => dismissNativeSplash());
  }
}

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'Failed to start application.\n\n$error\n\n'
              'Check the application logs for more details.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
