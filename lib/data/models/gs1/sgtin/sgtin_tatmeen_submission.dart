import 'package:equatable/equatable.dart';

class SGTINTatmeenSubmission extends Equatable {
  final int? id;
  final String? uuid;
  final int sgtinId;
  final String? submissionId;
  final String submissionStatus;
  final String submissionType;
  final String? submittedAt;
  final String? acceptedAt;
  final String? rejectedAt;
  final String? rejectionReason;
  final String? retryAt;
  final String? payloadHash;
  final String? responseBody;

  const SGTINTatmeenSubmission({
    this.id,
    this.uuid,
    required this.sgtinId,
    this.submissionId,
    required this.submissionStatus,
    required this.submissionType,
    this.submittedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.retryAt,
    this.payloadHash,
    this.responseBody,
  });

  factory SGTINTatmeenSubmission.fromJson(Map<String, dynamic> json) =>
      SGTINTatmeenSubmission(
        id: json['id'] as int?,
        uuid: json['uuid'] as String?,
        sgtinId: json['sgtinId'] as int,
        submissionId: json['submissionId'] as String?,
        submissionStatus: json['submissionStatus'] as String,
        submissionType: json['submissionType'] as String,
        submittedAt: json['submittedAt'] as String?,
        acceptedAt: json['acceptedAt'] as String?,
        rejectedAt: json['rejectedAt'] as String?,
        rejectionReason: json['rejectionReason'] as String?,
        retryAt: json['retryAt'] as String?,
        payloadHash: json['payloadHash'] as String?,
        responseBody: json['responseBody'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (uuid != null) 'uuid': uuid,
        'sgtinId': sgtinId,
        if (submissionId != null) 'submissionId': submissionId,
        'submissionStatus': submissionStatus,
        'submissionType': submissionType,
        if (submittedAt != null) 'submittedAt': submittedAt,
        if (acceptedAt != null) 'acceptedAt': acceptedAt,
        if (rejectedAt != null) 'rejectedAt': rejectedAt,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
        if (retryAt != null) 'retryAt': retryAt,
        if (payloadHash != null) 'payloadHash': payloadHash,
        if (responseBody != null) 'responseBody': responseBody,
      };

  SGTINTatmeenSubmission copyWith({
    int? id,
    String? uuid,
    int? sgtinId,
    String? submissionId,
    String? submissionStatus,
    String? submissionType,
    String? submittedAt,
    String? acceptedAt,
    String? rejectedAt,
    String? rejectionReason,
    String? retryAt,
    String? payloadHash,
    String? responseBody,
  }) =>
      SGTINTatmeenSubmission(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        sgtinId: sgtinId ?? this.sgtinId,
        submissionId: submissionId ?? this.submissionId,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        submissionType: submissionType ?? this.submissionType,
        submittedAt: submittedAt ?? this.submittedAt,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        rejectedAt: rejectedAt ?? this.rejectedAt,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        retryAt: retryAt ?? this.retryAt,
        payloadHash: payloadHash ?? this.payloadHash,
        responseBody: responseBody ?? this.responseBody,
      );

  @override
  List<Object?> get props => [
        id, uuid, sgtinId, submissionId, submissionStatus, submissionType,
        submittedAt, acceptedAt, rejectedAt, rejectionReason,
        retryAt, payloadHash, responseBody,
      ];
}
