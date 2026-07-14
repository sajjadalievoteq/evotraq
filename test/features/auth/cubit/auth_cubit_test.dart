import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/data/services/auth_service/auth_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

import 'auth_cubit_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;

  User testUser() => User(
        id: 1,
        username: 'tester',
        email: 'tester@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'USER',
        enabled: true,
      );

  setUp(() {
    mockAuthService = MockAuthService();
    when(mockAuthService.logout()).thenAnswer((_) async {});
  });

  group('AuthCubit.sessionExpired', () {
    blocTest<AuthCubit, AuthState>(
      'emits unauthenticated and clears session',
      build: () => AuthCubit(authService: mockAuthService),
      seed: () => AuthState(
        status: AuthStatus.authenticated,
        user: testUser(),
        token: 'tok',
      ),
      act: (cubit) => cubit.sessionExpired(),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated),
      ],
      verify: (_) {
        verify(mockAuthService.logout()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'is idempotent when already unauthenticated',
      build: () => AuthCubit(authService: mockAuthService),
      seed: () => const AuthState(status: AuthStatus.unauthenticated),
      act: (cubit) => cubit.sessionExpired(),
      expect: () => <AuthState>[],
      verify: (_) {
        verifyNever(mockAuthService.logout());
      },
    );
  });

  group('AuthCubit.checkAuth timeout', () {
    blocTest<AuthCubit, AuthState>(
      'auth-check timeout ends in unauthenticated',
      build: () {
        when(mockAuthService.getCurrentUser()).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(seconds: 30));
          return testUser();
        });
        return AuthCubit(
          authService: mockAuthService,
          authCheckTimeout: const Duration(milliseconds: 50),
        );
      },
      act: (cubit) => cubit.checkAuth(),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );
  });

  group('DioService.onUnauthorized', () {
    test('invokes onUnauthorized once for parallel 401 notifications', () {
      final dio = DioService();
      dio.resetUnauthorizedDebounceForTest();
      var calls = 0;
      dio.onUnauthorized = () => calls++;

      dio.notifyUnauthorizedDebounced();
      dio.notifyUnauthorizedDebounced();
      dio.notifyUnauthorizedDebounced();

      expect(calls, 1);

      final publicOptions = RequestOptions(path: '/auth/login');
      expect(
        () async => dio.handleUnauthorized(publicOptions),
        returnsNormally,
      );
      // Public auth path must not notify again within debounce either;
      // handleUnauthorized returns early before notify.
      expect(calls, 1);
    });

    test('non-public handleUnauthorized notifies callback', () async {
      final dio = DioService();
      dio.resetUnauthorizedDebounceForTest();
      var calls = 0;
      dio.onUnauthorized = () => calls++;

      await dio.handleUnauthorized(
        RequestOptions(path: '/api/users/profile'),
      );

      expect(calls, 1);
    });
  });
}
