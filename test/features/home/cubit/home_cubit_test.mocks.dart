




import 'dart:async' as _i5;

import 'package:mockito/mockito.dart' as _i1;
import 'package:traqtrace_app/data/models/home/dashboard_stats.dart' as _i2;
import 'package:traqtrace_app/data/models/home/recent_event.dart' as _i6;
import 'package:traqtrace_app/data/models/home/system_health_status.dart'
    as _i3;
import 'package:traqtrace_app/data/services/home/dashboard_service.dart' as _i4;
















class _FakeDashboardStats_0 extends _i1.SmartFake
    implements _i2.DashboardStats {
  _FakeDashboardStats_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeSystemHealthStatus_1 extends _i1.SmartFake
    implements _i3.SystemHealthStatus {
  _FakeSystemHealthStatus_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}




class MockDashboardService extends _i1.Mock implements _i4.DashboardService {
  MockDashboardService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.DashboardStats> getDashboardStats() =>
      (super.noSuchMethod(
            Invocation.method(#getDashboardStats, []),
            returnValue: _i5.Future<_i2.DashboardStats>.value(
              _FakeDashboardStats_0(
                this,
                Invocation.method(#getDashboardStats, []),
              ),
            ),
          )
          as _i5.Future<_i2.DashboardStats>);

  @override
  _i5.Future<({List<_i6.RecentEvent> recentEvents, _i2.DashboardStats stats})>
  getStatsAndRecentEvents({int? recentLimit = 10}) =>
      (super.noSuchMethod(
            Invocation.method(#getStatsAndRecentEvents, [], {
              #recentLimit: recentLimit,
            }),
            returnValue:
                _i5.Future<
                  ({
                    List<_i6.RecentEvent> recentEvents,
                    _i2.DashboardStats stats,
                  })
                >.value((
                  recentEvents: <_i6.RecentEvent>[],
                  stats: _FakeDashboardStats_0(
                    this,
                    Invocation.method(#getStatsAndRecentEvents, [], {
                      #recentLimit: recentLimit,
                    }),
                  ),
                )),
          )
          as _i5.Future<
            ({List<_i6.RecentEvent> recentEvents, _i2.DashboardStats stats})
          >);

  @override
  _i5.Future<({List<_i6.RecentEvent> recentEvents, _i2.DashboardStats stats})>
  getSummary({int? recentLimit = 5, int? throughputHours = 24}) =>
      (super.noSuchMethod(
            Invocation.method(#getSummary, [], {
              #recentLimit: recentLimit,
              #throughputHours: throughputHours,
            }),
            returnValue:
                _i5.Future<
                  ({
                    List<_i6.RecentEvent> recentEvents,
                    _i2.DashboardStats stats,
                  })
                >.value((
                  recentEvents: <_i6.RecentEvent>[],
                  stats: _FakeDashboardStats_0(
                    this,
                    Invocation.method(#getSummary, [], {
                      #recentLimit: recentLimit,
                      #throughputHours: throughputHours,
                    }),
                  ),
                )),
          )
          as _i5.Future<
            ({List<_i6.RecentEvent> recentEvents, _i2.DashboardStats stats})
          >);

  @override
  _i5.Future<List<_i6.RecentEvent>> getRecentEvents({int? limit = 5}) =>
      (super.noSuchMethod(
            Invocation.method(#getRecentEvents, [], {#limit: limit}),
            returnValue: _i5.Future<List<_i6.RecentEvent>>.value(
              <_i6.RecentEvent>[],
            ),
          )
          as _i5.Future<List<_i6.RecentEvent>>);

  @override
  _i5.Future<_i3.SystemHealthStatus> getSystemHealth() =>
      (super.noSuchMethod(
            Invocation.method(#getSystemHealth, []),
            returnValue: _i5.Future<_i3.SystemHealthStatus>.value(
              _FakeSystemHealthStatus_1(
                this,
                Invocation.method(#getSystemHealth, []),
              ),
            ),
          )
          as _i5.Future<_i3.SystemHealthStatus>);

  @override
  _i5.Future<({Map<int, int> buckets, int total})> fetchThroughput(
    int? hours,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#fetchThroughput, [hours]),
            returnValue: _i5.Future<({Map<int, int> buckets, int total})>.value(
              (buckets: <int, int>{}, total: 0),
            ),
          )
          as _i5.Future<({Map<int, int> buckets, int total})>);
}
