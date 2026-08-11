part of 'notification_cubit.dart';

extension NotificationCubitRealtime on NotificationCubit {
  /// @Deprecated — use [enableNotificationLive]. Kept for call-site migration.
  void connectWebSocket() => enableNotificationLive();

  /// Disables local notification Live without disconnecting the shared socket.
  void disconnectWebSocket() => disableNotificationLive();

  bool get isWebSocketConnected => _webSocketService.isConnected;

  bool get isNotificationLive =>
      state.notificationLiveEnabled &&
      state.connectionStatus == NotificationConnectionStatus.connected;

  void _onRealtimeNotificationReceived(Map<String, dynamic> notificationJson) {
    if (isClosed || !state.notificationLiveEnabled) return;
    try {
      final notification = RealtimeNotification.fromJson(notificationJson);
      emit(state.copyWith(lastRealtimeNotification: notification));
    } catch (error) {
      // Malformed push must not clobber subscription list status/error.
      print('Failed to process realtime notification: $error');
    }
  }
}
