import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/data/services/automation_center/notification_api_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';

class _MockNotificationApiService extends Mock
    implements NotificationApiService {}

class _MockWebSocketService extends Mock implements WebSocketService {}

void main() {
  late _MockNotificationApiService api;
  late _MockWebSocketService socket;
  late StreamController<bool> connections;

  setUp(() {
    api = _MockNotificationApiService();
    socket = _MockWebSocketService();
    connections = StreamController<bool>.broadcast();

    when(
      () => socket.notificationStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => socket.connectionStream).thenAnswer((_) => connections.stream);
    when(() => socket.isConnected).thenReturn(false);
    when(() => socket.isConnecting).thenReturn(false);
    when(() => socket.connect()).thenAnswer((_) {});
  });

  tearDown(() => connections.close());

  test(
    'Live reports connecting, connected, then disconnected accurately',
    () async {
      final cubit = NotificationCubit(
        apiService: api,
        webSocketService: socket,
      );

      cubit.enableNotificationLive();
      expect(
        cubit.state.connectionStatus,
        NotificationConnectionStatus.connecting,
      );

      connections.add(true);
      await pumpEventQueue();
      expect(
        cubit.state.connectionStatus,
        NotificationConnectionStatus.connected,
      );

      connections.add(false);
      await pumpEventQueue();
      expect(
        cubit.state.connectionStatus,
        NotificationConnectionStatus.disconnected,
      );

      await cubit.close();
    },
  );

  test('a failed connection attempt is not presented as connected', () async {
    final cubit = NotificationCubit(apiService: api, webSocketService: socket);

    cubit.enableNotificationLive();
    connections.add(false);
    await pumpEventQueue();

    expect(cubit.state.connectionStatus, NotificationConnectionStatus.failed);
    await cubit.close();
  });

  test(
    'pausing Live and disposing never disconnect the shared socket',
    () async {
      final cubit = NotificationCubit(
        apiService: api,
        webSocketService: socket,
      );

      cubit.disableNotificationLive();
      expect(cubit.state.notificationLiveEnabled, isFalse);
      await cubit.close();

      verifyNever(() => socket.disconnect());
    },
  );

  NotificationSubscription subscription({String id = 'sub-1'}) {
    return NotificationSubscription(
      id: id,
      subscriptionName: 'Batch alerts',
      webhookUrl: 'https://example.com/hook',
      status: 'ACTIVE',
      subscriptionType: 'BATCH',
      createdAt: DateTime.utc(2026, 1, 1),
    );
  }

  NotificationBatch batch({
    required String id,
    required String status,
    int? deliveryAttempts,
    DateTime? createdAt,
  }) {
    return NotificationBatch(
      id: id,
      subscriptionId: 'sub-1',
      status: status,
      deliveryAttempts: deliveryAttempts,
      createdAt: createdAt ?? DateTime.utc(2026, 1, 2),
    );
  }

  test('isExhausted requires FAILED status and at least 3 attempts', () {
    expect(
      batch(id: 'a', status: 'FAILED', deliveryAttempts: 3).isExhausted,
      isTrue,
    );
    expect(
      batch(id: 'b', status: 'FAILED', deliveryAttempts: 2).isExhausted,
      isFalse,
    );
    expect(
      batch(id: 'c', status: 'SENT', deliveryAttempts: 3).isExhausted,
      isFalse,
    );
  });

  test('loadFailedBatches keeps only exhausted batches', () async {
    when(
      () => api.getSubscriptions(),
    ).thenAnswer((_) async => [subscription()]);
    when(() => api.getBatchHistory('sub-1')).thenAnswer(
      (_) async => [
        batch(id: 'exhausted', status: 'FAILED', deliveryAttempts: 3),
        batch(id: 'retrying', status: 'FAILED', deliveryAttempts: 1),
        batch(id: 'sent', status: 'SENT', deliveryAttempts: 3),
      ],
    );

    final cubit = NotificationCubit(apiService: api, webSocketService: socket);
    await cubit.loadFailedBatches();

    expect(cubit.state.failedBatches, hasLength(1));
    expect(cubit.state.failedBatches.single.id, 'exhausted');
    expect(cubit.state.failedBatchesLoading, isFalse);
    await cubit.close();
  });

  test('retryBatch refreshes activity and failed batches', () async {
    when(
      () => api.getSubscriptions(),
    ).thenAnswer((_) async => [subscription()]);
    when(() => api.getBatchHistory('sub-1')).thenAnswer((_) async => []);
    when(
      () => api.getDeliveryActivity(
        page: any(named: 'page'),
        size: any(named: 'size'),
        outcome: any(named: 'outcome'),
      ),
    ).thenAnswer((_) async => (items: <WebhookNotification>[], hasMore: false, page: 0));
    when(() => api.retryBatch('batch-1')).thenAnswer((_) async {});

    final cubit = NotificationCubit(apiService: api, webSocketService: socket);
    await cubit.retryBatch('batch-1');

    verify(() => api.retryBatch('batch-1')).called(1);
    verify(() => api.getBatchHistory('sub-1')).called(1);
    verify(
      () => api.getDeliveryActivity(
        page: any(named: 'page'),
        size: any(named: 'size'),
        outcome: any(named: 'outcome'),
      ),
    ).called(1);
    await cubit.close();
  });

  test('retryWebhook refreshes delivery activity', () async {
    when(
      () => api.getSubscriptions(),
    ).thenAnswer((_) async => [subscription()]);
    when(
      () => api.getDeliveryActivity(
        page: any(named: 'page'),
        size: any(named: 'size'),
        outcome: any(named: 'outcome'),
      ),
    ).thenAnswer((_) async => (items: <WebhookNotification>[], hasMore: false, page: 0));
    when(() => api.retryWebhook('note-1')).thenAnswer((_) async {});

    final cubit = NotificationCubit(apiService: api, webSocketService: socket);
    await cubit.retryWebhook('note-1');

    verify(() => api.retryWebhook('note-1')).called(1);
    verify(
      () => api.getDeliveryActivity(
        page: any(named: 'page'),
        size: any(named: 'size'),
        outcome: any(named: 'outcome'),
      ),
    ).called(1);
    await cubit.close();
  });

  test('loadDeliveryActivity pages from the activity API', () async {
    when(
      () => api.getSubscriptions(),
    ).thenAnswer((_) async => [subscription()]);
    when(
      () => api.getDeliveryActivity(
        page: 0,
        size: any(named: 'size'),
        outcome: any(named: 'outcome'),
      ),
    ).thenAnswer(
      (_) async => (
        items: [
          WebhookNotification(
            id: 'n1',
            subscriptionId: 'sub-1',
            eventId: 'e1',
            status: 'DELIVERED',
            webhookUrl: 'https://example.com/hook',
            createdAt: DateTime.utc(2026, 1, 2),
            retryCount: 1,
          ),
        ],
        hasMore: true,
        page: 0,
      ),
    );
    when(
      () => api.getDeliveryActivity(
        page: 1,
        size: any(named: 'size'),
        outcome: any(named: 'outcome'),
      ),
    ).thenAnswer(
      (_) async => (
        items: [
          WebhookNotification(
            id: 'n2',
            subscriptionId: 'sub-1',
            eventId: 'e2',
            status: 'FAILED',
            webhookUrl: 'https://example.com/hook',
            createdAt: DateTime.utc(2026, 1, 1),
            retryCount: 3,
          ),
        ],
        hasMore: false,
        page: 1,
      ),
    );

    final cubit = NotificationCubit(apiService: api, webSocketService: socket);
    await cubit.loadDeliveryActivity(outcome: 'failed');

    expect(cubit.state.deliveryActivity, hasLength(1));
    expect(cubit.state.deliveryActivityHasMore, isTrue);
    expect(cubit.state.deliveryActivityOutcome, 'failed');

    await cubit.loadMoreDeliveryActivity();
    expect(cubit.state.deliveryActivity.map((e) => e.id), ['n1', 'n2']);
    expect(cubit.state.deliveryActivityHasMore, isFalse);
    expect(cubit.state.deliveryActivityPage, 1);
    await cubit.close();
  });
}
