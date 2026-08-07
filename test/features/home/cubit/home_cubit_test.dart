import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/home/system_health_status.dart';
import 'package:traqtrace_app/data/services/auth/auth_service.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';

import 'home_cubit_test.mocks.dart';

@GenerateMocks([DashboardService, WebSocketService])
class _StubAuthService extends Mock implements AuthService {}

class _TestAuthCubit extends AuthCubit {
  _TestAuthCubit({required AuthService authService})
      : super(authService: authService);

  void setState(AuthState state) => emit(state);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDashboardService mockService;
  late MockWebSocketService mockWs;
  late StreamController<Map<String, dynamic>> dashboardPushController;
  late StreamController<bool> connectionController;
  late _StubAuthService mockAuthService;
  late _TestAuthCubit authCubit;
  late HomeOverviewSessionStore sessionStore;
  late Directory hiveDir;

  DashboardStats stats({required int gtin}) => DashboardStats(
        gtinCount: gtin,
        glnCount: 0,
        sgtinCount: 0,
        ssccCount: 0,
        totalEvents: 0,
        eventsByType: const {},
      );

  List<RecentEvent> events(String id) => [
        RecentEvent(
          id: id,
          eventType: 'ObjectEvent',
          action: 'ADD',
          eventTime: DateTime.parse('2026-07-14T10:00:00Z'),
          epcList: const [],
        ),
      ];

  SystemHealthStatus health({required bool up}) => SystemHealthStatus(
        backendHealthy: up,
        databaseHealthy: up,
        cacheHealthy: up,
        backendVersion: up ? '1.0.0' : null,
      );

  _TestAuthCubit authCubitFor(String role) {
    final cubit = _TestAuthCubit(authService: mockAuthService);
    cubit.setState(
      AuthState(
        status: AuthStatus.authenticated,
        user: User(
          id: 1,
          username: role.toLowerCase(),
          email: '${role.toLowerCase()}@example.com',
          firstName: 'A',
          lastName: 'D',
          role: role,
          enabled: true,
          hasProfilePicture: false,
        ),
        token: 't',
        bootstrapCompleted: true,
      ),
    );
    return cubit;
  }

  HomeCubit buildCubit({Duration? pollInterval}) {
    return HomeCubit(
      mockService,
      sessionStore,
      authCubit: authCubit,
      webSocketService: mockWs,
      pollInterval: pollInterval ?? const Duration(seconds: 60),
    );
  }

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('home_cubit_hive_');
    await HiveStorage.initForTests(hiveDir.path);
    mockService = MockDashboardService();
    mockAuthService = _StubAuthService();
    authCubit = authCubitFor('ADMIN');
    sessionStore = HomeOverviewSessionStore();

    mockWs = MockWebSocketService();
    dashboardPushController = StreamController<Map<String, dynamic>>.broadcast();
    connectionController = StreamController<bool>.broadcast();
    when(mockWs.dashboardSummaryStream)
        .thenAnswer((_) => dashboardPushController.stream);
    when(mockWs.connectionStream).thenAnswer((_) => connectionController.stream);
    when(mockWs.isConnected).thenReturn(false);
    when(mockWs.connect()).thenReturn(null);
    when(mockWs.disconnect()).thenReturn(null);
  });

  tearDown(() async {
    await authCubit.close();
    await dashboardPushController.close();
    await connectionController.close();
    await HiveStorage.resetForTests();
    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
    }
  });

  test('plain USER load skips dashboard and health calls', () async {
    await authCubit.close();
    authCubit = authCubitFor('USER');

    final cubit = buildCubit();
    await cubit.load(accountEmail: 'user@example.com');

    expect(cubit.state.status, HomeLoadStatus.success);
    expect(cubit.state.stats, isNull);
    verifyNever(mockService.getSummary(
      recentLimit: anyNamed('recentLimit'),
      throughputHours: anyNamed('throughputHours'),
    ));
    verifyNever(mockService.getSystemHealth());

    await cubit.close();
  });

  test('manufacturer loads dashboard but skips admin-only health', () async {
    await authCubit.close();
    authCubit = authCubitFor('MANUFACTURER');

    when(mockService.getSummary(
      recentLimit: anyNamed('recentLimit'),
      throughputHours: anyNamed('throughputHours'),
    )).thenAnswer(
      (_) async => (stats: stats(gtin: 5), recentEvents: events('m')),
    );

    final cubit = buildCubit();
    await cubit.load(accountEmail: 'manufacturer@example.com');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(cubit.state.status, HomeLoadStatus.success);
    expect(cubit.state.stats?.gtinCount, 5);
    expect(cubit.state.healthLoading, isFalse);
    verifyNever(mockService.getSystemHealth());

    await cubit.close();
  });

  test('retailer skips the throughput endpoint', () async {
    await authCubit.close();
    authCubit = authCubitFor('RETAILER');

    final cubit = buildCubit();
    await cubit.loadThroughput(168);

    verifyNever(mockService.fetchThroughput(any));

    await cubit.close();
  });

  test('dashboard emits without waiting for health', () async {
    final healthCompleter = Completer<SystemHealthStatus>();
    when(mockService.getSummary(
      recentLimit: anyNamed('recentLimit'),
      throughputHours: anyNamed('throughputHours'),
    )).thenAnswer(
      (_) async => (stats: stats(gtin: 7), recentEvents: events('a')),
    );
    when(mockService.getSystemHealth())
        .thenAnswer((_) => healthCompleter.future);

    final cubit = buildCubit();
    final states = <HomeState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.load(accountEmail: 'user@example.com');

    expect(cubit.state.status, HomeLoadStatus.success);
    expect(cubit.state.stats?.gtinCount, 7);
    expect(cubit.state.healthStatus, isNull);
    expect(cubit.state.healthLoading, isTrue);

    healthCompleter.complete(health(up: true));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(cubit.state.healthStatus?.backendHealthy, isTrue);
    expect(cubit.state.healthLoading, isFalse);
    expect(cubit.state.stats?.gtinCount, 7);
    expect(
      states.any(
        (s) => s.status == HomeLoadStatus.success && s.healthStatus == null,
      ),
      isTrue,
    );

    await sub.cancel();
    await cubit.close();
  });

  test('cached state emits before network refresh', () async {
    await sessionStore.save(
      HomeOverviewBundle(
        stats: stats(gtin: 1),
        recentEvents: events('cached'),
        healthStatus: health(up: false),
        lastDataRefreshAt: DateTime.now(),
        accountEmail: 'user@example.com',
      ),
    );

    final summaryCompleter =
        Completer<({DashboardStats stats, List<RecentEvent> recentEvents})>();
    when(mockService.getSummary(
      recentLimit: anyNamed('recentLimit'),
      throughputHours: anyNamed('throughputHours'),
    )).thenAnswer((_) => summaryCompleter.future);
    when(mockService.getSystemHealth())
        .thenAnswer((_) async => health(up: true));

    final cubit = buildCubit();
    final states = <HomeState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.load(accountEmail: 'user@example.com');
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, HomeLoadStatus.success);
    expect(cubit.state.stats?.gtinCount, 1);
    expect(cubit.state.recentEvents?.first.id, 'cached');

    summaryCompleter.complete(
      (stats: stats(gtin: 99), recentEvents: events('fresh')),
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(cubit.state.stats?.gtinCount, 99);
    expect(states.first.stats?.gtinCount, 1);

    await sub.cancel();
    await cubit.close();
  });

  test('health failure leaves dashboard payload intact', () async {
    when(mockService.getSummary(
      recentLimit: anyNamed('recentLimit'),
      throughputHours: anyNamed('throughputHours'),
    )).thenAnswer(
      (_) async => (stats: stats(gtin: 3), recentEvents: events('ok')),
    );
    when(mockService.getSystemHealth())
        .thenAnswer((_) async => throw TimeoutException('health'));

    final cubit = buildCubit();
    await cubit.load(accountEmail: 'user@example.com');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(cubit.state.status, HomeLoadStatus.success);
    expect(cubit.state.stats?.gtinCount, 3);
    expect(cubit.state.healthLoading, isFalse);

    await cubit.close();
  });

  group('polling', () {
    Future<HomeCubit> seedReadyCubit({
      required Duration pollInterval,
      int gtin = 1,
    }) async {
      await sessionStore.save(
        HomeOverviewBundle(
          stats: stats(gtin: gtin),
          recentEvents: events('seed'),
          healthStatus: health(up: true),
          lastDataRefreshAt: DateTime(2026, 1, 1),
          accountEmail: 'user@example.com',
        ),
      );
      when(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).thenAnswer(
        (_) async => (stats: stats(gtin: gtin), recentEvents: events('seed')),
      );
      when(mockService.getSystemHealth())
          .thenAnswer((_) async => health(up: true));

      final cubit = buildCubit(pollInterval: pollInterval);
      await cubit.load(accountEmail: 'user@example.com');

      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(cubit.state.status, HomeLoadStatus.success);
      return cubit;
    }

    test('tick triggers background revalidate without loading flash', () async {
      final cubit = await seedReadyCubit(
        pollInterval: const Duration(milliseconds: 40),
      );
      clearInteractions(mockService);

      when(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).thenAnswer(
        (_) async => (stats: stats(gtin: 11), recentEvents: events('poll')),
      );
      when(mockService.getSystemHealth())
          .thenAnswer((_) async => health(up: true));

      cubit.startPolling(accountEmail: 'user@example.com');
      await Future<void>.delayed(const Duration(milliseconds: 70));

      expect(cubit.state.status, isNot(HomeLoadStatus.loading));
      expect(cubit.state.stats?.gtinCount, 11);
      expect(cubit.state.refreshFailed, isFalse);
      verify(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).called(greaterThanOrEqualTo(1));
      verifyNever(mockService.getSystemHealth());

      cubit.stopPolling();
      clearInteractions(mockService);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      verifyNever(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      ));
      verifyNever(mockService.getSystemHealth());

      await cubit.close();
    });

    test('overlapping ticks are skipped while revalidation is in flight', () async {
      final cubit = await seedReadyCubit(
        pollInterval: const Duration(milliseconds: 40),
      );

      var summaryCalls = 0;
      final gate = Completer<void>();
      when(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).thenAnswer((_) async {
        summaryCalls++;
        await gate.future;
        return (stats: stats(gtin: summaryCalls), recentEvents: events('x'));
      });
      when(mockService.getSystemHealth())
          .thenAnswer((_) async => health(up: true));

      cubit.startPolling(accountEmail: 'user@example.com');
      await Future<void>.delayed(const Duration(milliseconds: 55));
      expect(summaryCalls, 1);

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(summaryCalls, 1);

      gate.complete();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(cubit.state.stats?.gtinCount, 1);

      await cubit.close();
    });

    test('failed poll keeps payload and sets refreshFailed', () async {
      final cubit = await seedReadyCubit(
        pollInterval: const Duration(milliseconds: 40),
        gtin: 42,
      );

      when(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).thenAnswer((_) async => throw TimeoutException('down'));
      when(mockService.getSystemHealth())
          .thenAnswer((_) async => health(up: false));

      cubit.startPolling(accountEmail: 'user@example.com');
      await Future<void>.delayed(const Duration(milliseconds: 70));

      expect(cubit.state.status, HomeLoadStatus.success);
      expect(cubit.state.stats?.gtinCount, 42);
      expect(cubit.state.refreshFailed, isTrue);

      await cubit.close();
    });

    test('startPolling is idempotent (single cadence)', () async {
      final cubit = await seedReadyCubit(
        pollInterval: const Duration(milliseconds: 50),
      );

      var summaryCalls = 0;
      when(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).thenAnswer((_) async {
        summaryCalls++;
        return (stats: stats(gtin: summaryCalls), recentEvents: events('p'));
      });
      when(mockService.getSystemHealth())
          .thenAnswer((_) async => health(up: true));

      cubit.startPolling(accountEmail: 'user@example.com');
      cubit.startPolling(accountEmail: 'user@example.com');
      cubit.startPolling(accountEmail: 'user@example.com');

      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(summaryCalls, 1);

      await cubit.close();
    });

    test('onAppResumed refreshes immediately; close cancels further polls',
        () async {
      final cubit = await seedReadyCubit(
        pollInterval: const Duration(milliseconds: 40),
      );

      when(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).thenAnswer(
        (_) async => (stats: stats(gtin: 9), recentEvents: events('resume')),
      );
      when(mockService.getSystemHealth())
          .thenAnswer((_) async => health(up: true));

      await cubit.onAppResumed(accountEmail: 'user@example.com');
      expect(cubit.state.stats?.gtinCount, 9);

      clearInteractions(mockService);
      await cubit.close();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(cubit.isClosed, isTrue);
      verifyNever(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      ));
    });

    test('close cancels polling timer', () async {
      final cubit = await seedReadyCubit(
        pollInterval: const Duration(milliseconds: 30),
      );

      var summaryCalls = 0;
      when(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).thenAnswer((_) async {
        summaryCalls++;
        return (stats: stats(gtin: 1), recentEvents: events('x'));
      });

      cubit.startPolling(accountEmail: 'user@example.com');
      await cubit.close();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(summaryCalls, 0);
    });
  });

  group('websocket heartbeat push', () {
    Map<String, dynamic> pushPayload({required int gtin, String eventId = 'push'}) => {
          'counts': {'gtin': gtin, 'gln': 0, 'sgtin': 0, 'sscc': 0},
          'eventCounts': {
            'Object': 0,
            'Aggregation': 0,
            'Transaction': 0,
            'Transformation': 0,
            'totalEvents': 0,
          },
          'recentEvents': [
            {
              'id': eventId,
              'eventType': 'ObjectEvent',
              'action': 'ADD',
              'eventTime': '2026-07-14T10:00:00Z',
              'epcList': <String>[],
            },
          ],
          'throughput': {'buckets': <Map<String, dynamic>>[], 'totalCount': 0},
        };

    Future<HomeCubit> seedReadyCubit() async {
      when(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).thenAnswer(
        (_) async => (stats: stats(gtin: 1), recentEvents: events('initial')),
      );
      when(mockService.getSystemHealth()).thenAnswer((_) async => health(up: true));

      final cubit = buildCubit();
      await cubit.load(accountEmail: 'user@example.com');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cubit.state.status, HomeLoadStatus.success);
      return cubit;
    }

    test('a pushed snapshot updates state without a REST call', () async {
      final cubit = await seedReadyCubit();
      clearInteractions(mockService);

      dashboardPushController.add(pushPayload(gtin: 42, eventId: 'ws-1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cubit.state.stats?.gtinCount, 42);
      expect(cubit.state.recentEvents?.first.id, 'ws-1');
      verifyNever(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      ));

      await cubit.close();
    });

    test('a malformed push is swallowed and does not clobber state', () async {
      final cubit = await seedReadyCubit();

      dashboardPushController.add(<String, dynamic>{'counts': 'not-a-map'});
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cubit.state.stats?.gtinCount, 1);
      expect(cubit.state.status, HomeLoadStatus.success);

      await cubit.close();
    });

    test('connecting triggers an immediate REST re-sync and stops the fallback poll', () async {
      final cubit = await seedReadyCubit();
      cubit.startPolling(accountEmail: 'user@example.com'); // simulate a prior disconnected state
      clearInteractions(mockService);

      when(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).thenAnswer(
        (_) async => (stats: stats(gtin: 5), recentEvents: events('resynced')),
      );

      connectionController.add(true);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cubit.state.stats?.gtinCount, 5);
      verify(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).called(1);

      await cubit.close();
    });

    test('disconnecting starts the REST fallback poll', () async {
      final cubit = await seedReadyCubit();

      var summaryCalls = 0;
      when(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      )).thenAnswer((_) async {
        summaryCalls++;
        return (stats: stats(gtin: 7), recentEvents: events('fallback'));
      });

      connectionController.add(false);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(summaryCalls, greaterThanOrEqualTo(1));

      await cubit.close();
    });

    test('a push preserves a non-default throughput selection', () async {
      final cubit = await seedReadyCubit();
      when(mockService.fetchThroughput(168)).thenAnswer(
        (_) async => (buckets: {5: 10}, total: 10),
      );
      await cubit.loadThroughput(168);
      expect(cubit.state.throughputHours, 168);
      expect(cubit.state.stats?.throughputBuckets, {5: 10});

      // The heartbeat push always uses the default (24h) window with different figures — a
      // non-default selection must keep the previously-fetched throughput, not the push's.
      final withDifferentThroughput = pushPayload(gtin: 42);
      withDifferentThroughput['throughput'] = {
        'buckets': [
          {'hourIndex': 1, 'count': 999},
        ],
        'totalCount': 999,
      };
      dashboardPushController.add(withDifferentThroughput);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cubit.state.throughputHours, 168);
      expect(cubit.state.stats?.gtinCount, 42);
      expect(cubit.state.stats?.throughputBuckets, {5: 10});
      expect(cubit.state.stats?.throughputTotal, 10);

      await cubit.close();
    });

    test('close() cancels websocket subscriptions but never disconnects the shared socket',
        () async {
      final cubit = await seedReadyCubit();

      await cubit.close();

      verifyNever(mockWs.disconnect());
      // Emitting after close must not throw (subscriptions were cancelled).
      expect(() => dashboardPushController.add(pushPayload(gtin: 1)), returnsNormally);
      expect(() => connectionController.add(true), returnsNormally);
    });
  });
}
