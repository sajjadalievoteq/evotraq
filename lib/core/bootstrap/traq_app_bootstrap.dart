import 'dart:async';

import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/navigation/routes/feature_routes_bundle.dart'
    deferred as feature_routes;
import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/splash/screens/splash_screen.dart';
import 'package:traqtrace_app/traq_trace_app.dart';

/// Paints the Flutter splash immediately while storage, DI, and deferred route
/// chunks load. Auth still runs only after [TraqTraceApp] mounts.
class TraqAppBootstrap extends StatefulWidget {
  const TraqAppBootstrap({super.key});

  @override
  State<TraqAppBootstrap> createState() => _TraqAppBootstrapState();
}

class _TraqAppBootstrapState extends State<TraqAppBootstrap> {
  Object? _error;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      await HiveStorage.init();

      final appConfig = AppConfig(
        apiBaseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8080/api',
        ),
        appName: 'traq',
        appVersion: '1.0.0',
      );

      await Future.wait([
        initDependencies(appConfig),
        feature_routes.loadLibrary(),
      ]);

      final appRouter = AppRouter(
        authCubit: getIt<AuthCubit>(),
        featureRoutes: feature_routes.featureRoutes,
      );
      getIt.registerSingleton<AppRouter>(appRouter);
      unawaited(getIt<CbvVocabularyService>().hydrateFromCache());

      if (!mounted) return;
      setState(() {
        _error = null;
        _ready = true;
      });
    } catch (e, stackTrace) {
      debugPrint('FATAL ERROR DURING APP START: $e');
      debugPrint(stackTrace.toString());
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: SelectableText(
              'Failed to start application.\n\nError: $_error\n\n'
              'Check browser console for more details.',
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return MaterialApp(
        theme: TraqTheme.light(),
        darkTheme: TraqTheme.dark(),
        debugShowCheckedModeBanner: false,
        // Hot restart on web keeps the browser URL (e.g. /home) while deferred
        // routes load; route every initial location to splash until GoRouter mounts.
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute<void>(
            builder: (_) => const SplashScreen(),
          ),
        ],
      );
    }

    return const TraqTraceApp();
  }
}
