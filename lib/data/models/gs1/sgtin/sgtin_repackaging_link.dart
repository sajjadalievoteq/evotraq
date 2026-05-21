import 'package:equatable/equatable.dart';

class SGTINRepackagingLink extends Equatable {
  final int? id;
  final String? uuid;
  final int originalSgtinId;
  final int newSgtinId;
  final String repackagingType;
  final String? repackagingEventId;
  final String? repackagedAt;
  final String? reason;
  final String? responsiblePartyGln;

  const SGTINRepackagingLink({
    this.id,
    this.uuid,
    required this.originalSgtinId,
    required this.newSgtinId,
    required this.repackagingType,
    this.repackagingEventId,
    this.repackagedAt,
    this.reason,
    this.responsiblePartyGln,
  });

  factory SGTINRepackagingLink.fromJson(Map<String, dynamic> json) =>
      SGTINRepackagingLink(
        id: json['id'] as int?,
        uuid: json['uuid'] as String?,
        originalSgtinId: json['originalSgtinId'] as int,
        newSgtinId: json['newSgtinId'] as int,
        repackagingType: json['repackagingType'] as String,
        repackagingEventId: json['repackagingEventId'] as String?,
        repackagedAt: json['repackagedAt'] as String?,
        reason: json['reason'] as String?,
        responsiblePartyGln: json['responsiblePartyGln'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (uuid != null) 'uuid': uuid,
        'originalSgtinId': originalSgtinId,
        'newSgtinId': newSgtinId,
        'repackagingType': repackagingType,
        if (repackagingEventId != null)
          'repackagingEventId': repackagingEventId,
        if (repackagedAt != null) 'repackagedAt': repackagedAt,
        if (reason != null) 'reason': reason,
        if (responsiblePartyGln != null)
          'responsiblePartyGln': responsiblePartyGln,
      };

  SGTINRepackagingLink copyWith({
    int? id,
    String? uuid,
    int? originalSgtinId,
    int? newSgtinId,
    String? repackagingType,
    String? repackagingEventId,
    String? repackagedAt,
    String? reason,
    String? responsiblePartyGln,
  }) =>
      SGTINRepackagingLink(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        originalSgtinId: originalSgtinId ?? this.originalSgtinId,
        newSgtinId: newSgtinId ?? this.newSgtinId,
        repackagingType: repackagingType ?? this.repackagingType,
        repackagingEventId: repackagingEventId ?? this.repackagingEventId,
        repackagedAt: repackagedAt ?? this.repackagedAt,
        reason: reason ?? this.reason,
        responsiblePartyGln: responsiblePartyGln ?? this.responsiblePartyGln,
      );

  @override
  List<Object?> get props => [
        id, uuid, originalSgtinId, newSgtinId, repackagingType,
        repackagingEventId, repackagedAt, reason, responsiblePartyGln,
      ];
}
