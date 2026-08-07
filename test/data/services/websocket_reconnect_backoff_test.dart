import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _MockTokenManager extends Mock implements TokenManager {}

class _MockWebSocketChannel extends Mock implements WebSocketChannel {}

class _MockWebSocketSink extends Mock implements WebSocketSink {}

void main() {
  group('WebSocketService.reconnectBackoffCeilingSeconds', () {
    test('grows exponentially from a 2s base', () {
      expect(WebSocketService.reconnectBackoffCeilingSeconds(1), 2);
      expect(WebSocketService.reconnectBackoffCeilingSeconds(2), 4);
      expect(WebSocketService.reconnectBackoffCeilingSeconds(3), 8);
      expect(WebSocketService.reconnectBackoffCeilingSeconds(4), 16);
    });

    test('caps at 30 seconds', () {
      expect(WebSocketService.reconnectBackoffCeilingSeconds(5), 30);
      expect(WebSocketService.reconnectBackoffCeilingSeconds(6), 30);
      expect(WebSocketService.reconnectBackoffCeilingSeconds(50), 30);
    });

    test('is monotonically non-decreasing and never gives up', () {
      int previous = 0;
      for (var attempt = 1; attempt <= 100; attempt++) {
        final ceiling = WebSocketService.reconnectBackoffCeilingSeconds(
          attempt,
        );
        expect(ceiling, greaterThanOrEqualTo(previous));
        expect(ceiling, greaterThan(0)); // always schedules another attempt
        previous = ceiling;
      }
    });
  });

  group('WebSocketService startup and connection lifecycle', () {
    late _MockTokenManager tokenManager;
    late _MockWebSocketChannel channel;
    late _MockWebSocketSink sink;
    late StreamController<dynamic> incoming;
    late int channelCreations;

    setUp(() {
      tokenManager = _MockTokenManager();
      channel = _MockWebSocketChannel();
      sink = _MockWebSocketSink();
      incoming = StreamController<dynamic>.broadcast();
      channelCreations = 0;
      when(() => channel.stream).thenAnswer((_) => incoming.stream);
      when(() => channel.sink).thenReturn(sink);
      when(() => sink.add(any())).thenAnswer((_) {});
      when(() => sink.close(any(), any())).thenAnswer((_) async {});
    });

    tearDown(() async {
      await incoming.close();
    });

    WebSocketService buildService({String? baseUrl}) => WebSocketService(
      tokenManager: tokenManager,
      baseUrl: baseUrl,
      channelFactory: (uri, protocols) {
        channelCreations++;
        return channel;
      },
    );

    test(
      'connect before configuration fails safely without an async error',
      () async {
        when(() => tokenManager.getToken()).thenAnswer((_) async => 'token');
        final service = buildService();
        final states = <bool>[];
        final subscription = service.connectionStream.listen(states.add);

        service.connect();
        await pumpEventQueue();

        expect(service.isConnected, isFalse);
        expect(service.isConnecting, isFalse);
        expect(states, [false]);
        expect(channelCreations, 0);
        await subscription.cancel();
        service.dispose();
      },
    );

    test('connect without a stored token fails safely', () async {
      when(() => tokenManager.getToken()).thenAnswer((_) async => null);
      final service = buildService(baseUrl: 'http://localhost:8080/api');
      final states = <bool>[];
      final subscription = service.connectionStream.listen(states.add);

      service.connect();
      await pumpEventQueue();

      expect(service.isConnected, isFalse);
      expect(states, [false]);
      expect(channelCreations, 0);
      await subscription.cancel();
      service.dispose();
    });

    test(
      'configured service requires STOMP CONNECTED before becoming live',
      () async {
        when(() => tokenManager.getToken()).thenAnswer((_) async => 'token');
        final service = buildService(baseUrl: 'http://localhost:8080/api');

        service.connect();
        await pumpEventQueue();
        expect(channelCreations, 1);
        expect(service.isConnecting, isTrue);
        expect(service.isConnected, isFalse);

        incoming.add('CONNECTED\nversion:1.2\n\n\x00');
        await pumpEventQueue();
        expect(service.isConnecting, isFalse);
        expect(service.isConnected, isTrue);

        service.dispose();
      },
    );

    test('concurrent connect requests create only one channel', () async {
      final tokenCompleter = Completer<String?>();
      when(
        () => tokenManager.getToken(),
      ).thenAnswer((_) => tokenCompleter.future);
      final service = buildService(baseUrl: 'http://localhost:8080/api');

      service.connect();
      service.connect();
      service.connect();
      tokenCompleter.complete('token');
      await pumpEventQueue();

      expect(channelCreations, 1);
      service.dispose();
    });

    test('initialize then connect works for compatibility callers', () async {
      when(() => tokenManager.getToken()).thenAnswer((_) async => 'token');
      final service = buildService();

      service.initialize('http://localhost:8080/api', '');
      service.connect();
      await pumpEventQueue();

      expect(channelCreations, 1);
      service.dispose();
    });
  });
}
