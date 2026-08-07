import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
}
