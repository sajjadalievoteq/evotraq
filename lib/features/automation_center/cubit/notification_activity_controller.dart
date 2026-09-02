import 'dart:async';

import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/data/services/automation_center/notification_api_service.dart'
    as api;
import 'package:traqtrace_app/features/automation_center/cubit/activity_feed_memory.dart';
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

  static const int _pageSize = ActivityFeedMemory.pageSize;
  bool _deliveryActivityLoadInFlight = false;
  bool _failedBatchesLoadInFlight = false;

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
      var spins = 0;
      while (_subscriptionsLoading() && !_isClosed() && spins < 40) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        spins++;
      }
      if (_isClosed()) return;

      _deliveryActivityLoadInFlight = true;
      final page = await _apiService.getDeliveryActivity(
        page: 0,
        size: _pageSize,
        outcome: resolvedOutcome,
      );
      if (_isClosed()) return;
      _emit(
        _state().copyWith(
          deliveryActivity: ActivityFeedMemory.trimNewestSide(page.items),
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
        size: _pageSize,
        outcome: _state().deliveryActivityOutcome,
      );
      if (_isClosed()) return;

      final appended = ActivityFeedMemory.appendBounded(
        existing: _state().deliveryActivity,
        incoming: page.items,
        idOf: (e) => e.id,
      );

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
      _state().copyWith(
        failedBatchesLoading: true,
        failedBatchesLoadingMore: false,
        failedBatchesError: null,
      ),
    );
    try {
      await _loadSubscriptions();
      var spins = 0;
      while (_subscriptionsLoading() && !_isClosed() && spins < 40) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        spins++;
      }
      if (_isClosed()) return;

      _failedBatchesLoadInFlight = true;
      final page = await _loadExhaustedPage(page: 0);
      if (_isClosed()) return;
      _emit(
        _state().copyWith(
          failedBatches: ActivityFeedMemory.trimNewestSide(page.items),
          failedBatchesLoading: false,
          failedBatchesLoadingMore: false,
          failedBatchesHasMore: page.hasMore,
          failedBatchesPage: page.page,
          failedBatchesError: null,
        ),
      );
    } catch (e) {
      if (_isClosed()) return;
      _emit(
        _state().copyWith(
          failedBatchesLoading: false,
          failedBatchesLoadingMore: false,
          failedBatchesError: 'Failed to load failed batches: $e',
        ),
      );
    } finally {
      _failedBatchesLoadInFlight = false;
    }
  }

  Future<void> loadMoreFailedBatches() async {
    if (_isClosed() ||
        _failedBatchesLoadInFlight ||
        _state().failedBatchesLoading ||
        _state().failedBatchesLoadingMore ||
        !_state().failedBatchesHasMore) {
      return;
    }

    _failedBatchesLoadInFlight = true;
    _emit(_state().copyWith(failedBatchesLoadingMore: true));
    try {
      final nextPage = _state().failedBatchesPage + 1;
      final page = await _loadExhaustedPage(page: nextPage);
      if (_isClosed()) return;

      final appended = ActivityFeedMemory.appendBounded(
        existing: _state().failedBatches,
        incoming: page.items,
        idOf: (b) => b.id,
      );

      _emit(
        _state().copyWith(
          failedBatches: appended,
          failedBatchesLoadingMore: false,
          failedBatchesHasMore: page.hasMore,
          failedBatchesPage: page.page,
          failedBatchesError: null,
        ),
      );
    } catch (e) {
      if (_isClosed()) return;
      _emit(
        _state().copyWith(
          failedBatchesLoadingMore: false,
          failedBatchesError: 'Failed to load more failed batches: $e',
        ),
      );
    } finally {
      _failedBatchesLoadInFlight = false;
    }
  }

  Future<({List<NotificationBatch> items, bool hasMore, int page})>
  _loadExhaustedPage({required int page}) async {
    try {
      return await _apiService.getExhaustedBatches(page: page, size: _pageSize);
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 405) {
        return _legacyExhaustedFallback(page: page);
      }
      rethrow;
    }
  }

  Future<({List<NotificationBatch> items, bool hasMore, int page})>
  _legacyExhaustedFallback({required int page}) async {
    if (page > 0) {
      return (items: <NotificationBatch>[], hasMore: false, page: page);
    }
    final chunks = await Future.wait(
      _state().subscriptions.map((sub) => _apiService.getBatchHistory(sub.id)),
    );
    final failed =
        chunks.expand((e) => e).where((b) => b.isExhausted).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final bounded = ActivityFeedMemory.trimNewestSide(failed);
    return (items: bounded, hasMore: failed.length > bounded.length, page: 0);
  }

  Future<void> retryBatch(String batchId) async {
    try {
      await _apiService.retryBatch(batchId);
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
}
