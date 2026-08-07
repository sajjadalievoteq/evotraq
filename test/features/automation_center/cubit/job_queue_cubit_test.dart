import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/data/services/automation_center/job_queue_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_state.dart';

class _MockJobQueueService extends Mock implements JobQueueService {}

class _MockWebSocketService extends Mock implements WebSocketService {}

void main() {
  late _MockJobQueueService service;
  late _MockWebSocketService ws;
  late StreamController<Map<String, dynamic>> jobQueueController;
  late StreamController<bool> connectionController;

  Map<String, dynamic> dashboard({int queued = 0, int active = 0}) => {
        'queuedJobs': queued,
        'activeJobs': active,
        'completedJobs': 0,
        'workerPool': {'activeThreads': 0, 'poolSize': 2, 'maxPoolSize': 8},
        'priorityDistribution': {'1': queued},
        'jobTypeDistribution': {'NOTIFICATION_BATCH': queued},
        'processingPaused': false,
      };

  void stubRestBundle({int queued = 0, int active = 0}) {
    when(() => service.getDashboard())
        .thenAnswer((_) async => dashboard(queued: queued, active: active));
    when(() => service.getWorkerPoolStats()).thenAnswer((_) async => {});
    when(() => service.getQueueHealth())
        .thenAnswer((_) async => {'healthy': true, 'issues': <String>[]});
    when(() => service.getActiveJobs()).thenAnswer(
        (_) async => List.generate(active, (i) => {'jobId': 'A$i'}));
    when(() => service.getQueuedJobs(limit: any(named: 'limit'))).thenAnswer(
        (_) async => List.generate(queued, (i) => {'jobId': 'Q$i'}));
    when(() => service.getJobHistory(limit: any(named: 'limit')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
  }

  setUp(() {
    service = _MockJobQueueService();
    ws = _MockWebSocketService();
    jobQueueController = StreamController<Map<String, dynamic>>.broadcast();
    connectionController = StreamController<bool>.broadcast();

    when(() => ws.jobQueueEventStream)
        .thenAnswer((_) => jobQueueController.stream);
    when(() => ws.connectionStream).thenAnswer((_) => connectionController.stream);
    when(() => ws.isConnected).thenReturn(false);
    when(() => ws.connect()).thenAnswer((_) async {});
    when(() => ws.disconnect()).thenReturn(null);
  });

  tearDown(() async {
    await jobQueueController.close();
    await connectionController.close();
  });

  JobQueueCubit build() =>
      JobQueueCubit(service: service, webSocketService: ws);

  test('initial REST load populates the snapshot', () async {
    stubRestBundle(queued: 3, active: 1);
    final cubit = build();

    await cubit.stream.firstWhere((s) => s.status == JobQueueStatus.success);

    expect(cubit.state.snapshot, isNotNull);
    expect(cubit.state.snapshot!.queuedJobs, 3);
    expect(cubit.state.snapshot!.activeJobs, 1);
    expect(cubit.state.snapshot!.queuedJobsList.length, 3);
    await cubit.close();
  });

  test('incoming WS payload updates the snapshot via the shared builder', () async {
    stubRestBundle(queued: 0, active: 0);
    final cubit = build();
    await cubit.stream.firstWhere((s) => s.status == JobQueueStatus.success);

    jobQueueController.add({
      'version': 5,
      'summary': dashboard(queued: 7, active: 2),
      'workerPoolStats': {},
      'queueHealth': {'healthy': true, 'issues': <String>[]},
      'activeJobs': [
        {'jobId': 'A0'},
        {'jobId': 'A1'}
      ],
      'queuedJobs': List.generate(7, (i) => {'jobId': 'Q$i'}),
      'jobHistory': <Map<String, dynamic>>[],
    });

    final next = await cubit.stream.firstWhere(
        (s) => s.snapshot != null && s.snapshot!.queuedJobs == 7);
    expect(next.snapshot!.activeJobs, 2);
    expect(next.snapshot!.queuedJobsList.length, 7);
    await cubit.close();
  });

  test('a connected event triggers an immediate REST re-sync', () async {
    stubRestBundle(queued: 0, active: 0);
    final cubit = build();
    await cubit.stream.firstWhere((s) => s.status == JobQueueStatus.success);
    clearInteractions(service);

    connectionController.add(true);
    await cubit.stream.firstWhere(
        (s) => s.connectionStatus == JobQueueConnectionStatus.connected);

    verify(() => service.getDashboard()).called(1);
    await cubit.close();
  });

  test('a disconnected event marks the connection disconnected', () async {
    stubRestBundle();
    final cubit = build();
    await cubit.stream.firstWhere((s) => s.status == JobQueueStatus.success);

    connectionController.add(false);
    final s = await cubit.stream.firstWhere(
        (s) => s.connectionStatus == JobQueueConnectionStatus.disconnected);
    expect(s.connectionStatus, JobQueueConnectionStatus.disconnected);
    await cubit.close();
  });

  test('close() does not disconnect the shared WebSocketService', () async {
    stubRestBundle();
    final cubit = build();
    await cubit.stream.firstWhere((s) => s.status == JobQueueStatus.success);

    await cubit.close();

    verifyNever(() => ws.disconnect());
  });

  test('connectWebSocket connects the socket and marks connecting', () async {
    stubRestBundle();
    final cubit = build();
    await cubit.stream.firstWhere((s) => s.status == JobQueueStatus.success);

    cubit.connectWebSocket();

    verify(() => ws.connect()).called(1);
    await cubit.close();
  });
}
