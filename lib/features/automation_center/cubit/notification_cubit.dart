import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/automation_center/notification_api_service.dart' as api;
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/data/models/automation_center/realtime_notification.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final api.NotificationApiService _apiService;
  final WebSocketService _webSocketService;
  StreamSubscription? _realtimeSubscription;
  StreamSubscription? _connectionSubscription;

  /// True once subscriptions have been fetched at least once this session.
  /// Prevents redundant re-fetches when switching between the panels that
  /// share this cubit. Manual refresh / mutations pass `force: true`.
  bool _subscriptionsLoaded = false;

  NotificationCubit({
    required api.NotificationApiService apiService,
    required WebSocketService webSocketService,
  })  : _apiService = apiService,
        _webSocketService = webSocketService,
        super(const NotificationState()) {
    _initializeWebSocketListeners();
  }

  void _initializeWebSocketListeners() {
    _realtimeSubscription = _webSocketService.notificationStream.listen(
      (notification) {
        _onRealtimeNotificationReceived(notification.toJson());
      },
    );
    _connectionSubscription = _webSocketService.connectionStream.listen(
      (connected) {
        emit(state.copyWith(
          status: connected
              ? NotificationStatus.webSocketConnected
              : NotificationStatus.webSocketDisconnected,
        ));
      },
    );
  }

  Future<void> loadSubscriptions({bool force = false}) async {
    // Skip redundant fetches: load once on entry, then serve cached data when
    // switching panels. A load already in flight is also skipped. `force` (Refresh
    // button, auto-refresh, and post-mutation reloads) always re-fetches.
    if (!force &&
        (_subscriptionsLoaded ||
            state.status == NotificationStatus.loading)) {
      return;
    }
    try {
      emit(state.copyWith(status: NotificationStatus.loading));
      // Backend returns the full active list (no server-side paging).
      final subscriptions = await _apiService.getSubscriptions();

      _subscriptionsLoaded = true;
      emit(state.copyWith(
        status: NotificationStatus.success,
        subscriptions: subscriptions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to load subscriptions: $e',
      ));
    }
  }

  Future<void> loadSubscription(String id) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));
      final subscription = await _apiService.getSubscription(id);
      emit(state.copyWith(
        status: NotificationStatus.success,
        selectedSubscription: subscription,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to load subscription: $e',
      ));
    }
  }

  Future<void> createSubscription({
    required String subscriptionName,
    required String webhookUrl,
    required String subscriptionType,
    String? deliveryMethod,
    String? notificationFormat,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));
      final request = CreateSubscriptionRequest(
        subscriptionName: subscriptionName,
        webhookUrl: webhookUrl,
        subscriptionType: subscriptionType,
        deliveryMethod: deliveryMethod,
        notificationFormat: notificationFormat,
        queryParameters: queryParameters,
      );

      final subscription = await _apiService.createSubscription(request);
      emit(state.copyWith(
        status: NotificationStatus.subscriptionCreated,
        lastCreatedSubscription: subscription,
      ));

      await loadSubscriptions(force: true);
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to create subscription: $e',
      ));
    }
  }

  Future<void> updateSubscription({
    required String id,
    required String subscriptionName,
    required String webhookUrl,
    required String subscriptionType,
    String? deliveryMethod,
    String? notificationFormat,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));
      final request = CreateSubscriptionRequest(
        subscriptionName: subscriptionName,
        webhookUrl: webhookUrl,
        subscriptionType: subscriptionType,
        deliveryMethod: deliveryMethod,
        notificationFormat: notificationFormat,
        queryParameters: queryParameters,
      );

      final subscription = await _apiService.updateSubscription(id, request);
      emit(state.copyWith(
        status: NotificationStatus.subscriptionUpdated,
        lastUpdatedSubscription: subscription,
      ));

      await loadSubscriptions(force: true);
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to update subscription: $e',
      ));
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      await _apiService.deleteSubscription(id);
      emit(state.copyWith(
        status: NotificationStatus.subscriptionDeleted,
        lastDeletedSubscriptionId: id,
      ));

      await loadSubscriptions(force: true);
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to delete subscription: $e',
      ));
    }
  }

  Future<void> pauseSubscription(String id) async {
    try {
      await _apiService.pauseSubscription(id);
      await loadSubscriptions(force: true);
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to pause subscription: $e',
      ));
    }
  }

  Future<void> resumeSubscription(String id) async {
    try {
      await _apiService.resumeSubscription(id);
      await loadSubscriptions(force: true);
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to resume subscription: $e',
      ));
    }
  }

  Future<void> testWebhook(String webhookUrl) async {
    try {
      final result = await _apiService.testWebhook(webhookUrl);
      emit(state.copyWith(
        status: NotificationStatus.success,
        webhookTestResult: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to test webhook: $e',
      ));
    }
  }

  Future<void> testEmail(String emailAddress) async {
    try {
      final result = await _apiService.testEmail(emailAddress);
      emit(state.copyWith(
        status: NotificationStatus.success,
        emailTestResult: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to test email: $e',
      ));
    }
  }

  Future<void> loadWebhookHistory(String subscriptionId, {int page = 0, int size = 20}) async {
    try {
      final webhookHistory = await _apiService.getWebhookHistory(
        subscriptionId,
        page: page,
        size: size,
      );

      emit(state.copyWith(
        status: NotificationStatus.success,
        webhookHistory: webhookHistory,
        lastLoadedHistorySubscriptionId: subscriptionId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to load webhook history: $e',
      ));
    }
  }

  Future<void> loadSubscriptionStats(String subscriptionId) async {
    try {
      final stats = await _apiService.getSubscriptionStats(subscriptionId);
      emit(state.copyWith(
        status: NotificationStatus.success,
        lastLoadedStats: stats,
        lastLoadedStatsSubscriptionId: subscriptionId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to load subscription stats: $e',
      ));
    }
  }

  void connectWebSocket() {
    try {
      _webSocketService.connect();
      emit(state.copyWith(status: NotificationStatus.webSocketConnected));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to connect to WebSocket: $e',
      ));
    }
  }

  void disconnectWebSocket() {
    try {
      _webSocketService.disconnect();
      emit(state.copyWith(status: NotificationStatus.webSocketDisconnected));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to disconnect from WebSocket: $e',
      ));
    }
  }

  bool get isWebSocketConnected => _webSocketService.isConnected;

  void _onRealtimeNotificationReceived(Map<String, dynamic> notificationJson) {
    try {
      final notification = RealtimeNotification.fromJson(notificationJson);
      emit(state.copyWith(
        status: NotificationStatus.success,
        lastRealtimeNotification: notification,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: 'Failed to process realtime notification: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    
    return super.close();
  }
}
