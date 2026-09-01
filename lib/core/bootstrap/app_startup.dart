import 'dart:async';

import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/config/platform_startup_route.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/navigation/routes/feature_routes_bundle.dart'
    deferred as feature_routes;
import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

Future<void> initializeApplication({required String startupRoute}) async {
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
    initialLocation: resolveRouterInitialLocation(startupRoute),
  );
  getIt.registerSingleton<AppRouter>(appRouter);
  unawaited(getIt<CbvVocabularyService>().hydrateFromCache());
}