import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/models/system_settings_model.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockThemeCubit extends MockCubit<ThemeState> implements ThemeCubit {}

class _MockSystemSettingsCubit extends MockCubit<SystemSettingsState>
    implements SystemSettingsCubit {}

void main() {
  testWidgets(
    'Product Hierarchy tile appears under Inbox/Outbox and navigates',
    (tester) async {
      final authCubit = _MockAuthCubit();
      final themeCubit = _MockThemeCubit();
      final settingsCubit = _MockSystemSettingsCubit();

      final authState = AuthState(
        status: AuthStatus.authenticated,
        user: User(
          id: 1,
          username: 'tester',
          email: 'tester@traqtrace.com',
          firstName: 'Test',
          lastName: 'User',
          role: 'USER',
          enabled: true,
        ),
      );
      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.value(authState),
        initialState: authState,
      );

      const themeState = ThemeState(isDarkMode: false);
      when(() => themeCubit.state).thenReturn(themeState);
      whenListen(
        themeCubit,
        const Stream<ThemeState>.empty(),
        initialState: themeState,
      );

      final systemState = SystemSettingsState(
        settings: SystemSettings.defaults(),
        isInitialized: true,
      );
      when(() => settingsCubit.state).thenReturn(systemState);
      whenListen(
        settingsCubit,
        const Stream<SystemSettingsState>.empty(),
        initialState: systemState,
      );

      final router = GoRouter(
        initialLocation: Constants.homeRoute,
        routes: [
          GoRoute(
            path: Constants.homeRoute,
            builder: (context, state) => Scaffold(
              appBar: AppBar(),
              drawer: const AppDrawer(),
              body: const Text('Home'),
            ),
          ),
          GoRoute(
            path: Constants.productHierarchyRoute,
            builder: (context, state) =>
                const Scaffold(body: Text('Product Hierarchy Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<SystemSettingsCubit>.value(value: settingsCubit),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            theme: TraqTheme.light(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      final ioTile = find.text('Inbox / Outbox');
      final hierarchyTile = find.text('Product Hierarchy');
      expect(ioTile, findsOneWidget);
      expect(hierarchyTile, findsOneWidget);
      expect(
        tester.getTopLeft(hierarchyTile).dy,
        greaterThan(tester.getTopLeft(ioTile).dy),
      );

      await tester.tap(hierarchyTile);
      await tester.pumpAndSettle();

      expect(find.text('Product Hierarchy Screen'), findsOneWidget);
    },
  );
}
