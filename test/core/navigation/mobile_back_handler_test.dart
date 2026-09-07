import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_navigation.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/navigation/mobile_back/mobile_back_exit_guard.dart';
import 'package:traqtrace_app/core/navigation/mobile_back/mobile_back_handler.dart';
import 'package:traqtrace_app/core/widgets/snack_bar_interaction_scope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoRouter router;
  late MobileBackHandler handler;
  var now = DateTime(2026, 1, 1, 12);

  setUp(() {
    now = DateTime(2026, 1, 1, 12);
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: Constants.homeRoute,
      routes: [
        GoRoute(
          path: Constants.homeRoute,
          builder: (_, __) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const Scaffold(body: Text('profile')),
        ),
        GoRoute(
          path: Constants.loginRoute,
          builder: (_, __) => const Scaffold(body: Text('login')),
        ),
      ],
    );
    handler = MobileBackHandler(
      router: router,
      exitGuard: MobileBackExitGuard(now: () => now),
    );
  });

  tearDown(() => router.dispose());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => SnackBarInteractionScope(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('on home, first back is consumed without exiting', (tester) async {
    await pumpApp(tester);
    expect(await handler.handle(), isTrue);
    expect(router.state.uri.path, Constants.homeRoute);
  });

  testWidgets('from profile with empty stack, back goes home', (tester) async {
    await pumpApp(tester);
    router.go('/profile');
    await tester.pumpAndSettle();

    expect(await handler.handle(), isTrue);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Constants.homeRoute);
  });

  testWidgets('pushed route is popped before home logic', (tester) async {
    await pumpApp(tester);
    router.push('/profile');
    await tester.pumpAndSettle();

    expect(await handler.handle(), isTrue);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Constants.homeRoute);
  });

  testWidgets('auth routes are not redirected to home', (tester) async {
    await pumpApp(tester);
    router.go(Constants.loginRoute);
    await tester.pumpAndSettle();

    expect(await handler.handle(), isFalse);
    expect(router.state.uri.path, Constants.loginRoute);
  });
}
