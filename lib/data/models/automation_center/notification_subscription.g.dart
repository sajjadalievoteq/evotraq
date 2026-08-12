// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationSubscription _$NotificationSubscriptionFromJson(
  Map<String, dynamic> json,
) => NotificationSubscription(
  id: json['id'] as String,
  subscriptionName: json['subscriptionName'] as String,
  webhookUrl: json['webhookUrl'] as String,
  status: json['status'] as String,
  subscriptionType: json['subscriptionType'] as String,
  notificationFormat: json['notificationFormat'] as String?,
  notificationFrequency: json['notificationFrequency'] as String?,
  maxEventsPerNotification: (json['maxEventsPerNotification'] as num?)?.toInt(),
  preferredHour: (json['preferredHour'] as num?)?.toInt(),
  preferredMinute: (json['preferredMinute'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdTime'] as String),
  updatedAt: json['lastModifiedTime'] == null
      ? null
      : DateTime.parse(json['lastModifiedTime'] as String),
  queryParameters: json['queryParameters'] as Map<String, dynamic>?,
  stats: json['metrics'] == null
      ? null
      : NotificationStats.fromJson(json['metrics'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NotificationSubscriptionToJson(
  NotificationSubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'subscriptionName': instance.subscriptionName,
  'webhookUrl': instance.webhookUrl,
  'status': instance.status,
  'subscriptionType': instance.subscriptionType,
  'notificationFormat': instance.notificationFormat,
  'notificationFrequency': instance.notificationFrequency,
  'maxEventsPerNotification': instance.maxEventsPerNotification,
  'preferredHour': instance.preferredHour,
  'preferredMinute': instance.preferredMinute,
  'createdTime': instance.createdAt.toIso8601String(),
  'lastModifiedTime': instance.updatedAt?.toIso8601String(),
  'queryParameters': instance.queryParameters,
  'metrics': instance.stats?.toJson(),
};

NotificationStats _$NotificationStatsFromJson(Map<String, dynamic> json) =>
    NotificationStats(
      totalNotifications: (json['totalEventsMatched'] as num).toInt(),
      successfulNotifications: (json['successfulNotifications'] as num).toInt(),
      failedNotifications: (json['failedNotifications'] as num).toInt(),
      successRate: (json['successRate'] as num).toDouble(),
      lastNotificationSent: json['lastErrorTime'] == null
          ? null
          : DateTime.parse(json['lastErrorTime'] as String),
      avgDeliveryTime: (json['averageDeliveryTimeMs'] as num).toDouble(),
    );

Map<String, dynamic> _$NotificationStatsToJson(NotificationStats instance) =>
    <String, dynamic>{
      'totalEventsMatched': instance.totalNotifications,
      'successfulNotifications': instance.successfulNotifications,
      'failedNotifications': instance.failedNotifications,
      'successRate': instance.successRate,
      'lastErrorTime': instance.lastNotificationSent?.toIso8601String(),
      'averageDeliveryTimeMs': instance.avgDeliveryTime,
    };

CreateSubscriptionRequest _$CreateSubscriptionRequestFromJson(
  Map<String, dynamic> json,
) => CreateSubscriptionRequest(
  subscriptionName: json['subscriptionName'] as String,
  webhookUrl: json['webhookUrl'] as String,
  subscriptionType: json['subscriptionType'] as String,
  deliveryMethod: json['deliveryMethod'] as String?,
  notificationFormat: json['notificationFormat'] as String?,
  notificationFrequency: json['notificationFrequency'] as String?,
  maxEventsPerNotification: (json['maxEventsPerNotification'] as num?)?.toInt(),
  preferredHour: (json['preferredHour'] as num?)?.toInt(),
  preferredMinute: (json['preferredMinute'] as num?)?.toInt(),
  queryParameters: json['queryParameters'] as Map<String, dynamic>?,
  webhookAuthUsername: json['webhookAuthUsername'] as String?,
  webhookAuthPassword: json['webhookAuthPassword'] as String?,
);

Map<String, dynamic> _$CreateSubscriptionRequestToJson(
  CreateSubscriptionRequest instance,
) => <String, dynamic>{
  'subscriptionName': instance.subscriptionName,
  'webhookUrl': instance.webhookUrl,
  'subscriptionType': instance.subscriptionType,
  'deliveryMethod': ?instance.deliveryMethod,
  'notificationFormat': ?instance.notificationFormat,
  'notificationFrequency': ?instance.notificationFrequency,
  'maxEventsPerNotification': ?instance.maxEventsPerNotification,
  'preferredHour': ?instance.preferredHour,
  'preferredMinute': ?instance.preferredMinute,
  'queryParameters': ?instance.queryParameters,
  'webhookAuthUsername': ?instance.webhookAuthUsername,
  'webhookAuthPassword': ?instance.webhookAuthPassword,
};

WebhookNotification _$WebhookNotificationFromJson(Map<String, dynamic> json) =>
    WebhookNotification.fromJson(json);

Map<String, dynamic> _$WebhookNotificationToJson(
  WebhookNotification instance,
) => <String, dynamic>{
  'id': instance.id,
  'subscriptionId': instance.subscriptionId,
  'eventId': instance.eventId,
  'status': instance.status,
  'webhookUrl': instance.webhookUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'deliveredAt': instance.deliveredAt?.toIso8601String(),
  'retryCount': instance.retryCount,
  'errorMessage': instance.errorMessage,
  'response': instance.response,
};
