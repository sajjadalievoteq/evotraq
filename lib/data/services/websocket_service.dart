import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:traqtrace_app/features/notifications/domain/models/realtime_notification.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<RealtimeNotification> _notificationController =
      StreamController<RealtimeNotification>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  String? _baseUrl;
  String? _accessToken;
  bool _isConnected = false;
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

    // Reset reconnect attempts when manually connecting
    _reconnectAttempts = 0;

    try {
      final wsUrl = _baseUrl!.replaceFirst('http', 'ws') + '/ws';
      
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['v10.stomp', 'v11.stomp', 'v12.stomp'],
      );

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnect,
      );

      // Send STOMP CONNECT frame
      _sendStompFrame('CONNECT', {
        'accept-version': '1.0,1.1,1.2',
        'heart-beat': '10000,10000',
        'Authorization': 'Bearer $_accessToken',
      });

      _isConnected = true;
      _connectionController.add(true);
      _reconnectAttempts = 0; // Reset reconnect attempts on successful connection
      _startHeartbeat();

    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _connectionController.add(false);
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    
    if (_channel != null) {
      _sendStompFrame('DISCONNECT', {});
      _channel!.sink.close(status.normalClosure);
    }
    
    _isConnected = false;
    _connectionController.add(false);
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

  void _onError(error) {
    print('WebSocket Error: $error');
    _isConnected = false;
    _connectionController.add(false);
    _scheduleReconnect();
  }

  void _onDisconnect() {
    print('WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(false);
    _scheduleReconnect();
  }

  void _sendStompFrame(String command, Map<String, String> headers, [String? body]) {
    if (_channel == null) return;

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

    _channel!.sink.add(frame.toString());
  }

  void _subscribeToNotifications() {
    // Subscribe to general notifications
    _sendStompFrame('SUBSCRIBE', {
      'id': 'sub-1',
      'destination': '/topic/notifications',
    });

    // Subscribe to user-specific notifications
    _sendStompFrame('SUBSCRIBE', {
      'id': 'sub-2',
      'destination': '/user/queue/notifications',
    });
  }

  void _handleStompMessage(String message) {
    try {
      final lines = message.split('\n');
      String? body;
      
      // Find the message body (after the empty line)
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
        _notificationController.add(notification);
      }
    } catch (e) {
      print('Error parsing notification: $e');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        _channel!.sink.add('\n');
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    
    // Don't reconnect if we've exceeded max attempts
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnection attempts reached. Stopping reconnection.');
      return;
    }
    
    _reconnectAttempts++;
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (!_isConnected) {
        print('Attempting to reconnect... (attempt $_reconnectAttempts/$_maxReconnectAttempts)');
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
