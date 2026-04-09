import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/notification_api_service.dart' as api;
import '../../data/services/websocket_service.dart';
import '../../domain/models/notification_subscription.dart';
import '../../domain/models/realtime_notification.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final api.NotificationApiService _apiService;
  final WebSocketService _webSocketService;
  StreamSubscription? _realtimeSubscription;

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
  }

  Future<void> loadSubscriptions({int page = 0, int size = 20}) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));
      final subscriptions = await _apiService.getSubscriptions(
        page: page,
        size: size,
      );

      emit(state.copyWith(
        status: NotificationStatus.success,
        subscriptions: subscriptions,
        hasReachedMax: subscriptions.length < size,
        currentPage: page,
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
    String? notificationFormat,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));
      final request = CreateSubscriptionRequest(
        subscriptionName: subscriptionName,
        webhookUrl: webhookUrl,
        subscriptionType: subscriptionType,
        notificationFormat: notificationFormat,
        queryParameters: queryParameters,
      );

      final subscription = await _apiService.createSubscription(request);
      emit(state.copyWith(
        status: NotificationStatus.subscriptionCreated,
        lastCreatedSubscription: subscription,
      ));

      // Reload subscriptions
      await loadSubscriptions();
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
    String? notificationFormat,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));
      final request = CreateSubscriptionRequest(
        subscriptionName: subscriptionName,
        webhookUrl: webhookUrl,
        subscriptionType: subscriptionType,
        notificationFormat: notificationFormat,
        queryParameters: queryParameters,
      );

      final subscription = await _apiService.updateSubscription(id, request);
      emit(state.copyWith(
        status: NotificationStatus.subscriptionUpdated,
        lastUpdatedSubscription: subscription,
      ));

      // Reload subscriptions
      await loadSubscriptions();
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

      // Reload subscriptions
      await loadSubscriptions();
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
      // Reload subscriptions to reflect the new status
      await loadSubscriptions();
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
      // Reload subscriptions to reflect the new status
      await loadSubscriptions();
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
    _webSocketService.dispose();
    return super.close();
  }
}
