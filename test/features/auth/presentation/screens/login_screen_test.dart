import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/data/services/auth_service/auth_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/presentation/screens/login_screen.dart';

class TestAuthService extends AuthService {
  TestAuthService() : super(dioService: DioService());

  LoginRequest? lastLoginRequest;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    lastLoginRequest = request;
    return AuthResponse(
      token: 'test-token',
      type: 'Bearer',
      id: 1,
      username: 'tester',
      email: 'tester@example.com',
      role: 'USER',
    );
  }

  @override
  Future<User> getCurrentUser() async {
    return User(
      id: 1,
      username: 'tester',
      email: 'tester@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: 'USER',
      enabled: true,
    );
  }
}

Widget buildTestApp(AuthCubit authCubit) {
  final router = GoRouter(
    initialLocation: Constants.loginRoute,
    routes: [
      GoRoute(
        path: Constants.loginRoute,
        builder: (context, state) {
          return BlocProvider<AuthCubit>.value(
            value: authCubit,
            child: const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('Home')),
      ),
      GoRoute(
        path: Constants.registerRoute,
        builder: (context, state) => const Scaffold(body: Text('Register')),
      ),
      GoRoute(
        path: Constants.forgotPasswordRoute,
        builder: (context, state) =>
            const Scaffold(body: Text('Forgot Password')),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

void main() {
  group('LoginScreen', () {
    testWidgets('shows updated identifier copy', (tester) async {
      final authService = TestAuthService();
      final authCubit = AuthCubit(authService: authService);

      await tester.pumpWidget(buildTestApp(authCubit));
      await tester.pumpAndSettle();

      expect(find.text('Username or Email'), findsOneWidget);
      expect(find.text('Use your username or email to log in'), findsOneWidget);
    });

    testWidgets('logs in with a username identifier', (tester) async {
      final authService = TestAuthService();
      final authCubit = AuthCubit(authService: authService);

      await tester.pumpWidget(buildTestApp(authCubit));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'warehouse_admin',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();

      final loginButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      loginButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(authService.lastLoginRequest, isNotNull);
      expect(authService.lastLoginRequest!.username, 'warehouse_admin');
      expect(authService.lastLoginRequest!.password, 'password123');
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('logs in with an email identifier', (tester) async {
      final authService = TestAuthService();
      final authCubit = AuthCubit(authService: authService);

      await tester.pumpWidget(buildTestApp(authCubit));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        '  user@example.com  ',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();

      final loginButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      loginButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(authService.lastLoginRequest, isNotNull);
      expect(authService.lastLoginRequest!.username, 'user@example.com');
      expect(authService.lastLoginRequest!.password, 'password123');
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
