import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    SharedPreferences.setMockInitialValues({});
    mockService = MockDashboardService();
    sessionStore = HomeOverviewSessionStore(
      prefs: await SharedPreferences.getInstance(),
    );
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
}
