import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/home/system_health_status.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';

import 'home_cubit_test.mocks.dart';

@GenerateMocks([DashboardService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDashboardService mockService;
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

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('home_cubit_hive_');
    await HiveStorage.initForTests(hiveDir.path);
    mockService = MockDashboardService();
    sessionStore = HomeOverviewSessionStore();
  });

  tearDown(() async {
    await HiveStorage.resetForTests();
    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
    }
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

    final cubit = HomeCubit(mockService, sessionStore);
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

    final cubit = HomeCubit(mockService, sessionStore);
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

    final cubit = HomeCubit(mockService, sessionStore);
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

      final cubit = HomeCubit(
        mockService,
        sessionStore,
        pollInterval: pollInterval,
      );
      await cubit.load(accountEmail: 'user@example.com');
      // Allow background SWR from load() to finish so _isRevalidating clears.
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

      cubit.stopPolling();
      clearInteractions(mockService);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      verifyNever(mockService.getSummary(
        recentLimit: anyNamed('recentLimit'),
        throughputHours: anyNamed('throughputHours'),
      ));

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

      // Several intervals while the first request is still gated.
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
}
