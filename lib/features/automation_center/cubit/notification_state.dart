import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/data/models/automation_center/realtime_notification.dart'
    hide NotificationBatch;

/// Subscription list / detail load operations (independent of socket + mutations).
enum NotificationStatus {
  initial,
  loading,
  success,
  error,
  subscriptionCreated,
  subscriptionUpdated,
  subscriptionDeleted,
}

/// Shared-socket connection progress for Delivery Activity UI.
enum NotificationConnectionStatus {
  disconnected,
  connecting,
  connected,
  failed,
}

class NotificationState extends Equatable {
  final NotificationStatus status;
  final NotificationConnectionStatus connectionStatus;

  /// When true, Delivery Activity applies realtime notification payloads locally.
  /// Does not own the shared WebSocket connection.
  final bool notificationLiveEnabled;

  final List<NotificationSubscription> subscriptions;
  final String? error;
  final NotificationSubscription? lastCreatedSubscription;
  final NotificationSubscription? lastUpdatedSubscription;
  final String? lastDeletedSubscriptionId;
  final NotificationSubscription? selectedSubscription;
  final Map<String, dynamic>? webhookTestResult;
  final Map<String, dynamic>? emailTestResult;

  /// Cross-subscription delivery event feed for the Activity tab.
  final List<WebhookNotification> deliveryActivity;
  final bool deliveryActivityLoading;
  final bool deliveryActivityLoadingMore;
  final bool deliveryActivityHasMore;
  final int deliveryActivityPage;
  final String deliveryActivityOutcome;
  final String? deliveryActivityError;

  /// Exhausted batches awaiting manual retry (FAILED with deliveryAttempts >= 3).
  final List<NotificationBatch> failedBatches;
  final bool failedBatchesLoading;
  final String? failedBatchesError;

  final NotificationStats? lastLoadedStats;
  final String? lastLoadedStatsSubscriptionId;
  final RealtimeNotification? lastRealtimeNotification;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.connectionStatus = NotificationConnectionStatus.disconnected,
    this.notificationLiveEnabled = true,
    this.subscriptions = const [],
    this.error,
    this.lastCreatedSubscription,
    this.lastUpdatedSubscription,
    this.lastDeletedSubscriptionId,
    this.selectedSubscription,
    this.webhookTestResult,
    this.emailTestResult,
    this.deliveryActivity = const [],
    this.deliveryActivityLoading = false,
    this.deliveryActivityLoadingMore = false,
    this.deliveryActivityHasMore = false,
    this.deliveryActivityPage = 0,
    this.deliveryActivityOutcome = 'all',
    this.deliveryActivityError,
    this.failedBatches = const [],
    this.failedBatchesLoading = false,
    this.failedBatchesError,
    this.lastLoadedStats,
    this.lastLoadedStatsSubscriptionId,
    this.lastRealtimeNotification,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    NotificationConnectionStatus? connectionStatus,
    bool? notificationLiveEnabled,
    List<NotificationSubscription>? subscriptions,
    String? error,
    NotificationSubscription? lastCreatedSubscription,
    NotificationSubscription? lastUpdatedSubscription,
    String? lastDeletedSubscriptionId,
    NotificationSubscription? selectedSubscription,
    Map<String, dynamic>? webhookTestResult,
    Map<String, dynamic>? emailTestResult,
    List<WebhookNotification>? deliveryActivity,
    bool? deliveryActivityLoading,
    bool? deliveryActivityLoadingMore,
    bool? deliveryActivityHasMore,
    int? deliveryActivityPage,
    String? deliveryActivityOutcome,
    String? deliveryActivityError,
    List<NotificationBatch>? failedBatches,
    bool? failedBatchesLoading,
    String? failedBatchesError,
    NotificationStats? lastLoadedStats,
    String? lastLoadedStatsSubscriptionId,
    RealtimeNotification? lastRealtimeNotification,
  }) {
    return NotificationState(
      status: status ?? this.status,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      notificationLiveEnabled:
          notificationLiveEnabled ?? this.notificationLiveEnabled,
      subscriptions: subscriptions ?? this.subscriptions,
      error: error,
      lastCreatedSubscription:
          lastCreatedSubscription ?? this.lastCreatedSubscription,
      lastUpdatedSubscription:
          lastUpdatedSubscription ?? this.lastUpdatedSubscription,
      lastDeletedSubscriptionId:
          lastDeletedSubscriptionId ?? this.lastDeletedSubscriptionId,
      selectedSubscription: selectedSubscription ?? this.selectedSubscription,
      webhookTestResult: webhookTestResult ?? this.webhookTestResult,
      emailTestResult: emailTestResult ?? this.emailTestResult,
      deliveryActivity: deliveryActivity ?? this.deliveryActivity,
      deliveryActivityLoading:
          deliveryActivityLoading ?? this.deliveryActivityLoading,
      deliveryActivityLoadingMore:
          deliveryActivityLoadingMore ?? this.deliveryActivityLoadingMore,
      deliveryActivityHasMore:
          deliveryActivityHasMore ?? this.deliveryActivityHasMore,
      deliveryActivityPage: deliveryActivityPage ?? this.deliveryActivityPage,
      deliveryActivityOutcome:
          deliveryActivityOutcome ?? this.deliveryActivityOutcome,
      deliveryActivityError: deliveryActivityError,
      failedBatches: failedBatches ?? this.failedBatches,
      failedBatchesLoading: failedBatchesLoading ?? this.failedBatchesLoading,
      failedBatchesError: failedBatchesError,
      lastLoadedStats: lastLoadedStats ?? this.lastLoadedStats,
      lastLoadedStatsSubscriptionId:
          lastLoadedStatsSubscriptionId ?? this.lastLoadedStatsSubscriptionId,
      lastRealtimeNotification:
          lastRealtimeNotification ?? this.lastRealtimeNotification,
    );
  }

  @override
  List<Object?> get props => [
    status,
    connectionStatus,
    notificationLiveEnabled,
    subscriptions,
    error,
    lastCreatedSubscription,
    lastUpdatedSubscription,
    lastDeletedSubscriptionId,
    selectedSubscription,
    webhookTestResult,
    emailTestResult,
    deliveryActivity,
    deliveryActivityLoading,
    deliveryActivityLoadingMore,
    deliveryActivityHasMore,
    deliveryActivityPage,
    deliveryActivityOutcome,
    deliveryActivityError,
    failedBatches,
    failedBatchesLoading,
    failedBatchesError,
    lastLoadedStats,
    lastLoadedStatsSubscriptionId,
    lastRealtimeNotification,
  ];
}
