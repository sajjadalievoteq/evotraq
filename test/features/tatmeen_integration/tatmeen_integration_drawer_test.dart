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
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit_session.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockThemeCubit extends MockCubit<ThemeState> implements ThemeCubit {}

class _MockSystemSettingsCubit extends MockCubit<SystemSettingsState>
    implements SystemSettingsCubit {}

void main() {
  Future<void> pumpDrawer(
    WidgetTester tester, {
    required AuthState authState,
    required GoRouter router,
  }) async {
    final authCubit = _MockAuthCubit();
    final themeCubit = _MockThemeCubit();
    final settingsCubit = _MockSystemSettingsCubit();

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
  }

  testWidgets('admin sees Tatmeen Integration below Automation Center', (
    tester,
  ) async {
    final authState = AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: 1,
        username: 'admin',
        email: 'admin@traqtrace.com',
        firstName: 'Admin',
        lastName: 'User',
        role: 'ADMIN',
        enabled: true,
      ),
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
          path: Constants.tatmeenIntegrationRoute,
          builder: (context, state) =>
              const Scaffold(body: Text('Tatmeen Screen')),
        ),
      ],
    );

    await pumpDrawer(tester, authState: authState, router: router);

    final scrollable = find.descendant(
      of: find.byType(Drawer),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Automation Center'),
      120,
      scrollable: scrollable,
    );
    await tester.scrollUntilVisible(
      find.text('Tatmeen Integration'),
      120,
      scrollable: scrollable,
    );

    final automation = find.text('Automation Center');
    final tatmeen = find.text('Tatmeen Integration');
    expect(automation, findsOneWidget);
    expect(tatmeen, findsOneWidget);
    expect(
      tester.getTopLeft(tatmeen).dy,
      greaterThan(tester.getTopLeft(automation).dy),
    );
  });

  testWidgets('unauthorized user does not see Tatmeen Integration tile', (
    tester,
  ) async {
    final authState = AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: 2,
        username: 'plain',
        email: 'plain@traqtrace.com',
        firstName: 'Plain',
        lastName: 'User',
        role: 'USER',
        enabled: true,
      ),
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
      ],
    );

    await pumpDrawer(tester, authState: authState, router: router);
    expect(find.text('Tatmeen Integration'), findsNothing);
  });

  testWidgets('manufacturer can navigate to Tatmeen Integration route', (
    tester,
  ) async {
    final authState = AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: 3,
        username: 'maker',
        email: 'maker@traqtrace.com',
        firstName: 'Maker',
        lastName: 'User',
        role: 'MANUFACTURER',
        enabled: true,
      ),
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
          path: Constants.tatmeenIntegrationRoute,
          builder: (context, state) =>
              const Scaffold(body: Text('Tatmeen Screen')),
        ),
      ],
    );

    await pumpDrawer(tester, authState: authState, router: router);

    final scrollable = find.descendant(
      of: find.byType(Drawer),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Tatmeen Integration'),
      120,
      scrollable: scrollable,
    );

    expect(find.text('Tatmeen Integration'), findsOneWidget);
    await tester.tap(find.text('Tatmeen Integration'));
    await tester.pumpAndSettle();
    expect(find.text('Tatmeen Screen'), findsOneWidget);
  });
}
