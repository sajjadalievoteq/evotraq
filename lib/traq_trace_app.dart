import 'package:traqtrace_app/core/layout/app_layout_builder.dart';
import 'package:traqtrace_app/core/widgets/snack_bar_interaction_scope.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:traqtrace_app/core/config/platform_startup_route.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';

import 'package:traqtrace_app/features/auth/widgets/session_activity_listener.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

import 'package:traqtrace_app/features/user/cubit/profile_cubit.dart';

import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/utils/app_screen_util.dart';

import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/splash/screens/splash_screen.dart';

import 'package:traqtrace_app/data/services/admin/system_settings_service.dart';
import 'package:traqtrace_app/data/services/auth/auth_service.dart';
import 'package:traqtrace_app/data/services/profile_service.dart';

import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

class TraqTraceApp extends StatefulWidget {
  const TraqTraceApp({super.key});

  @override
  State<TraqTraceApp> createState() => _TraqTraceAppState();
}

class _TraqTraceAppState extends State<TraqTraceApp> {
  Object? _error;
  bool _initReady = false;

  /// Captured synchronously so async init cannot lose the browser URL on reload.
  late final String _startupRoute = resolvePlatformStartupRoute();

  void _onBootstrapReady() {
    if (!mounted) return;
    setState(() => _initReady = true);
  }

  void _onBootstrapError(Object error, StackTrace stackTrace) {
    debugPrint('FATAL ERROR DURING APP START: $error');
    debugPrint(stackTrace.toString());
    if (!mounted) return;
    setState(() => _error = error);
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

    if (!_initReady) {
      return MaterialApp(
        theme: TraqTheme.light(),
        darkTheme: TraqTheme.dark(),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          startupRoute: _startupRoute,
          onReady: _onBootstrapReady,
          onError: _onBootstrapError,
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: getIt<AuthCubit>()),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileService: getIt<ProfileService>(),
            authService: getIt<AuthService>(),
          ),
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
              ],
              builder: (context, child) => SnackBarInteractionScope(
                child: SessionActivityListener(
                  child: AppScreenUtilInit(
                    child: AppLayoutBuilder(
                      builder: (context, layout) =>
                          child ?? const SizedBox.shrink(),
                    ),
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
