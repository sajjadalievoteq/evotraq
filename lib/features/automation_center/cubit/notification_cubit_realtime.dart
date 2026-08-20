import 'package:traqtrace_app/data/models/automation_center/realtime_notification.dart'
    hide NotificationBatch;
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';

extension NotificationCubitRealtime on NotificationCubit {
  /// @Deprecated — use [enableNotificationLive]. Kept for call-site migration.
  void connectWebSocket() => enableNotificationLive();

  /// Disables local notification Live without disconnecting the shared socket.
  void disconnectWebSocket() => disableNotificationLive();

  bool get isWebSocketConnected => webSocketService.isConnected;

  bool get isNotificationLive =>
      state.notificationLiveEnabled &&
      state.connectionStatus == NotificationConnectionStatus.connected;

  void onRealtimeNotificationReceived(Map<String, dynamic> notificationJson) {
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
