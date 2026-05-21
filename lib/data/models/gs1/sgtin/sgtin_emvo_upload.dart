import 'package:equatable/equatable.dart';

class SGTINEmvoUpload extends Equatable {
  final int? id;
  final String? uuid;
  final int sgtinId;
  final int uploadAttemptCount;
  final String uploadStatus;
  final Map<String, dynamic>? uploadResponse;
  final String? acknowledgedAt;
  final String? retryAt;
  final String? batchId;
  final String? uploadInitiatedAt;
  final String? lastErrorMessage;
  final String? emvoReferenceId;

  const SGTINEmvoUpload({
    this.id,
    this.uuid,
    required this.sgtinId,
    required this.uploadAttemptCount,
    required this.uploadStatus,
    this.uploadResponse,
    this.acknowledgedAt,
    this.retryAt,
    this.batchId,
    this.uploadInitiatedAt,
    this.lastErrorMessage,
    this.emvoReferenceId,
  });

  factory SGTINEmvoUpload.fromJson(Map<String, dynamic> json) =>
      SGTINEmvoUpload(
        id: json['id'] as int?,
        uuid: json['uuid'] as String?,
        sgtinId: json['sgtinId'] as int,
        uploadAttemptCount: json['uploadAttemptCount'] as int? ?? 0,
        uploadStatus: json['uploadStatus'] as String,
        uploadResponse: json['uploadResponse'] as Map<String, dynamic>?,
        acknowledgedAt: json['acknowledgedAt'] as String?,
        retryAt: json['retryAt'] as String?,
        batchId: json['batchId'] as String?,
        uploadInitiatedAt: json['uploadInitiatedAt'] as String?,
        lastErrorMessage: json['lastErrorMessage'] as String?,
        emvoReferenceId: json['emvoReferenceId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (uuid != null) 'uuid': uuid,
        'sgtinId': sgtinId,
        'uploadAttemptCount': uploadAttemptCount,
        'uploadStatus': uploadStatus,
        if (uploadResponse != null) 'uploadResponse': uploadResponse,
        if (acknowledgedAt != null) 'acknowledgedAt': acknowledgedAt,
        if (retryAt != null) 'retryAt': retryAt,
        if (batchId != null) 'batchId': batchId,
        if (uploadInitiatedAt != null) 'uploadInitiatedAt': uploadInitiatedAt,
        if (lastErrorMessage != null) 'lastErrorMessage': lastErrorMessage,
        if (emvoReferenceId != null) 'emvoReferenceId': emvoReferenceId,
      };

  SGTINEmvoUpload copyWith({
    int? id,
    String? uuid,
    int? sgtinId,
    int? uploadAttemptCount,
    String? uploadStatus,
    Map<String, dynamic>? uploadResponse,
    String? acknowledgedAt,
    String? retryAt,
    String? batchId,
    String? uploadInitiatedAt,
    String? lastErrorMessage,
    String? emvoReferenceId,
  }) =>
      SGTINEmvoUpload(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        sgtinId: sgtinId ?? this.sgtinId,
        uploadAttemptCount: uploadAttemptCount ?? this.uploadAttemptCount,
        uploadStatus: uploadStatus ?? this.uploadStatus,
        uploadResponse: uploadResponse ?? this.uploadResponse,
        acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
        retryAt: retryAt ?? this.retryAt,
        batchId: batchId ?? this.batchId,
        uploadInitiatedAt: uploadInitiatedAt ?? this.uploadInitiatedAt,
        lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
        emvoReferenceId: emvoReferenceId ?? this.emvoReferenceId,
      );

  @override
  List<Object?> get props => [
        id, uuid, sgtinId, uploadAttemptCount, uploadStatus,
        uploadResponse, acknowledgedAt, retryAt, batchId,
        uploadInitiatedAt, lastErrorMessage, emvoReferenceId,
      ];
}
