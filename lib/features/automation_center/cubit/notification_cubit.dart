import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/services/automation_center/notification_api_service.dart'
    as api;
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/data/models/automation_center/realtime_notification.dart'
    hide NotificationBatch;
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';

part 'notification_cubit_realtime.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final api.NotificationApiService _apiService;
  final WebSocketService _webSocketService;
  StreamSubscription? _realtimeSubscription;
  StreamSubscription? _connectionSubscription;

  /// True once subscriptions have been fetched at least once this session.
  /// Prevents redundant re-fetches when switching between the panels that
  /// share this cubit. Manual refresh / mutations pass `force: true`.
  bool _subscriptionsLoaded = false;
  bool _loadInFlight = false;
  bool _forceReloadPending = false;

  NotificationCubit({
    required api.NotificationApiService apiService,
    required WebSocketService webSocketService,
  }) : _apiService = apiService,
       _webSocketService = webSocketService,
       super(const NotificationState()) {
    _initializeWebSocketListeners();
    _syncConnectionFromService();
  }

  void _initializeWebSocketListeners() {
    _realtimeSubscription = _webSocketService.notificationStream.listen((
      notification,
    ) {
      _onRealtimeNotificationReceived(notification.toJson());
    });
    _connectionSubscription = _webSocketService.connectionStream.listen((
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
    if (_webSocketService.isConnected) {
      emit(
        state.copyWith(
          connectionStatus: NotificationConnectionStatus.connected,
        ),
      );
    } else if (_webSocketService.isConnecting) {
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

  static const int _deliveryActivityPageSize = 20;

  bool _deliveryActivityLoadInFlight = false;

  /// Loads per-event delivery history across all subscriptions for Activity.
  ///
  /// Pass [outcome] to match Activity filter chips (`all` | `delivered` |
  /// `failed` | `pending`). Resets to page 0.
  Future<void> loadDeliveryActivity({
    String? outcome,
    bool forceSubscriptions = false,
  }) async {
    final resolvedOutcome = outcome ?? state.deliveryActivityOutcome;
    emit(
      state.copyWith(
        deliveryActivityLoading: true,
        deliveryActivityLoadingMore: false,
        deliveryActivityError: null,
        deliveryActivityOutcome: resolvedOutcome,
      ),
    );

    try {
      await loadSubscriptions(force: forceSubscriptions);
      // If a concurrent load was in flight, wait briefly for it to settle.
      var spins = 0;
      while (_loadInFlight && !isClosed && spins < 40) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        spins++;
      }
      if (isClosed) return;

      _deliveryActivityLoadInFlight = true;
      final page = await _apiService.getDeliveryActivity(
        page: 0,
        size: _deliveryActivityPageSize,
        outcome: resolvedOutcome,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          deliveryActivity: page.items,
          deliveryActivityLoading: false,
          deliveryActivityLoadingMore: false,
          deliveryActivityHasMore: page.hasMore,
          deliveryActivityPage: page.page,
          deliveryActivityOutcome: resolvedOutcome,
          deliveryActivityError: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          deliveryActivityLoading: false,
          deliveryActivityLoadingMore: false,
          deliveryActivityError: 'Failed to load delivery events: $e',
        ),
      );
    } finally {
      _deliveryActivityLoadInFlight = false;
    }
  }

  /// Appends the next Activity page when the user scrolls near the end.
  Future<void> loadMoreDeliveryActivity() async {
    if (isClosed ||
        _deliveryActivityLoadInFlight ||
        state.deliveryActivityLoading ||
        state.deliveryActivityLoadingMore ||
        !state.deliveryActivityHasMore) {
      return;
    }

    _deliveryActivityLoadInFlight = true;
    emit(state.copyWith(deliveryActivityLoadingMore: true));
    try {
      final nextPage = state.deliveryActivityPage + 1;
      final page = await _apiService.getDeliveryActivity(
        page: nextPage,
        size: _deliveryActivityPageSize,
        outcome: state.deliveryActivityOutcome,
      );
      if (isClosed) return;

      final seen = state.deliveryActivity.map((e) => e.id).toSet();
      final appended = [
        ...state.deliveryActivity,
        for (final item in page.items)
          if (!seen.contains(item.id)) item,
      ];

      emit(
        state.copyWith(
          deliveryActivity: appended,
          deliveryActivityLoadingMore: false,
          deliveryActivityHasMore: page.hasMore,
          deliveryActivityPage: page.page,
          deliveryActivityError: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          deliveryActivityLoadingMore: false,
          deliveryActivityError: 'Failed to load more delivery events: $e',
        ),
      );
    } finally {
      _deliveryActivityLoadInFlight = false;
    }
  }

  Future<void> loadFailedBatches() async {
    if (isClosed) return;
    emit(state.copyWith(failedBatchesLoading: true, failedBatchesError: null));
    try {
      await loadSubscriptions();
      var spins = 0;
      while (_loadInFlight && !isClosed && spins < 40) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        spins++;
      }
      if (isClosed) return;

      final chunks = await Future.wait(
        state.subscriptions.map((sub) => _apiService.getBatchHistory(sub.id)),
      );
      final failed =
          chunks.expand((e) => e).where((b) => b.isExhausted).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (isClosed) return;
      emit(state.copyWith(failedBatches: failed, failedBatchesLoading: false));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          failedBatchesLoading: false,
          failedBatchesError: 'Failed to load failed batches: $e',
        ),
      );
    }
  }

  Future<void> retryBatch(String batchId) async {
    try {
      await _apiService.retryBatch(batchId);
      // Refresh both activity and failed batches
      await loadDeliveryActivity(forceSubscriptions: false);
      await loadFailedBatches();
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: NotificationStatus.error,
            error: e is ApiException
                ? e.getUserFriendlyMessage()
                : "Couldn't retry this batch. Please try again.",
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> retryWebhook(String notificationId) async {
    try {
      await _apiService.retryWebhook(notificationId);
      await loadDeliveryActivity(forceSubscriptions: false);
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: NotificationStatus.error,
            error: e is ApiException
                ? e.getUserFriendlyMessage()
                : "Couldn't retry this delivery. Please try again.",
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> loadSubscriptionStats(String subscriptionId) async {
    try {
      final stats = await _apiService.getSubscriptionStats(subscriptionId);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          lastLoadedStats: stats,
          lastLoadedStatsSubscriptionId: subscriptionId,
          error: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          error: 'Failed to load subscription stats: $e',
        ),
      );
    }
  }

  /// Ensures the shared application socket is connecting/connected and enables
  /// local Delivery Activity consumption of notification pushes.
  ///
  /// Does not claim ownership of the shared [WebSocketService]; never disconnects it.
  void enableNotificationLive() {
    if (isClosed) return;
    emit(
      state.copyWith(
        notificationLiveEnabled: true,
        connectionStatus: _webSocketService.isConnected
            ? NotificationConnectionStatus.connected
            : NotificationConnectionStatus.connecting,
      ),
    );
    _webSocketService.connect();
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
