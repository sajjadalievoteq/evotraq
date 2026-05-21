import 'package:equatable/equatable.dart';

class SGTINAlert extends Equatable {
  final int? id;
  final String? uuid;
  final int sgtinId;
  final String alertType;
  final String severity;
  final String message;
  final String? triggeredAt;
  final String? acknowledgedAt;
  final String? acknowledgedBy;
  final String? resolvedAt;
  final String? resolvedBy;
  final String? resolutionNotes;
  final String? regimeContext;

  const SGTINAlert({
    this.id,
    this.uuid,
    required this.sgtinId,
    required this.alertType,
    required this.severity,
    required this.message,
    this.triggeredAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNotes,
    this.regimeContext,
  });

  factory SGTINAlert.fromJson(Map<String, dynamic> json) => SGTINAlert(
        id: json['id'] as int?,
        uuid: json['uuid'] as String?,
        sgtinId: json['sgtinId'] as int,
        alertType: json['alertType'] as String,
        severity: json['severity'] as String? ?? 'MEDIUM',
        message: json['message'] as String,
        triggeredAt: json['triggeredAt'] as String?,
        acknowledgedAt: json['acknowledgedAt'] as String?,
        acknowledgedBy: json['acknowledgedBy'] as String?,
        resolvedAt: json['resolvedAt'] as String?,
        resolvedBy: json['resolvedBy'] as String?,
        resolutionNotes: json['resolutionNotes'] as String?,
        regimeContext: json['regimeContext'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (uuid != null) 'uuid': uuid,
        'sgtinId': sgtinId,
        'alertType': alertType,
        'severity': severity,
        'message': message,
        if (triggeredAt != null) 'triggeredAt': triggeredAt,
        if (acknowledgedAt != null) 'acknowledgedAt': acknowledgedAt,
        if (acknowledgedBy != null) 'acknowledgedBy': acknowledgedBy,
        if (resolvedAt != null) 'resolvedAt': resolvedAt,
        if (resolvedBy != null) 'resolvedBy': resolvedBy,
        if (resolutionNotes != null) 'resolutionNotes': resolutionNotes,
        if (regimeContext != null) 'regimeContext': regimeContext,
      };

  SGTINAlert copyWith({
    int? id,
    String? uuid,
    int? sgtinId,
    String? alertType,
    String? severity,
    String? message,
    String? triggeredAt,
    String? acknowledgedAt,
    String? acknowledgedBy,
    String? resolvedAt,
    String? resolvedBy,
    String? resolutionNotes,
    String? regimeContext,
  }) =>
      SGTINAlert(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        sgtinId: sgtinId ?? this.sgtinId,
        alertType: alertType ?? this.alertType,
        severity: severity ?? this.severity,
        message: message ?? this.message,
        triggeredAt: triggeredAt ?? this.triggeredAt,
        acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
        acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
        resolvedAt: resolvedAt ?? this.resolvedAt,
        resolvedBy: resolvedBy ?? this.resolvedBy,
        resolutionNotes: resolutionNotes ?? this.resolutionNotes,
        regimeContext: regimeContext ?? this.regimeContext,
      );

  bool get isOpen => resolvedAt == null;
  bool get isAcknowledged => acknowledgedAt != null;

  @override
  List<Object?> get props => [
        id, uuid, sgtinId, alertType, severity, message, triggeredAt,
        acknowledgedAt, acknowledgedBy, resolvedAt, resolvedBy,
        resolutionNotes, regimeContext,
      ];
}
