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
  final String? notificationFormat;
  final String? notificationFrequency;
  final int? maxEventsPerNotification;
  final int? preferredHour;
  final int? preferredMinute;
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
    this.notificationFrequency,
    this.maxEventsPerNotification,
    this.preferredHour,
    this.preferredMinute,
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
    notificationFrequency,
    maxEventsPerNotification,
    preferredHour,
    preferredMinute,
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
    String? notificationFrequency,
    int? maxEventsPerNotification,
    int? preferredHour,
    int? preferredMinute,
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
      notificationFrequency:
          notificationFrequency ?? this.notificationFrequency,
      maxEventsPerNotification:
          maxEventsPerNotification ?? this.maxEventsPerNotification,
      preferredHour: preferredHour ?? this.preferredHour,
      preferredMinute: preferredMinute ?? this.preferredMinute,
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
  final int totalNotifications;
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
  final String? deliveryMethod;
  @JsonKey(includeIfNull: false)
  final String? notificationFormat;
  @JsonKey(includeIfNull: false)
  final String? notificationFrequency;
  @JsonKey(includeIfNull: false)
  final int? maxEventsPerNotification;
  @JsonKey(includeIfNull: false)
  final int? preferredHour;
  @JsonKey(includeIfNull: false)
  final int? preferredMinute;
  final Map<String, dynamic>? queryParameters;
  @JsonKey(includeIfNull: false)
  final String? webhookAuthUsername;
  @JsonKey(includeIfNull: false)
  final String? webhookAuthPassword;

  const CreateSubscriptionRequest({
    required this.subscriptionName,
    required this.webhookUrl,
    required this.subscriptionType,
    this.deliveryMethod,
    this.notificationFormat,
    this.notificationFrequency,
    this.maxEventsPerNotification,
    this.preferredHour,
    this.preferredMinute,
    this.queryParameters,
    this.webhookAuthUsername,
    this.webhookAuthPassword,
  });

  factory CreateSubscriptionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSubscriptionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSubscriptionRequestToJson(this);

  @override
  List<Object?> get props => [
    subscriptionName,
    webhookUrl,
    subscriptionType,
    deliveryMethod,
    notificationFormat,
    notificationFrequency,
    maxEventsPerNotification,
    preferredHour,
    preferredMinute,
    queryParameters,
    webhookAuthUsername,
    webhookAuthPassword,
  ];
}

@JsonSerializable(createFactory: false)
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

  /// Maps backend [WebhookNotificationDTO] field names (`eventIds`,
  /// `attemptCount`, `deliveryTime`, `responseBody`) plus legacy aliases.
  factory WebhookNotification.fromJson(Map<String, dynamic> json) {
    final eventIds = json['eventIds'];
    String eventId = json['eventId']?.toString() ?? '';
    if (eventId.isEmpty && eventIds is List && eventIds.isNotEmpty) {
      eventId = eventIds.first.toString();
    }

    DateTime? parseTime(Object? value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    final responseBody = json['responseBody'];
    Map<String, dynamic>? response;
    if (json['response'] is Map<String, dynamic>) {
      response = Map<String, dynamic>.from(json['response'] as Map);
    } else if (responseBody != null) {
      response = {'body': responseBody};
    }

    return WebhookNotification(
      id: json['id']?.toString() ?? '',
      subscriptionId: json['subscriptionId']?.toString() ?? '',
      eventId: eventId,
      status: json['status']?.toString() ?? '',
      webhookUrl: json['webhookUrl']?.toString() ?? '',
      createdAt:
          parseTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      deliveredAt: parseTime(json['deliveryTime'] ?? json['deliveredAt']),
      retryCount:
          (json['attemptCount'] as num?)?.toInt() ??
          (json['retryCount'] as num?)?.toInt() ??
          0,
      errorMessage: json['errorMessage'] as String?,
      response: response,
    );
  }

  bool get isEmail {
    final url = webhookUrl.trim();
    final lower = url.toLowerCase();
    if (lower.startsWith('mailto:')) return true;
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return false;
    }
    return url.contains('@');
  }

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

class NotificationBatch extends Equatable {
  final String id;
  final String subscriptionId;
  final String? subscriptionName;
  final int? batchSize;
  final String
  status; // PENDING | PROCESSING | SENT | DELIVERED | FAILED | CANCELLED
  final int? deliveryAttempts;
  final String? lastError;
  final DateTime? scheduledTime;
  final DateTime? processingEndTime;
  final DateTime createdAt;

  const NotificationBatch({
    required this.id,
    required this.subscriptionId,
    this.subscriptionName,
    this.batchSize,
    required this.status,
    this.deliveryAttempts,
    this.lastError,
    this.scheduledTime,
    this.processingEndTime,
    required this.createdAt,
  });

  factory NotificationBatch.fromJson(Map<String, dynamic> json) {
    DateTime? parseTime(Object? v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return NotificationBatch(
      id: json['id']?.toString() ?? '',
      subscriptionId: json['subscriptionId']?.toString() ?? '',
      subscriptionName: json['subscriptionName'] as String?,
      batchSize: (json['batchSize'] as num?)?.toInt(),
      status: json['status']?.toString() ?? 'PENDING',
      deliveryAttempts: (json['deliveryAttempts'] as num?)?.toInt(),
      lastError: json['lastError'] as String?,
      scheduledTime: parseTime(json['scheduledTime']),
      processingEndTime: parseTime(json['processingEndTime']),
      createdAt:
          parseTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  bool get isExhausted => status == 'FAILED' && (deliveryAttempts ?? 0) >= 3;

  @override
  List<Object?> get props => [
    id,
    subscriptionId,
    status,
    deliveryAttempts,
    lastError,
  ];
}
