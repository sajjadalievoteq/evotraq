import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/auth/auth_response.dart';
import 'package:traqtrace_app/data/models/auth/login_request.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/data/services/auth/auth_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

import 'auth_cubit_test.mocks.dart';

class _RecordingWebSocketService extends WebSocketService {
  int connectCalls = 0;
  int disconnectCalls = 0;

  @override
  void connect() => connectCalls++;

  @override
  void disconnect() => disconnectCalls++;
}

@GenerateMocks([AuthService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late _RecordingWebSocketService socket;

  User testUser() => User(
    id: 1,
    username: 'tester',
    email: 'tester@example.com',
    firstName: 'Test',
    lastName: 'User',
    role: 'USER',
    enabled: true,
  );

  setUp(() async {
    await getIt.reset();
    mockAuthService = MockAuthService();
    socket = _RecordingWebSocketService();
    getIt.registerSingleton<WebSocketService>(socket);
    when(mockAuthService.logout()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('authenticated WebSocket lifecycle', () {
    test(
      'authentication restoration initiates the shared connection',
      () async {
        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => testUser());
        final cubit = AuthCubit(authService: mockAuthService);

        await cubit.checkAuth();

        expect(socket.connectCalls, 1);
        await cubit.close();
      },
    );

    test(
      'successful login reconnects after logout with the new session',
      () async {
        final request = LoginRequest(username: 'tester', password: 'password');
        when(mockAuthService.login(request)).thenAnswer(
          (_) async => AuthResponse(
            token: 'new-token',
            type: 'Bearer',
            id: 1,
            username: 'tester',
            email: 'tester@example.com',
            role: 'USER',
          ),
        );
        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => testUser());
        final cubit = AuthCubit(authService: mockAuthService);

        await cubit.login(request);
        expect(socket.connectCalls, 1);

        await cubit.logout();
        expect(socket.disconnectCalls, greaterThanOrEqualTo(1));

        await cubit.login(request);
        expect(socket.connectCalls, 2);
        await cubit.close();
      },
    );
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
        const AuthState(
          status: AuthStatus.unauthenticated,
          bootstrapCompleted: true,
        ),
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
        const AuthState(
          status: AuthStatus.unauthenticated,
          bootstrapCompleted: true,
        ),
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

      expect(calls, 1);
    });

    test('non-public authenticated 401 notifies callback', () async {
      final dio = DioService();
      dio.resetUnauthorizedGuardsForTest(clearGrace: true);
      var calls = 0;
      dio.onUnauthorized = () => calls++;

      await dio.handleUnauthorized(
        RequestOptions(
          path: '/api/users/profile',
          headers: {'Authorization': 'Bearer real-token'},
        ),
      );

      expect(calls, 1);
    });

    test(
      'non-public tokenless 401 does not notify (startup race guard)',
      () async {
        final dio = DioService();
        dio.resetUnauthorizedGuardsForTest(clearGrace: true);
        var calls = 0;
        dio.onUnauthorized = () => calls++;

        await dio.handleUnauthorized(
          RequestOptions(path: '/api/users/profile'),
        );

        expect(calls, 0);
      },
    );
  });
}
