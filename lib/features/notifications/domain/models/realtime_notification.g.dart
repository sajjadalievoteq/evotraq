// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealtimeNotification _$RealtimeNotificationFromJson(
  Map<String, dynamic> json,
) => RealtimeNotification(
  id: json['id'] as String,
  subscriptionId: json['subscriptionId'] as String,
  eventType: json['eventType'] as String,
  eventId: json['eventId'] as String,
  eventData: json['eventData'] as Map<String, dynamic>,
  timestamp: DateTime.parse(json['timestamp'] as String),
  source: json['source'] as String,
);

Map<String, dynamic> _$RealtimeNotificationToJson(
  RealtimeNotification instance,
) => <String, dynamic>{
  'id': instance.id,
  'subscriptionId': instance.subscriptionId,
  'eventType': instance.eventType,
  'eventId': instance.eventId,
  'eventData': instance.eventData,
  'timestamp': instance.timestamp.toIso8601String(),
  'source': instance.source,
};

NotificationBatch _$NotificationBatchFromJson(Map<String, dynamic> json) =>
    NotificationBatch(
      id: json['id'] as String,
      subscriptionId: json['subscriptionId'] as String,
      eventIds: (json['eventIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      retryCount: (json['retryCount'] as num).toInt(),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$NotificationBatchToJson(NotificationBatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subscriptionId': instance.subscriptionId,
      'eventIds': instance.eventIds,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'processedAt': instance.processedAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'retryCount': instance.retryCount,
      'errorMessage': instance.errorMessage,
    };
