import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/automation_center/notification_api_service.dart'
    as api;
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_activity_controller.dart';

import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit_realtime.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final api.NotificationApiService _apiService;
  final WebSocketService webSocketService;
  StreamSubscription? _realtimeSubscription;
  StreamSubscription? _connectionSubscription;

  /// True once subscriptions have been fetched at least once this session.
  /// Prevents redundant re-fetches when switching between the panels that
  /// share this cubit. Manual refresh / mutations pass `force: true`.
  bool _subscriptionsLoaded = false;
  bool _loadInFlight = false;
  bool _forceReloadPending = false;
  late final NotificationActivityController _activityController;

  NotificationCubit({
    required api.NotificationApiService apiService,
    required WebSocketService webSocketService,
  }) : _apiService = apiService,
       webSocketService = webSocketService,
       super(const NotificationState()) {
    _activityController = NotificationActivityController(
      apiService: _apiService,
      loadSubscriptions: loadSubscriptions,
      subscriptionsLoading: () => _loadInFlight,
      isClosed: () => isClosed,
      state: () => state,
      emit: emit,
    );
    _initializeWebSocketListeners();
    _syncConnectionFromService();
  }

  void _initializeWebSocketListeners() {
    _realtimeSubscription = webSocketService.notificationStream.listen((
      notification,
    ) {
      onRealtimeNotificationReceived(notification.toJson());
    });
    _connectionSubscription = webSocketService.connectionStream.listen((
      connected,
    ) {
      if (isClosed) return;
      if (connected) {
        emit(
          state.copyWith(
            connectionStatus: NotificationConnectionStatus.connected,
          ),
        );
      } else if (state.connectionStatus ==
          NotificationConnectionStatus.connecting) {
        emit(
          state.copyWith(connectionStatus: NotificationConnectionStatus.failed),
        );
      } else {
        emit(
          state.copyWith(
            connectionStatus: NotificationConnectionStatus.disconnected,
          ),
        );
      }
    });
  }

  void _syncConnectionFromService() {
    if (webSocketService.isConnected) {
      emit(
        state.copyWith(
          connectionStatus: NotificationConnectionStatus.connected,
        ),
      );
    } else if (webSocketService.isConnecting) {
      emit(
        state.copyWith(
          connectionStatus: NotificationConnectionStatus.connecting,
        ),
      );
    }
  }

  Future<void> loadSubscriptions({bool force = false}) async {
    // Skip redundant fetches: load once on entry, then serve cached data when
    // switching panels. A load already in flight is also skipped. `force` (Refresh
    // button and post-mutation reloads) always re-fetches.
    // One in-flight fetch at a time (covers force-refresh races too).
    if (_loadInFlight) {
      // A mutation/manual refresh racing the initial load must not be lost.
      // Coalesce any number of forced requests into exactly one follow-up.
      if (force) _forceReloadPending = true;
      return;
    }
    if (!force && _subscriptionsLoaded) return;
    _loadInFlight = true;
    try {
      if (!isClosed) {
        emit(state.copyWith(status: NotificationStatus.loading));
      }
      // Backend returns the full active list (no server-side paging).
      final subscriptions = await _apiService.getSubscriptions();

      _subscriptionsLoaded = true;
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          subscriptions: subscriptions,
          error: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          error: 'Failed to load subscriptions: $e',
        ),
      );
    } finally {
      _loadInFlight = false;
      if (_forceReloadPending && !isClosed) {
        _forceReloadPending = false;
        unawaited(loadSubscriptions(force: true));
      }
    }
  }

  Future<void> loadSubscription(String id) async {
    try {
      if (!isClosed) {
        emit(state.copyWith(status: NotificationStatus.loading));
      }
      final subscription = await _apiService.getSubscription(id);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          selectedSubscription: subscription,
          error: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          error: 'Failed to load subscription: $e',
        ),
      );
    }
  }

  Future<void> createSubscription({
    required String subscriptionName,
    required String webhookUrl,
    required String subscriptionType,
    String? deliveryMethod,
    String? notificationFormat,
    String? notificationFrequency,
    int? maxEventsPerNotification,
    int? preferredHour,
    int? preferredMinute,
    Map<String, dynamic>? queryParameters,
    String? webhookAuthUsername,
    String? webhookAuthPassword,
  }) async {
    try {
      if (!isClosed) {
        emit(state.copyWith(status: NotificationStatus.loading));
      }
      final request = CreateSubscriptionRequest(
        subscriptionName: subscriptionName,
        webhookUrl: webhookUrl,
        subscriptionType: subscriptionType,
        deliveryMethod: deliveryMethod,
        notificationFormat: notificationFormat,
        notificationFrequency: notificationFrequency,
        maxEventsPerNotification: maxEventsPerNotification,
        preferredHour: preferredHour,
        preferredMinute: preferredMinute,
        queryParameters: queryParameters,
        webhookAuthUsername: webhookAuthUsername,
        webhookAuthPassword: webhookAuthPassword,
      );

      final subscription = await _apiService.createSubscription(request);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.subscriptionCreated,
          lastCreatedSubscription: subscription,
          error: null,
        ),
      );

      await loadSubscriptions(force: true);
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          error: 'Failed to create subscription: $e',
        ),
      );
    }
  }

  Future<void> updateSubscription({
    required String id,
    required String subscriptionName,
    required String webhookUrl,
    required String subscriptionType,
    String? deliveryMethod,
    String? notificationFormat,
    String? notificationFrequency,
    int? maxEventsPerNotification,
    int? preferredHour,
    int? preferredMinute,
    Map<String, dynamic>? queryParameters,
    String? webhookAuthUsername,
    String? webhookAuthPassword,
  }) async {
    try {
      if (!isClosed) {
        emit(state.copyWith(status: NotificationStatus.loading));
      }
      final request = CreateSubscriptionRequest(
        subscriptionName: subscriptionName,
        webhookUrl: webhookUrl,
        subscriptionType: subscriptionType,
        deliveryMethod: deliveryMethod,
        notificationFormat: notificationFormat,
        notificationFrequency: notificationFrequency,
        maxEventsPerNotification: maxEventsPerNotification,
        preferredHour: preferredHour,
        preferredMinute: preferredMinute,
        queryParameters: queryParameters,
        webhookAuthUsername: webhookAuthUsername,
        webhookAuthPassword: webhookAuthPassword,
      );

      final subscription = await _apiService.updateSubscription(id, request);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.subscriptionUpdated,
          lastUpdatedSubscription: subscription,
          error: null,
        ),
      );

      await loadSubscriptions(force: true);
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          error: 'Failed to update subscription: $e',
        ),
      );
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      await _apiService.deleteSubscription(id);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.subscriptionDeleted,
          lastDeletedSubscriptionId: id,
          error: null,
        ),
      );

      await loadSubscriptions(force: true);
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          error: 'Failed to delete subscription: $e',
        ),
      );
    }
  }

  Future<void> pauseSubscription(String id) async {
    try {
      await _apiService.pauseSubscription(id);
      await loadSubscriptions(force: true);
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          error: 'Failed to pause subscription: $e',
        ),
      );
    }
  }

  Future<void> resumeSubscription(String id) async {
    try {
      await _apiService.resumeSubscription(id);
      await loadSubscriptions(force: true);
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          error: 'Failed to resume subscription: $e',
        ),
      );
    }
  }

  Future<void> testWebhook(String webhookUrl) async {
    try {
      final result = await _apiService.testWebhook(webhookUrl);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          webhookTestResult: result,
          error: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          error: 'Failed to test webhook: $e',
        ),
      );
    }
  }

  Future<void> testEmail(String emailAddress) async {
    try {
      final result = await _apiService.testEmail(emailAddress);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          emailTestResult: result,
          error: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          error: 'Failed to test email: $e',
        ),
      );
    }
  }

  Future<void> loadDeliveryActivity({
    String? outcome,
    bool forceSubscriptions = false,
  }) => _activityController.loadDeliveryActivity(
    outcome: outcome,
    forceSubscriptions: forceSubscriptions,
  );

  Future<void> loadMoreDeliveryActivity() =>
      _activityController.loadMoreDeliveryActivity();

  Future<void> loadFailedBatches() => _activityController.loadFailedBatches();

  Future<void> retryBatch(String batchId) =>
      _activityController.retryBatch(batchId);

  Future<void> retryWebhook(String notificationId) =>
      _activityController.retryWebhook(notificationId);

  Future<void> loadSubscriptionStats(String subscriptionId) =>
      _activityController.loadSubscriptionStats(subscriptionId);

  void enableNotificationLive() {
    if (isClosed) return;
    emit(
      state.copyWith(
        notificationLiveEnabled: true,
        connectionStatus: webSocketService.isConnected
            ? NotificationConnectionStatus.connected
            : NotificationConnectionStatus.connecting,
      ),
    );
    webSocketService.connect();
  }

  /// Stops applying notification pushes locally. Job-queue and home consumers
  /// keep using the shared socket.
  void disableNotificationLive() {
    if (isClosed) return;
    emit(state.copyWith(notificationLiveEnabled: false));
  }

  void setNotificationLive(bool enabled) {
    if (enabled) {
      enableNotificationLive();
    } else {
      disableNotificationLive();
    }
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    // Never disconnect the shared WebSocketService singleton here.
    return super.close();
  }
}
