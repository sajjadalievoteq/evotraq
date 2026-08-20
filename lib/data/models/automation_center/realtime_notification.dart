import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import 'package:traqtrace_app/data/models/automation_center/realtime_notification.g.dart';

@JsonSerializable(explicitToJson: true)
class RealtimeNotification extends Equatable {
  final String id;
  final String subscriptionId;
  final String eventType;
  final String eventId;
  final Map<String, dynamic> eventData;
  final DateTime timestamp;
  final String source;

  const RealtimeNotification({
    required this.id,
    required this.subscriptionId,
    required this.eventType,
    required this.eventId,
    required this.eventData,
    required this.timestamp,
    required this.source,
  });

  factory RealtimeNotification.fromJson(Map<String, dynamic> json) =>
      realtimeNotificationFromJson(json);

  Map<String, dynamic> toJson() => realtimeNotificationToJson(this);

  @override
  List<Object?> get props => [
    id,
    subscriptionId,
    eventType,
    eventId,
    eventData,
    timestamp,
    source,
  ];
}

@JsonSerializable()
class NotificationBatch extends Equatable {
  final String id;
  final String subscriptionId;
  final List<String> eventIds;
  final String status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? deliveredAt;
  final int retryCount;
  final String? errorMessage;

  const NotificationBatch({
    required this.id,
    required this.subscriptionId,
    required this.eventIds,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.deliveredAt,
    required this.retryCount,
    this.errorMessage,
  });

  factory NotificationBatch.fromJson(Map<String, dynamic> json) =>
      notificationBatchFromJson(json);

  Map<String, dynamic> toJson() => notificationBatchToJson(this);

  @override
  List<Object?> get props => [
    id,
    subscriptionId,
    eventIds,
    status,
    createdAt,
    processedAt,
    deliveredAt,
    retryCount,
    errorMessage,
  ];
}
