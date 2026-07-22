import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:traqtrace_app/features/notifications/domain/models/realtime_notification.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  final StreamController<RealtimeNotification> _notificationController =
      StreamController<RealtimeNotification>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  String? _baseUrl;
  String? _accessToken;
  bool _isConnected = false;
  bool _intentionalDisconnect = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  Stream<RealtimeNotification> get notificationStream =>
      _notificationController.stream;

  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;

  void initialize(String baseUrl, String accessToken) {
    _baseUrl = baseUrl;
    _accessToken = accessToken;
  }

  void connect() {
    if (_baseUrl == null || _accessToken == null) {
      throw Exception('WebSocket service not properly initialized');
    }

    _intentionalDisconnect = false;
    _teardownChannel(sendDisconnect: false);

    try {
      final wsUrl = '${_baseUrl!.replaceFirst('http', 'ws')}/ws';

      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['v10.stomp', 'v11.stomp', 'v12.stomp'],
      );

      _channelSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnect,
      );

      _sendStompFrame('CONNECT', {
        'accept-version': '1.0,1.1,1.2',
        'heart-beat': '10000,10000',
        'Authorization': 'Bearer $_accessToken',
      });

      _isConnected = true;
      _connectionController.add(true);
      _reconnectAttempts = 0;
      _startHeartbeat();
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _isConnected = false;
      _connectionController.add(false);
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _teardownChannel(sendDisconnect: true);
    _isConnected = false;
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
  }

  
  void _teardownChannel({required bool sendDisconnect}) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _channelSubscription?.cancel();
    _channelSubscription = null;

    final channel = _channel;
    _channel = null;
    if (channel == null) return;

    if (sendDisconnect) {
      try {
        _sendStompFrameOn(channel, 'DISCONNECT', {});
      } catch (_) {}
    }
    try {
      channel.sink.close(status.normalClosure);
    } catch (_) {}
  }

  void _onMessage(dynamic message) {
    try {
      final String messageStr = message.toString();

      if (messageStr.startsWith('CONNECTED')) {
        print('WebSocket connected successfully');
        _subscribeToNotifications();
      } else if (messageStr.startsWith('MESSAGE')) {
        _handleStompMessage(messageStr);
      } else if (messageStr.startsWith('ERROR')) {
        print('STOMP Error: $messageStr');
      }
    } catch (e) {
      print('Error processing message: $e');
    }
  }

  void _onError(dynamic error) {
    print('WebSocket Error: $error');
    _isConnected = false;
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _onDisconnect() {
    print('WebSocket disconnected');
    _isConnected = false;
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _sendStompFrame(String command, Map<String, String> headers, [String? body]) {
    if (_channel == null) return;
    _sendStompFrameOn(_channel!, command, headers, body);
  }

  void _sendStompFrameOn(
    WebSocketChannel channel,
    String command,
    Map<String, String> headers, [
    String? body,
  ]) {
    final StringBuffer frame = StringBuffer();
    frame.writeln(command);

    headers.forEach((key, value) {
      frame.writeln('$key:$value');
    });

    frame.writeln();
    if (body != null) {
      frame.write(body);
    }
    frame.write('\x00');

    channel.sink.add(frame.toString());
  }

  void _subscribeToNotifications() {
    _sendStompFrame('SUBSCRIBE', {
      'id': 'sub-1',
      'destination': '/topic/notifications',
    });

    _sendStompFrame('SUBSCRIBE', {
      'id': 'sub-2',
      'destination': '/user/queue/notifications',
    });
  }

  void _handleStompMessage(String message) {
    try {
      final lines = message.split('\n');
      String? body;

      bool foundEmptyLine = false;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].isEmpty) {
          foundEmptyLine = true;
          continue;
        }
        if (foundEmptyLine) {
          body = lines.sublist(i).join('\n').replaceAll('\x00', '');
          break;
        }
      }

      if (body != null && body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(body);
        final notification = RealtimeNotification.fromJson(data);
        if (!_notificationController.isClosed) {
          _notificationController.add(notification);
        }
      }
    } catch (e) {
      print('Error parsing notification: $e');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        _channel!.sink.add('\n');
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnection attempts reached. Stopping reconnection.');
      return;
    }

    _reconnectAttempts++;
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_intentionalDisconnect) {
        print(
          'Attempting to reconnect... (attempt $_reconnectAttempts/$_maxReconnectAttempts)',
        );
        connect();
      }
    });
  }

  void subscribeToNotifications(String subscriptionId) {
    if (_isConnected) {
      _sendStompFrame('SEND', {
        'destination': '/app/notifications/subscribe',
      }, subscriptionId);
    }
  }

  void updateAccessToken(String newToken) {
    _accessToken = newToken;
    if (_isConnected) {
      disconnect();
      connect();
    }
  }

  void dispose() {
    disconnect();
    _notificationController.close();
    _connectionController.close();
  }
}
