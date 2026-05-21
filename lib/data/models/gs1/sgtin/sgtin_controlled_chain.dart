import 'package:equatable/equatable.dart';

class SGTINControlledChain extends Equatable {
  final int? id;
  final String? uuid;
  final int sgtinId;
  final String chainType;
  final double? tempMinThreshold;
  final double? tempMaxThreshold;
  final double? tempMinRecorded;
  final double? tempMaxRecorded;
  final bool excursionFlag;
  final String? excursionDetectedAt;
  final String? lastSensorEventId;
  final String chainStatus;
  final double? humidityMinRecorded;
  final double? humidityMaxRecorded;

  const SGTINControlledChain({
    this.id,
    this.uuid,
    required this.sgtinId,
    required this.chainType,
    this.tempMinThreshold,
    this.tempMaxThreshold,
    this.tempMinRecorded,
    this.tempMaxRecorded,
    required this.excursionFlag,
    this.excursionDetectedAt,
    this.lastSensorEventId,
    required this.chainStatus,
    this.humidityMinRecorded,
    this.humidityMaxRecorded,
  });

  factory SGTINControlledChain.fromJson(Map<String, dynamic> json) =>
      SGTINControlledChain(
        id: json['id'] as int?,
        uuid: json['uuid'] as String?,
        sgtinId: json['sgtinId'] as int,
        chainType: json['chainType'] as String,
        tempMinThreshold: (json['tempMinThreshold'] as num?)?.toDouble(),
        tempMaxThreshold: (json['tempMaxThreshold'] as num?)?.toDouble(),
        tempMinRecorded: (json['tempMinRecorded'] as num?)?.toDouble(),
        tempMaxRecorded: (json['tempMaxRecorded'] as num?)?.toDouble(),
        excursionFlag: json['excursionFlag'] as bool? ?? false,
        excursionDetectedAt: json['excursionDetectedAt'] as String?,
        lastSensorEventId: json['lastSensorEventId'] as String?,
        chainStatus: json['chainStatus'] as String? ?? 'INTACT',
        humidityMinRecorded: (json['humidityMinRecorded'] as num?)?.toDouble(),
        humidityMaxRecorded: (json['humidityMaxRecorded'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (uuid != null) 'uuid': uuid,
        'sgtinId': sgtinId,
        'chainType': chainType,
        if (tempMinThreshold != null) 'tempMinThreshold': tempMinThreshold,
        if (tempMaxThreshold != null) 'tempMaxThreshold': tempMaxThreshold,
        if (tempMinRecorded != null) 'tempMinRecorded': tempMinRecorded,
        if (tempMaxRecorded != null) 'tempMaxRecorded': tempMaxRecorded,
        'excursionFlag': excursionFlag,
        if (excursionDetectedAt != null)
          'excursionDetectedAt': excursionDetectedAt,
        if (lastSensorEventId != null) 'lastSensorEventId': lastSensorEventId,
        'chainStatus': chainStatus,
        if (humidityMinRecorded != null)
          'humidityMinRecorded': humidityMinRecorded,
        if (humidityMaxRecorded != null)
          'humidityMaxRecorded': humidityMaxRecorded,
      };

  SGTINControlledChain copyWith({
    int? id,
    String? uuid,
    int? sgtinId,
    String? chainType,
    double? tempMinThreshold,
    double? tempMaxThreshold,
    double? tempMinRecorded,
    double? tempMaxRecorded,
    bool? excursionFlag,
    String? excursionDetectedAt,
    String? lastSensorEventId,
    String? chainStatus,
    double? humidityMinRecorded,
    double? humidityMaxRecorded,
  }) =>
      SGTINControlledChain(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        sgtinId: sgtinId ?? this.sgtinId,
        chainType: chainType ?? this.chainType,
        tempMinThreshold: tempMinThreshold ?? this.tempMinThreshold,
        tempMaxThreshold: tempMaxThreshold ?? this.tempMaxThreshold,
        tempMinRecorded: tempMinRecorded ?? this.tempMinRecorded,
        tempMaxRecorded: tempMaxRecorded ?? this.tempMaxRecorded,
        excursionFlag: excursionFlag ?? this.excursionFlag,
        excursionDetectedAt: excursionDetectedAt ?? this.excursionDetectedAt,
        lastSensorEventId: lastSensorEventId ?? this.lastSensorEventId,
        chainStatus: chainStatus ?? this.chainStatus,
        humidityMinRecorded: humidityMinRecorded ?? this.humidityMinRecorded,
        humidityMaxRecorded: humidityMaxRecorded ?? this.humidityMaxRecorded,
      );

  @override
  List<Object?> get props => [
        id, uuid, sgtinId, chainType, tempMinThreshold, tempMaxThreshold,
        tempMinRecorded, tempMaxRecorded, excursionFlag, excursionDetectedAt,
        lastSensorEventId, chainStatus, humidityMinRecorded, humidityMaxRecorded,
      ];
}
