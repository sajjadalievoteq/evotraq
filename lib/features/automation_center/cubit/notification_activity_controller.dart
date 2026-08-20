import 'dart:async';

import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/services/automation_center/notification_api_service.dart'
    as api;
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';

typedef LoadNotificationSubscriptions = Future<void> Function({bool force});

class NotificationActivityController {
  NotificationActivityController({
    required api.NotificationApiService apiService,
    required LoadNotificationSubscriptions loadSubscriptions,
    required bool Function() subscriptionsLoading,
    required bool Function() isClosed,
    required NotificationState Function() state,
    required void Function(NotificationState) emit,
  }) : _apiService = apiService,
       _loadSubscriptions = loadSubscriptions,
       _subscriptionsLoading = subscriptionsLoading,
       _isClosed = isClosed,
       _state = state,
       _emit = emit;

  final api.NotificationApiService _apiService;
  final LoadNotificationSubscriptions _loadSubscriptions;
  final bool Function() _subscriptionsLoading;
  final bool Function() _isClosed;
  final NotificationState Function() _state;
  final void Function(NotificationState) _emit;

  static const int _deliveryActivityPageSize = 20;
  bool _deliveryActivityLoadInFlight = false;

  Future<void> loadDeliveryActivity({
    String? outcome,
    bool forceSubscriptions = false,
  }) async {
    final resolvedOutcome = outcome ?? _state().deliveryActivityOutcome;
    _emit(
      _state().copyWith(
        deliveryActivityLoading: true,
        deliveryActivityLoadingMore: false,
        deliveryActivityError: null,
        deliveryActivityOutcome: resolvedOutcome,
      ),
    );

    try {
      await _loadSubscriptions(force: forceSubscriptions);
      // If a concurrent load was in flight, wait briefly for it to settle.
      var spins = 0;
      while (_subscriptionsLoading() && !_isClosed() && spins < 40) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        spins++;
      }
      if (_isClosed()) return;

      _deliveryActivityLoadInFlight = true;
      final page = await _apiService.getDeliveryActivity(
        page: 0,
        size: _deliveryActivityPageSize,
        outcome: resolvedOutcome,
      );
      if (_isClosed()) return;
      _emit(
        _state().copyWith(
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
      if (_isClosed()) return;
      _emit(
        _state().copyWith(
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
    if (_isClosed() ||
        _deliveryActivityLoadInFlight ||
        _state().deliveryActivityLoading ||
        _state().deliveryActivityLoadingMore ||
        !_state().deliveryActivityHasMore) {
      return;
    }

    _deliveryActivityLoadInFlight = true;
    _emit(_state().copyWith(deliveryActivityLoadingMore: true));
    try {
      final nextPage = _state().deliveryActivityPage + 1;
      final page = await _apiService.getDeliveryActivity(
        page: nextPage,
        size: _deliveryActivityPageSize,
        outcome: _state().deliveryActivityOutcome,
      );
      if (_isClosed()) return;

      final seen = _state().deliveryActivity.map((e) => e.id).toSet();
      final appended = [
        ..._state().deliveryActivity,
        for (final item in page.items)
          if (!seen.contains(item.id)) item,
      ];

      _emit(
        _state().copyWith(
          deliveryActivity: appended,
          deliveryActivityLoadingMore: false,
          deliveryActivityHasMore: page.hasMore,
          deliveryActivityPage: page.page,
          deliveryActivityError: null,
        ),
      );
    } catch (e) {
      if (_isClosed()) return;
      _emit(
        _state().copyWith(
          deliveryActivityLoadingMore: false,
          deliveryActivityError: 'Failed to load more delivery events: $e',
        ),
      );
    } finally {
      _deliveryActivityLoadInFlight = false;
    }
  }

  Future<void> loadFailedBatches() async {
    if (_isClosed()) return;
    _emit(
      _state().copyWith(failedBatchesLoading: true, failedBatchesError: null),
    );
    try {
      await _loadSubscriptions();
      var spins = 0;
      while (_subscriptionsLoading() && !_isClosed() && spins < 40) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        spins++;
      }
      if (_isClosed()) return;

      final chunks = await Future.wait(
        _state().subscriptions.map(
          (sub) => _apiService.getBatchHistory(sub.id),
        ),
      );
      final failed =
          chunks.expand((e) => e).where((b) => b.isExhausted).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (_isClosed()) return;
      _emit(
        _state().copyWith(failedBatches: failed, failedBatchesLoading: false),
      );
    } catch (e) {
      if (_isClosed()) return;
      _emit(
        _state().copyWith(
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
      if (!_isClosed()) {
        _emit(
          _state().copyWith(
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
      if (!_isClosed()) {
        _emit(
          _state().copyWith(
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
      if (_isClosed()) return;
      _emit(
        _state().copyWith(
          status: NotificationStatus.success,
          lastLoadedStats: stats,
          lastLoadedStatsSubscriptionId: subscriptionId,
          error: null,
        ),
      );
    } catch (e) {
      if (_isClosed()) return;
      _emit(
        _state().copyWith(
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
}
