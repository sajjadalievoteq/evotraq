import 'package:equatable/equatable.dart';
import '../../domain/models/notification_subscription.dart';
import '../../domain/models/realtime_notification.dart';

enum NotificationStatus { initial, loading, success, error, subscriptionCreated, subscriptionUpdated, subscriptionDeleted, webSocketConnected, webSocketDisconnected }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationSubscription> subscriptions;
  final bool hasReachedMax;
  final int currentPage;
  final String? error;
  final NotificationSubscription? lastCreatedSubscription;
  final NotificationSubscription? lastUpdatedSubscription;
  final String? lastDeletedSubscriptionId;
  final NotificationSubscription? selectedSubscription;
  final Map<String, dynamic>? webhookTestResult;
  final Map<String, dynamic>? emailTestResult;
  final List<WebhookNotification> webhookHistory;
  final String? lastLoadedHistorySubscriptionId;
  final NotificationStats? lastLoadedStats;
  final String? lastLoadedStatsSubscriptionId;
  final RealtimeNotification? lastRealtimeNotification;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.subscriptions = const [],
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.error,
    this.lastCreatedSubscription,
    this.lastUpdatedSubscription,
    this.lastDeletedSubscriptionId,
    this.selectedSubscription,
    this.webhookTestResult,
    this.emailTestResult,
    this.webhookHistory = const [],
    this.lastLoadedHistorySubscriptionId,
    this.lastLoadedStats,
    this.lastLoadedStatsSubscriptionId,
    this.lastRealtimeNotification,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationSubscription>? subscriptions,
    bool? hasReachedMax,
    int? currentPage,
    String? error,
    NotificationSubscription? lastCreatedSubscription,
    NotificationSubscription? lastUpdatedSubscription,
    String? lastDeletedSubscriptionId,
    NotificationSubscription? selectedSubscription,
    Map<String, dynamic>? webhookTestResult,
    Map<String, dynamic>? emailTestResult,
    List<WebhookNotification>? webhookHistory,
    String? lastLoadedHistorySubscriptionId,
    NotificationStats? lastLoadedStats,
    String? lastLoadedStatsSubscriptionId,
    RealtimeNotification? lastRealtimeNotification,
  }) {
    return NotificationState(
      status: status ?? this.status,
      subscriptions: subscriptions ?? this.subscriptions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      lastCreatedSubscription: lastCreatedSubscription ?? this.lastCreatedSubscription,
      lastUpdatedSubscription: lastUpdatedSubscription ?? this.lastUpdatedSubscription,
      lastDeletedSubscriptionId: lastDeletedSubscriptionId ?? this.lastDeletedSubscriptionId,
      selectedSubscription: selectedSubscription ?? this.selectedSubscription,
      webhookTestResult: webhookTestResult ?? this.webhookTestResult,
      emailTestResult: emailTestResult ?? this.emailTestResult,
      webhookHistory: webhookHistory ?? this.webhookHistory,
      lastLoadedHistorySubscriptionId: lastLoadedHistorySubscriptionId ?? this.lastLoadedHistorySubscriptionId,
      lastLoadedStats: lastLoadedStats ?? this.lastLoadedStats,
      lastLoadedStatsSubscriptionId: lastLoadedStatsSubscriptionId ?? this.lastLoadedStatsSubscriptionId,
      lastRealtimeNotification: lastRealtimeNotification ?? this.lastRealtimeNotification,
    );
  }

  @override
  List<Object?> get props => [
        status,
        subscriptions,
        hasReachedMax,
        currentPage,
        error,
        lastCreatedSubscription,
        lastUpdatedSubscription,
        lastDeletedSubscriptionId,
        selectedSubscription,
        webhookTestResult,
        emailTestResult,
        webhookHistory,
        lastLoadedHistorySubscriptionId,
        lastLoadedStats,
        lastLoadedStatsSubscriptionId,
        lastRealtimeNotification,
      ];
}
