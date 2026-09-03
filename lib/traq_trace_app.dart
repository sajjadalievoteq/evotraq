import 'package:traqtrace_app/core/layout/app_layout_builder.dart';
import 'package:traqtrace_app/core/widgets/snack_bar_interaction_scope.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_typography.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';

import 'package:traqtrace_app/features/auth/widgets/session_activity_listener.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

import 'package:traqtrace_app/features/user/cubit/profile_cubit.dart';

import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/utils/app_screen_util.dart';

import 'package:traqtrace_app/core/di/injection.dart';

import 'package:traqtrace_app/data/services/admin/system_settings_service.dart';
import 'package:traqtrace_app/data/services/auth/auth_service.dart';
import 'package:traqtrace_app/data/services/profile_service.dart';

import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

class TraqTraceApp extends StatelessWidget {
  const TraqTraceApp({super.key, required this.initialIsDarkMode});

  final bool initialIsDarkMode;

  @override
  Widget build(BuildContext context) {
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
          create: (context) => ThemeCubit(
            profileCubit: context.read<ProfileCubit>(),
            initialIsDarkMode: initialIsDarkMode,
          ),
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
              builder: (context, child) => DefaultTextHeightBehavior(
                textHeightBehavior: TraqText.heightBehavior,
                child: SnackBarInteractionScope(
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
            ),
          );
        },
      ),
    );
  }
}
