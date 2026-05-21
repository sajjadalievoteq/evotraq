import 'package:equatable/equatable.dart';

class SGTINDuplicateEvidence extends Equatable {
  final int? id;
  final String? uuid;
  final int sgtinId;
  final int? duplicateOfSgtinId;
  final String? detectionSource;
  final String? detectionTimestamp;
  final int? fraudScore;
  final String evidenceType;
  final String? evidenceReference;
  final String? resolvedAt;
  final String? resolutionNotes;
  final String? antiTamperStatus;

  const SGTINDuplicateEvidence({
    this.id,
    this.uuid,
    required this.sgtinId,
    this.duplicateOfSgtinId,
    this.detectionSource,
    this.detectionTimestamp,
    this.fraudScore,
    required this.evidenceType,
    this.evidenceReference,
    this.resolvedAt,
    this.resolutionNotes,
    this.antiTamperStatus,
  });

  factory SGTINDuplicateEvidence.fromJson(Map<String, dynamic> json) =>
      SGTINDuplicateEvidence(
        id: json['id'] as int?,
        uuid: json['uuid'] as String?,
        sgtinId: json['sgtinId'] as int,
        duplicateOfSgtinId: json['duplicateOfSgtinId'] as int?,
        detectionSource: json['detectionSource'] as String?,
        detectionTimestamp: json['detectionTimestamp'] as String?,
        fraudScore: json['fraudScore'] as int?,
        evidenceType: json['evidenceType'] as String? ?? 'DUPLICATE_SCAN',
        evidenceReference: json['evidenceReference'] as String?,
        resolvedAt: json['resolvedAt'] as String?,
        resolutionNotes: json['resolutionNotes'] as String?,
        antiTamperStatus: json['antiTamperStatus'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (uuid != null) 'uuid': uuid,
        'sgtinId': sgtinId,
        if (duplicateOfSgtinId != null)
          'duplicateOfSgtinId': duplicateOfSgtinId,
        if (detectionSource != null) 'detectionSource': detectionSource,
        if (detectionTimestamp != null)
          'detectionTimestamp': detectionTimestamp,
        if (fraudScore != null) 'fraudScore': fraudScore,
        'evidenceType': evidenceType,
        if (evidenceReference != null) 'evidenceReference': evidenceReference,
        if (resolvedAt != null) 'resolvedAt': resolvedAt,
        if (resolutionNotes != null) 'resolutionNotes': resolutionNotes,
        if (antiTamperStatus != null) 'antiTamperStatus': antiTamperStatus,
      };

  SGTINDuplicateEvidence copyWith({
    int? id,
    String? uuid,
    int? sgtinId,
    int? duplicateOfSgtinId,
    String? detectionSource,
    String? detectionTimestamp,
    int? fraudScore,
    String? evidenceType,
    String? evidenceReference,
    String? resolvedAt,
    String? resolutionNotes,
    String? antiTamperStatus,
  }) =>
      SGTINDuplicateEvidence(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        sgtinId: sgtinId ?? this.sgtinId,
        duplicateOfSgtinId: duplicateOfSgtinId ?? this.duplicateOfSgtinId,
        detectionSource: detectionSource ?? this.detectionSource,
        detectionTimestamp: detectionTimestamp ?? this.detectionTimestamp,
        fraudScore: fraudScore ?? this.fraudScore,
        evidenceType: evidenceType ?? this.evidenceType,
        evidenceReference: evidenceReference ?? this.evidenceReference,
        resolvedAt: resolvedAt ?? this.resolvedAt,
        resolutionNotes: resolutionNotes ?? this.resolutionNotes,
        antiTamperStatus: antiTamperStatus ?? this.antiTamperStatus,
      );

  @override
  List<Object?> get props => [
        id, uuid, sgtinId, duplicateOfSgtinId, detectionSource,
        detectionTimestamp, fraudScore, evidenceType, evidenceReference,
        resolvedAt, resolutionNotes, antiTamperStatus,
      ];
}
