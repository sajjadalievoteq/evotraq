import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'notification_subscription.g.dart';

@JsonSerializable(explicitToJson: true)
class NotificationSubscription extends Equatable {
  final String id;
  final String subscriptionName;
  final String webhookUrl;
  final String status;
  final String subscriptionType;
  final String? notificationFormat; // Optional since backend doesn't always include it
  @JsonKey(name: 'createdTime')
  final DateTime createdAt;
  @JsonKey(name: 'lastModifiedTime')
  final DateTime? updatedAt;
  final Map<String, dynamic>? queryParameters;
  @JsonKey(name: 'metrics')
  final NotificationStats? stats;

  const NotificationSubscription({
    required this.id,
    required this.subscriptionName,
    required this.webhookUrl,
    required this.status,
    required this.subscriptionType,
    this.notificationFormat,
    required this.createdAt,
    this.updatedAt,
    this.queryParameters,
    this.stats,
  });

  factory NotificationSubscription.fromJson(Map<String, dynamic> json) =>
      _$NotificationSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSubscriptionToJson(this);

  @override
  List<Object?> get props => [
        id,
        subscriptionName,
        webhookUrl,
        status,
        subscriptionType,
        notificationFormat,
        createdAt,
        updatedAt,
        queryParameters,
        stats,
      ];

  NotificationSubscription copyWith({
    String? id,
    String? subscriptionName,
    String? webhookUrl,
    String? status,
    String? subscriptionType,
    String? notificationFormat,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? queryParameters,
    NotificationStats? stats,
  }) {
    return NotificationSubscription(
      id: id ?? this.id,
      subscriptionName: subscriptionName ?? this.subscriptionName,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      status: status ?? this.status,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      notificationFormat: notificationFormat ?? this.notificationFormat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      queryParameters: queryParameters ?? this.queryParameters,
      stats: stats ?? this.stats,
    );
  }
}

@JsonSerializable()
class NotificationStats extends Equatable {
  @JsonKey(name: 'totalEventsMatched')
  final int totalNotifications; // Map from backend's totalEventsMatched
  final int successfulNotifications;
  final int failedNotifications;
  final double successRate;
  @JsonKey(name: 'lastErrorTime')
  final DateTime? lastNotificationSent;
  @JsonKey(name: 'averageDeliveryTimeMs')
  final double avgDeliveryTime;

  const NotificationStats({
    required this.totalNotifications,
    required this.successfulNotifications,
    required this.failedNotifications,
    required this.successRate,
    this.lastNotificationSent,
    required this.avgDeliveryTime,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) =>
      _$NotificationStatsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationStatsToJson(this);

  @override
  List<Object?> get props => [
        totalNotifications,
        successfulNotifications,
        failedNotifications,
        successRate,
        lastNotificationSent,
        avgDeliveryTime,
      ];
}

@JsonSerializable(includeIfNull: false)
class CreateSubscriptionRequest extends Equatable {
  final String subscriptionName;
  final String webhookUrl;
  final String subscriptionType;
  @JsonKey(includeIfNull: false)
  final String? notificationFormat;
  final Map<String, dynamic>? queryParameters;

  const CreateSubscriptionRequest({
    required this.subscriptionName,
    required this.webhookUrl,
    required this.subscriptionType,
    this.notificationFormat,
    this.queryParameters,
  });

  factory CreateSubscriptionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSubscriptionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSubscriptionRequestToJson(this);

  @override
  List<Object?> get props => [
        subscriptionName,
        webhookUrl,
        subscriptionType,
        notificationFormat,
        queryParameters,
      ];
}

@JsonSerializable()
class WebhookNotification extends Equatable {
  final String id;
  final String subscriptionId;
  final String eventId;
  final String status;
  final String webhookUrl;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final int retryCount;
  final String? errorMessage;
  final Map<String, dynamic>? response;

  const WebhookNotification({
    required this.id,
    required this.subscriptionId,
    required this.eventId,
    required this.status,
    required this.webhookUrl,
    required this.createdAt,
    this.deliveredAt,
    required this.retryCount,
    this.errorMessage,
    this.response,
  });

  factory WebhookNotification.fromJson(Map<String, dynamic> json) =>
      _$WebhookNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookNotificationToJson(this);

  @override
  List<Object?> get props => [
        id,
        subscriptionId,
        eventId,
        status,
        webhookUrl,
        createdAt,
        deliveredAt,
        retryCount,
        errorMessage,
        response,
      ];
}
