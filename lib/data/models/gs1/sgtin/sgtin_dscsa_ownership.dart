import 'package:equatable/equatable.dart';

class SGTINDscsaOwnership extends Equatable {
  final int? id;
  final String? uuid;
  final int sgtinId;
  final String fromPartyGln;
  final String toPartyGln;
  final String? transactionId;
  final String transactionType;
  final String? tiHash;
  final String? transferDate;
  final String? dnLotNumber;
  final String? dnNdc;
  final String? dnDescription;
  final String? atpvReference;

  const SGTINDscsaOwnership({
    this.id,
    this.uuid,
    required this.sgtinId,
    required this.fromPartyGln,
    required this.toPartyGln,
    this.transactionId,
    required this.transactionType,
    this.tiHash,
    this.transferDate,
    this.dnLotNumber,
    this.dnNdc,
    this.dnDescription,
    this.atpvReference,
  });

  factory SGTINDscsaOwnership.fromJson(Map<String, dynamic> json) =>
      SGTINDscsaOwnership(
        id: json['id'] as int?,
        uuid: json['uuid'] as String?,
        sgtinId: json['sgtinId'] as int,
        fromPartyGln: json['fromPartyGln'] as String,
        toPartyGln: json['toPartyGln'] as String,
        transactionId: json['transactionId'] as String?,
        transactionType: json['transactionType'] as String? ?? 'SALE',
        tiHash: json['tiHash'] as String?,
        transferDate: json['transferDate'] as String?,
        dnLotNumber: json['dnLotNumber'] as String?,
        dnNdc: json['dnNdc'] as String?,
        dnDescription: json['dnDescription'] as String?,
        atpvReference: json['atpvReference'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (uuid != null) 'uuid': uuid,
        'sgtinId': sgtinId,
        'fromPartyGln': fromPartyGln,
        'toPartyGln': toPartyGln,
        if (transactionId != null) 'transactionId': transactionId,
        'transactionType': transactionType,
        if (tiHash != null) 'tiHash': tiHash,
        if (transferDate != null) 'transferDate': transferDate,
        if (dnLotNumber != null) 'dnLotNumber': dnLotNumber,
        if (dnNdc != null) 'dnNdc': dnNdc,
        if (dnDescription != null) 'dnDescription': dnDescription,
        if (atpvReference != null) 'atpvReference': atpvReference,
      };

  SGTINDscsaOwnership copyWith({
    int? id,
    String? uuid,
    int? sgtinId,
    String? fromPartyGln,
    String? toPartyGln,
    String? transactionId,
    String? transactionType,
    String? tiHash,
    String? transferDate,
    String? dnLotNumber,
    String? dnNdc,
    String? dnDescription,
    String? atpvReference,
  }) =>
      SGTINDscsaOwnership(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        sgtinId: sgtinId ?? this.sgtinId,
        fromPartyGln: fromPartyGln ?? this.fromPartyGln,
        toPartyGln: toPartyGln ?? this.toPartyGln,
        transactionId: transactionId ?? this.transactionId,
        transactionType: transactionType ?? this.transactionType,
        tiHash: tiHash ?? this.tiHash,
        transferDate: transferDate ?? this.transferDate,
        dnLotNumber: dnLotNumber ?? this.dnLotNumber,
        dnNdc: dnNdc ?? this.dnNdc,
        dnDescription: dnDescription ?? this.dnDescription,
        atpvReference: atpvReference ?? this.atpvReference,
      );

  @override
  List<Object?> get props => [
        id, uuid, sgtinId, fromPartyGln, toPartyGln, transactionId,
        transactionType, tiHash, transferDate, dnLotNumber, dnNdc,
        dnDescription, atpvReference,
      ];
}
