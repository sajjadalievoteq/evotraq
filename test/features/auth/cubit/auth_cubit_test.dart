import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
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

String buildJwt({required DateTime expUtc}) {
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode(jsonEncode({'exp': expUtc.millisecondsSinceEpoch ~/ 1000})),
  );
  return '$header.$payload.sig';
}

@GenerateMocks([AuthService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late _RecordingWebSocketService socket;
  late TokenManager tokenManager;

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
    tokenManager = TokenManager();
    socket = _RecordingWebSocketService();
    getIt.registerSingleton<WebSocketService>(socket);
    when(mockAuthService.logout()).thenAnswer((_) async {});
    when(
      mockAuthService.getAuthToken(),
    ).thenAnswer((_) async => 'opaque-token');
  });

  tearDown(() async {
    await getIt.reset();
  });

  AuthCubit buildCubit() =>
      AuthCubit(authService: mockAuthService, tokenManager: tokenManager);

  group('authenticated WebSocket lifecycle', () {
    test(
      'authentication restoration initiates the shared connection',
      () async {
        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => testUser());
        final cubit = buildCubit();

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
        final cubit = buildCubit();

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
      build: buildCubit,
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
      build: buildCubit,
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
          tokenManager: tokenManager,
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

  group('JWT expiry timer', () {
    test(
      'Scenario A — timer expiry clears session and disconnects WS',
      () async {
        final token = buildJwt(
          expUtc: DateTime.now().toUtc().add(
            TokenManager.tokenExpirySafetyMargin + const Duration(seconds: 2),
          ),
        );
        final request = LoginRequest(username: 'tester', password: 'password');
        when(mockAuthService.login(request)).thenAnswer(
          (_) async => AuthResponse(
            token: token,
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

        final cubit = buildCubit();
        await cubit.login(request);

        expect(cubit.state.status, AuthStatus.authenticated);
        expect(cubit.hasTokenExpiryTimerForTest, isTrue);
        expect(socket.connectCalls, 1);

        await Future<void>.delayed(const Duration(seconds: 3));

        expect(cubit.state.status, AuthStatus.unauthenticated);
        expect(cubit.hasTokenExpiryTimerForTest, isFalse);
        expect(socket.disconnectCalls, greaterThanOrEqualTo(1));
        verify(mockAuthService.logout()).called(greaterThanOrEqualTo(1));
        await cubit.close();
      },
    );

    test(
      'Scenario B — checkAuth rebuilds remaining timer for valid JWT',
      () async {
        final token = buildJwt(
          expUtc: DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        when(mockAuthService.getAuthToken()).thenAnswer((_) async => token);
        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => testUser());

        final cubit = buildCubit();
        await cubit.checkAuth();

        expect(cubit.state.status, AuthStatus.authenticated);
        expect(cubit.hasTokenExpiryTimerForTest, isTrue);
        expect(cubit.scheduledExpiryTokenForTest, token);
        await cubit.close();
      },
    );

    test('Scenario C — checkAuth rejects already-expired stored JWT', () async {
      final token = buildJwt(
        expUtc: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      );
      when(mockAuthService.getAuthToken()).thenAnswer((_) async => token);

      final cubit = buildCubit();
      await cubit.checkAuth();

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.hasTokenExpiryTimerForTest, isFalse);
      verifyNever(mockAuthService.getCurrentUser());
      verify(mockAuthService.logout()).called(1);
      await cubit.close();
    });

    test('Scenario D — manual logout cancels expiry timer', () async {
      final token = buildJwt(
        expUtc: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
      final request = LoginRequest(username: 'tester', password: 'password');
      when(mockAuthService.login(request)).thenAnswer(
        (_) async => AuthResponse(
          token: token,
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

      final cubit = buildCubit();
      await cubit.login(request);
      expect(cubit.hasTokenExpiryTimerForTest, isTrue);

      await cubit.logout();

      expect(cubit.hasTokenExpiryTimerForTest, isFalse);
      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(socket.disconnectCalls, greaterThanOrEqualTo(1));
      await cubit.close();
    });

    test(
      'Scenario E — re-login cancels Token A timer before Token B',
      () async {
        final tokenA = buildJwt(
          expUtc: DateTime.now().toUtc().add(
            TokenManager.tokenExpirySafetyMargin + const Duration(seconds: 2),
          ),
        );
        final tokenB = buildJwt(
          expUtc: DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        final request = LoginRequest(username: 'tester', password: 'password');

        var loginCount = 0;
        when(mockAuthService.login(request)).thenAnswer((_) async {
          loginCount += 1;
          return AuthResponse(
            token: loginCount == 1 ? tokenA : tokenB,
            type: 'Bearer',
            id: 1,
            username: 'tester',
            email: 'tester@example.com',
            role: 'USER',
          );
        });
        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => testUser());

        final cubit = buildCubit();
        await cubit.login(request);
        expect(cubit.scheduledExpiryTokenForTest, tokenA);

        await cubit.logout();
        await cubit.login(request);
        expect(cubit.scheduledExpiryTokenForTest, tokenB);
        expect(cubit.state.status, AuthStatus.authenticated);

        await Future<void>.delayed(const Duration(seconds: 3));

        expect(cubit.state.status, AuthStatus.authenticated);
        expect(cubit.scheduledExpiryTokenForTest, tokenB);
        await cubit.close();
      },
    );

    test(
      'Scenario F — early backend 401 cancels timer via sessionExpired',
      () async {
        final token = buildJwt(
          expUtc: DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        final request = LoginRequest(username: 'tester', password: 'password');
        when(mockAuthService.login(request)).thenAnswer(
          (_) async => AuthResponse(
            token: token,
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

        final cubit = buildCubit();
        await cubit.login(request);
        expect(cubit.hasTokenExpiryTimerForTest, isTrue);

        await cubit.sessionExpired();

        expect(cubit.hasTokenExpiryTimerForTest, isFalse);
        expect(cubit.state.status, AuthStatus.unauthenticated);
        await cubit.close();
      },
    );

    test('Scenario J — duplicate expiry signals remain idempotent', () async {
      final token = buildJwt(
        expUtc: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
      when(mockAuthService.getAuthToken()).thenAnswer((_) async => token);
      when(
        mockAuthService.getCurrentUser(),
      ).thenAnswer((_) async => testUser());

      final cubit = buildCubit();
      await cubit.checkAuth();

      await Future.wait([cubit.sessionExpired(), cubit.sessionExpired()]);

      expect(cubit.state.status, AuthStatus.unauthenticated);
      verify(mockAuthService.logout()).called(1);
      await cubit.close();
    });
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
