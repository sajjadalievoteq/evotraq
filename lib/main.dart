import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:traqtrace_app/core/web/url_strategy_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/url_strategy_web.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:world_countries/world_countries.dart';

import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';

import 'package:traqtrace_app/features/user/cubit/profile_cubit.dart';

import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/utils/app_screen_util.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/core/storage/last_route_store.dart';

import 'package:traqtrace_app/data/services/system_settings_service.dart';
import 'package:traqtrace_app/data/services/profile_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await HiveStorage.init();

    configureUrlStrategy();

    final appConfig = AppConfig(
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080/api',
      ),
      appName: 'traq',
      appVersion: '1.0.0',
    );

    debugPrint('Initializing dependencies...');
    await initDependencies(appConfig);
    getIt.registerSingleton<AppRouter>(
      AppRouter(
        authCubit: getIt<AuthCubit>(),
        lastRouteStore: getIt<LastRouteStore>(),
      ),
    );
    debugPrint('Dependencies initialized.');
    unawaited(getIt<CbvVocabularyService>().hydrateFromCache());

    debugPrint('Starting TraqTraceApp...');
    runApp(const TraqTraceApp());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Initializing WebSocket...');
      try {
        getIt<WebSocketService>().initialize(appConfig.apiBaseUrl, '');
      } catch (e) {
        debugPrint('WebSocket initialization failed: $e');
      }
    });
  } catch (e, stackTrace) {
    debugPrint('FATAL ERROR DURING APP START: $e');
    debugPrint(stackTrace.toString());

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SelectableText(
              'Failed to start application.\n\nError: $e\n\nCheck browser console for more details.',
            ),
          ),
        ),
      ),
    );
  }
}

class TraqTraceApp extends StatelessWidget {
  const TraqTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: getIt<AuthCubit>()),
        BlocProvider<ProfileCubit>(
          create: (context) =>
              ProfileCubit(profileService: getIt<ProfileService>()),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) =>
              ThemeCubit(profileCubit: context.read<ProfileCubit>()),
        ),
        BlocProvider<SystemSettingsCubit>(
          create: (context) =>
              SystemSettingsCubit(getIt<SystemSettingsService>()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        buildWhen: (previous, current) =>
            previous.isDarkMode != current.isDarkMode,
        builder: (context, themeState) {
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.isAuthenticated && state.user != null) {
                context.read<SystemSettingsCubit>().initialize();
              } else if (!state.isAuthenticated) {
                context.read<SystemSettingsCubit>().reset();
              }
            },
            child: MaterialApp.router(
              title: getIt<AppConfig>().appName,
              theme: TraqTheme.light(),
              debugShowCheckedModeBanner: false,
              darkTheme: TraqTheme.dark(),
              themeMode: themeState.themeMode,
              routerConfig: getIt<AppRouter>().router,
              localizationsDelegates: const [
                ...GlobalMaterialLocalizations.delegates,
                TypedLocaleDelegate(),
              ],
              builder: (context, child) => SnackBarInteractionScope(
                child: AppScreenUtilInit(
                  child: AppLayoutBuilder(
                    builder: (context, layout) =>
                        child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
