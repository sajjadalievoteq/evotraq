import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/data/services/tatmeen_integration/tatmeen_integration_service.dart';

class UseTatmeenDashboard extends ChangeNotifier {
  UseTatmeenDashboard({required TatmeenIntegrationService service})
    : _service = service;

  final TatmeenIntegrationService _service;
  Timer? _pollTimer;
  bool _busy = false;
  bool _initialLoaded = false;

  TatmeenDashboardStats? stats;
  List<TatmeenChartPoint> chartData = const [];
  TatmeenStatusBreakdown? breakdown;
  List<TatmeenSyncEvent> recentActivity = const [];
  List<TatmeenErrorSummaryItem> errorSummary = const [];
  String? error;

  bool get isLoading => !_initialLoaded && _busy;
  bool get isRefreshing => _initialLoaded && _busy;
  bool get isError => error != null;

  Future<void> load() async {
    await _fetch();
    _pollTimer ??= Timer.periodic(const Duration(seconds: 60), (_) {
      _fetch(silent: true);
    });
  }

  Future<void> refetch() => _fetch();

  Future<void> _fetch({bool silent = false}) async {
    if (_busy) return;
    _busy = true;
    if (!silent) {
      notifyListeners();
    }
    try {
      final results = await Future.wait([
        _service.getTatmeenDashboardStats(),
        _service.getTatmeenChartData(days: 30),
        _service.getTatmeenStatusBreakdown(),
        _service.getTatmeenRecentActivity(limit: 10),
        _service.getTatmeenErrorSummary(),
      ]);
      stats = results[0] as TatmeenDashboardStats;
      chartData = results[1] as List<TatmeenChartPoint>;
      breakdown = results[2] as TatmeenStatusBreakdown;
      recentActivity = results[3] as List<TatmeenSyncEvent>;
      errorSummary = results[4] as List<TatmeenErrorSummaryItem>;
      error = null;
      _initialLoaded = true;
    } catch (e) {
      error = e is ApiException ? e.getUserFriendlyMessage() : e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
