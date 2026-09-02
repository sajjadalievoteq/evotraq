import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/data/models/automation_center/realtime_notification.dart';

typedef WebSocketChannelFactory =
    WebSocketChannel Function(Uri uri, Iterable<String> protocols);

class WebSocketService {
  
  WebSocketService({
    TokenManager? tokenManager,
    String? baseUrl,
    WebSocketChannelFactory? channelFactory,
  }) : _tokenManager = tokenManager,
       _baseUrl = baseUrl,
       _channelFactory = channelFactory ?? _defaultChannelFactory;

  final TokenManager? _tokenManager;
  final WebSocketChannelFactory _channelFactory;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  final StreamController<RealtimeNotification> _notificationController =
      StreamController<RealtimeNotification>.broadcast();
  final StreamController<Map<String, dynamic>> _jobQueueController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _dashboardController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  String? _baseUrl;
  String? _accessToken;
  bool _isConnected = false;
  bool _connecting = false;
  bool _intentionalDisconnect = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  void Function()? onAuthenticationFailed;

  static const int _baseReconnectSeconds = 2;
  static const int _maxReconnectSeconds = 30;
  final Random _random = Random();

  Stream<RealtimeNotification> get notificationStream =>
      _notificationController.stream;

  Stream<Map<String, dynamic>> get jobQueueEventStream =>
      _jobQueueController.stream;

  Stream<Map<String, dynamic>> get dashboardSummaryStream =>
      _dashboardController.stream;

  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;

  bool get isConnecting => _connecting;

  void initialize(String baseUrl, String accessToken) {
    _baseUrl = baseUrl;
    if (accessToken.isNotEmpty) {
      _accessToken = accessToken;
    }
  }

  static WebSocketChannel _defaultChannelFactory(
    Uri uri,
    Iterable<String> protocols,
  ) => WebSocketChannel.connect(uri, protocols: protocols);

  void connect() {
    unawaited(_connect());
  }

  Future<void> _connect() async {
    
    if (_isConnected || _connecting) {
      return;
    }
    _connecting = true;
    _intentionalDisconnect = false;
    _teardownChannel(sendDisconnect: false);

    try {
      final baseUrl = _baseUrl?.trim();
      if (baseUrl == null || baseUrl.isEmpty) {
        _reportConnectionFailure('WebSocket service is not configured');
        return;
      }

      final stored = await _tokenManager?.getToken();
      if (stored != null && stored.isNotEmpty) {
        _accessToken = stored;
      }

      if (_accessToken == null || _accessToken!.isEmpty) {
        _reportConnectionFailure('No authentication token is available');
        return;
      }

      final wsUrl = '${baseUrl.replaceFirst('http', 'ws')}/ws';

      _channel = _channelFactory(Uri.parse(wsUrl), const [
        'v10.stomp',
        'v11.stomp',
        'v12.stomp',
      ]);

      _channelSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnect,
      );

      _sendStompFrame('CONNECT', {
        'accept-version': '1.0,1.1,1.2',
        'heart-beat': '10000,10000',
        'Authorization': 'Bearer ${_accessToken ?? ''}',
      });
      
    } catch (e) {
      _reportConnectionFailure(e.toString());
      _scheduleReconnect();
    }
  }

  void _reportConnectionFailure(String _) {
    _connecting = false;
    _isConnected = false;
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
  }

  void disconnect() {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _connecting = false;
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
        _connecting = false;
        _isConnected = true;
        _reconnectAttempts = 0;
        if (!_connectionController.isClosed) {
          _connectionController.add(true);
        }
        _startHeartbeat();
        _subscribeToTopics();
      } else if (messageStr.startsWith('MESSAGE')) {
        _handleStompMessage(messageStr);
      } else if (messageStr.startsWith('ERROR')) {
        _handleStompError(messageStr);
      }
    } catch (_) {}
  }

  void _handleStompError(String messageStr) {
    _connecting = false;
    _isConnected = false;
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }

    final lower = messageStr.toLowerCase();
    final authFailure =
        lower.contains('unauthorized') ||
        lower.contains('authentication') ||
        lower.contains('access denied') ||
        lower.contains('invalid token') ||
        lower.contains('expired') ||
        lower.contains('401');

    if (authFailure) {
      
      _intentionalDisconnect = true;
      _reconnectTimer?.cancel();
      onAuthenticationFailed?.call();
      return;
    }

    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _onError(dynamic _) {
    _connecting = false;
    _isConnected = false;
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _onDisconnect() {
    _connecting = false;
    _isConnected = false;
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _sendStompFrame(
    String command,
    Map<String, String> headers, [
    String? body,
  ]) {
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

  void _subscribeToTopics() {
    _sendStompFrame('SUBSCRIBE', {
      'id': 'sub-1',
      'destination': '/topic/notifications',
    });

    _sendStompFrame('SUBSCRIBE', {
      'id': 'sub-2',
      'destination': '/user/queue/notifications',
    });

    _sendStompFrame('SUBSCRIBE', {
      'id': 'sub-3',
      'destination': '/topic/job-queue/dashboard',
    });

    _sendStompFrame('SUBSCRIBE', {
      'id': 'sub-4',
      'destination': '/topic/dashboard/summary',
    });
  }

  void _handleStompMessage(String message) {
    try {
      final lines = message.split('\n');
      final headers = <String, String>{};
      String? body;

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i];
        if (line.isEmpty) {
          body = lines.sublist(i + 1).join('\n').replaceAll('\x00', '');
          break;
        }
        final idx = line.indexOf(':');
        if (idx > 0) {
          headers[line.substring(0, idx)] = line
              .substring(idx + 1)
              .replaceAll('\r', '');
        }
      }

      if (body == null || body.isEmpty) return;

      final destination = headers['destination'] ?? '';
      final Map<String, dynamic> data = json.decode(body);

      if (destination.startsWith('/topic/job-queue')) {
        if (!_jobQueueController.isClosed) {
          _jobQueueController.add(data);
        }
      } else if (destination.startsWith('/topic/dashboard')) {
        if (!_dashboardController.isClosed) {
          _dashboardController.add(data);
        }
      } else {
        final notification = RealtimeNotification.fromJson(data);
        if (!_notificationController.isClosed) {
          _notificationController.add(notification);
        }
      }
    } catch (_) {}
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        _channel!.sink.add('\n');
      }
    });
  }

  static int reconnectBackoffCeilingSeconds(int attempt) {
    final exponent = min(
      (attempt < 1 ? 0 : attempt - 1),
      5,
    ); 
    return min(_baseReconnectSeconds * (1 << exponent), _maxReconnectSeconds);
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    final backoffSeconds = reconnectBackoffCeilingSeconds(_reconnectAttempts);
    final delayMs = (_random.nextDouble() * backoffSeconds * 1000).round();

    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!_isConnected && !_intentionalDisconnect) {
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
    if (_isConnected || _connecting) {
      disconnect();
      connect();
    }
  }

  void dispose() {
    disconnect();
    _notificationController.close();
    _jobQueueController.close();
    _dashboardController.close();
    _connectionController.close();
  }
}
