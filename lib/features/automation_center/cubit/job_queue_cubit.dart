import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/automation_center/job_queue_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/utils/job_queue_dashboard_snapshot_builder.dart';

/// Drives the Job Queue panel from an initial REST load plus live WebSocket snapshots.
///
/// REST is used only for: the initial load, an immediate re-sync on (re)connect, and a low-
/// frequency fallback poll while disconnected. While the WebSocket is healthy, updates arrive via
/// push with no fixed polling. Every payload — REST or WS — is funnelled through the same
/// [buildJobQueueDashboardSnapshot] builder so there is a single parsing path and a single
/// authoritative snapshot.
class JobQueueCubit extends Cubit<JobQueueState> {
  final JobQueueService _service;
  final WebSocketService _webSocketService;

  StreamSubscription? _jobQueueSubscription;
  StreamSubscription? _connectionSubscription;

  Timer? _fallbackGraceTimer;
  Timer? _fallbackPollTimer;

  static const Duration _fallbackGrace = Duration(seconds: 10);
  static const Duration _fallbackInterval = Duration(seconds: 25);

  // Rolling sparkline samples (mirrors the previous panel behavior: last 16 points).
  final List<double> _activeSparkline = <double>[];
  final List<double> _queuedSparkline = <double>[];
  static const int _sparklineWindow = 16;

  bool _loading = false;

  JobQueueCubit({
    required JobQueueService service,
    required WebSocketService webSocketService,
  }) : _service = service,
       _webSocketService = webSocketService,
       super(const JobQueueState()) {
    _initializeWebSocketListeners();
    // Initial paint from REST, independent of whether/when the socket connects.
    loadInitial();
  }

  void _initializeWebSocketListeners() {
    _jobQueueSubscription = _webSocketService.jobQueueEventStream.listen(
      _onSnapshotPushed,
    );
    _connectionSubscription = _webSocketService.connectionStream.listen(
      _onConnectionChanged,
    );
  }

  // ---- Live push handling -------------------------------------------------

  void _onSnapshotPushed(Map<String, dynamic> payload) {
    if (isClosed) return;
    try {
      final snapshot = _buildSnapshot(
        dashboardData: _asMap(payload['summary']),
        workerPoolStats: _asMap(payload['workerPoolStats']),
        queueHealth: _asMap(payload['queueHealth']),
        activeJobs: _asMapList(payload['activeJobs']),
        queuedJobs: _asMapList(payload['queuedJobs']),
        jobHistory: _asMapList(payload['jobHistory']),
      );
      emit(state.copyWith(status: JobQueueStatus.success, snapshot: snapshot));
    } catch (e) {
      emit(
        state.copyWith(
          status: JobQueueStatus.error,
          error: 'Failed to process job-queue update: $e',
        ),
      );
    }
  }

  void _onConnectionChanged(bool connected) {
    if (isClosed) return;
    if (connected) {
      _cancelFallback();
      emit(
        state.copyWith(connectionStatus: JobQueueConnectionStatus.connected),
      );
      // Immediate REST re-sync so the UI is current without waiting for the heartbeat.
      refresh();
    } else {
      emit(
        state.copyWith(connectionStatus: JobQueueConnectionStatus.disconnected),
      );
      _scheduleFallback();
    }
  }

  // ---- Connection control (explicit, like NotificationCubit) --------------

  void connectWebSocket() {
    if (_webSocketService.isConnected) {
      emit(
        state.copyWith(connectionStatus: JobQueueConnectionStatus.connected),
      );
      return;
    }
    emit(state.copyWith(connectionStatus: JobQueueConnectionStatus.connecting));
    // Shared socket is session-owned; connect() is idempotent.
    _webSocketService.connect();
  }

  /// Updates local connection UI only. Does not disconnect the shared socket.
  void markWebSocketDisconnectedLocally() {
    _cancelFallback();
    emit(
      state.copyWith(connectionStatus: JobQueueConnectionStatus.disconnected),
    );
  }

  /// @Deprecated — prefer [markWebSocketDisconnectedLocally]. Never disconnects
  /// the application-wide [WebSocketService].
  void disconnectWebSocket() => markWebSocketDisconnectedLocally();

  bool get isWebSocketConnected => _webSocketService.isConnected;

  // ---- REST loading -------------------------------------------------------

  Future<void> loadInitial() async {
    emit(state.copyWith(status: JobQueueStatus.loading));
    await _loadBundle();
  }

  /// One-shot REST reload of the whole dashboard bundle (initial load, on-connect re-sync,
  /// fallback poll, post-mutation refresh, and the manual Refresh action).
  Future<void> refresh() => _loadBundle();

  Future<void> _loadBundle() async {
    if (_loading) return;
    _loading = true;
    try {
      final results = await Future.wait([
        _service.getDashboard(),
        _service.getWorkerPoolStats(),
        _service.getQueueHealth(),
        _service.getActiveJobs(),
        _service.getQueuedJobs(limit: 100),
        _service.getJobHistory(limit: 100),
      ]);

      if (isClosed) return;
      final snapshot = _buildSnapshot(
        dashboardData: results[0] as Map<String, dynamic>,
        workerPoolStats: results[1] as Map<String, dynamic>,
        queueHealth: results[2] as Map<String, dynamic>,
        activeJobs: results[3] as List<Map<String, dynamic>>,
        queuedJobs: results[4] as List<Map<String, dynamic>>,
        jobHistory: results[5] as List<Map<String, dynamic>>,
      );
      emit(state.copyWith(status: JobQueueStatus.success, snapshot: snapshot));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: JobQueueStatus.error,
          error: 'Failed to load job queue data: $e',
        ),
      );
    } finally {
      _loading = false;
    }
  }

  // ---- Mutations (delegate to REST; the resulting backend event pushes a fresh snapshot,
  //      and we also refresh once for immediate feedback / when the socket is down) ---------

  Future<void> submitJob({
    required String jobType,
    required int priority,
    required Map<String, dynamic> payload,
  }) async {
    await _service.submitJob(
      jobType: jobType,
      priority: priority,
      payload: payload,
    );
    await refresh();
  }

  Future<void> cancelJob(String jobId) async {
    await _service.cancelJob(jobId);
    await refresh();
  }

  Future<void> retryJob(String jobId) async {
    await _service.retryJob(jobId);
    await refresh();
  }

  Future<void> pauseQueue() async {
    await _service.pauseQueue();
    await refresh();
  }

  Future<void> resumeQueue() async {
    await _service.resumeQueue();
    await refresh();
  }

  Future<Map<String, dynamic>> configureWorkerPool({
    required int corePoolSize,
    required int maxPoolSize,
    required int queueCapacity,
  }) async {
    final result = await _service.configureWorkerPool(
      corePoolSize: corePoolSize,
      maxPoolSize: maxPoolSize,
      queueCapacity: queueCapacity,
    );
    await refresh();
    return result;
  }

  Future<Map<String, dynamic>> resizeWorkerPool({required int newSize}) async {
    final result = await _service.resizeWorkerPool(newSize: newSize);
    await refresh();
    return result;
  }

  Future<Map<String, dynamic>> purgeJobs({int retentionDays = 30}) async {
    final result = await _service.purgeJobs(retentionDays: retentionDays);
    await refresh();
    return result;
  }

  /// Read-only prefill for the worker-pool config dialog.
  Future<Map<String, dynamic>> getWorkerPoolConfig() =>
      _service.getWorkerPoolConfig();

  // ---- App lifecycle ------------------------------------------------------

  /// Backgrounded: stop the disconnected-fallback poll so we do no work while hidden.
  void handleAppPaused() {
    _cancelFallback();
  }

  /// Foregrounded: re-sync immediately, and if still disconnected, resume the fallback poll.
  void handleAppResumed() {
    refresh();
    if (state.connectionStatus != JobQueueConnectionStatus.connected) {
      _scheduleFallback();
    }
  }

  // ---- Fallback poll while disconnected -----------------------------------

  void _scheduleFallback() {
    _fallbackGraceTimer?.cancel();
    _fallbackGraceTimer = Timer(_fallbackGrace, () {
      if (state.connectionStatus != JobQueueConnectionStatus.connected) {
        refresh();
        _fallbackPollTimer?.cancel();
        _fallbackPollTimer = Timer.periodic(_fallbackInterval, (_) {
          if (state.connectionStatus != JobQueueConnectionStatus.connected) {
            refresh();
          }
        });
      }
    });
  }

  void _cancelFallback() {
    _fallbackGraceTimer?.cancel();
    _fallbackGraceTimer = null;
    _fallbackPollTimer?.cancel();
    _fallbackPollTimer = null;
  }

  // ---- Snapshot assembly --------------------------------------------------

  JobQueueDashboardSnapshot _buildSnapshot({
    required Map<String, dynamic> dashboardData,
    required Map<String, dynamic> workerPoolStats,
    required Map<String, dynamic> queueHealth,
    required List<Map<String, dynamic>> activeJobs,
    required List<Map<String, dynamic>> queuedJobs,
    required List<Map<String, dynamic>> jobHistory,
  }) {
    _recordSparkline(activeJobs.length, queuedJobs.length);
    return buildJobQueueDashboardSnapshot(
      dashboardData: dashboardData,
      workerPoolStats: workerPoolStats,
      queueHealth: queueHealth,
      activeJobs: activeJobs,
      queuedJobs: queuedJobs,
      jobHistory: jobHistory,
      activeSparkline: _activeSparkline,
      queuedSparkline: _queuedSparkline,
      lastUpdated: DateTime.now(),
    );
  }

  void _recordSparkline(int active, int queued) {
    _activeSparkline.add(active.toDouble());
    _queuedSparkline.add(queued.toDouble());
    if (_activeSparkline.length > _sparklineWindow) {
      _activeSparkline.removeAt(0);
    }
    if (_queuedSparkline.length > _sparklineWindow) {
      _queuedSparkline.removeAt(0);
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static List<Map<String, dynamic>> _asMapList(dynamic value) => value is List
      ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : <Map<String, dynamic>>[];

  @override
  Future<void> close() async {
    await _jobQueueSubscription?.cancel();
    _jobQueueSubscription = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _cancelFallback();
    // Never disconnect the shared WebSocketService singleton here.
    return super.close();
  }
}
