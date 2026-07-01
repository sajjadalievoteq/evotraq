import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_status.dart';

class DecommissioningResponse {
  DecommissioningResponse({
    this.decommissioningOperationId,
    this.decommissioningReference,
    this.eventIds,
    this.decommissionedEpcsCount,
    this.epcList,
    this.status,
    this.processedAt,
    this.locationGLN,
    this.disposition,
    this.reason,
    this.comments,
    this.messages,
    this.processingTimeMs,
  });

  String? decommissioningOperationId;
  String? decommissioningReference;
  List<String>? eventIds;
  int? decommissionedEpcsCount;
  List<String>? epcList;
  DecommissioningStatus? status;
  DateTime? processedAt;
  String? locationGLN;
  String? disposition;
  String? reason;
  String? comments;
  List<String>? messages;
  int? processingTimeMs;

  factory DecommissioningResponse.fromJson(Map<String, dynamic> json) {
    final eventIds = json['eventIds'] != null
        ? List<String>.from((json['eventIds'] as List).map((e) => e.toString()))
        : null;

    final epcList = (json['epcList'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['childEpcList'] as List?)?.map((e) => e.toString()).toList();

    return DecommissioningResponse(
      decommissioningOperationId:
          _readNonEmptyString(json['decommissioningOperationId']) ??
              _readNonEmptyString(json['operationId']) ??
              _firstNonEmptyString(eventIds),
      decommissioningReference:
          _readNonEmptyString(json['decommissioningReference']),
      eventIds: eventIds,
      decommissionedEpcsCount: (json['decommissionedEpcsCount'] as num?)?.toInt() ??
          epcList?.length,
      epcList: epcList,
      status: json['status'] != null
          ? parseDecommissioningStatus(json['status'].toString())
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())
          : null,
      locationGLN: _readNonEmptyString(json['locationGLN']),
      disposition: _readNonEmptyString(json['disposition']),
      reason: _readNonEmptyString(json['reason']),
      comments: _readNonEmptyString(json['comments']),
      messages: (json['messages'] as List?)?.map((e) => e.toString()).toList(),
      processingTimeMs: (json['processingTimeMs'] as num?)?.toInt(),
    );
  }

  static String? _readNonEmptyString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String? _firstNonEmptyString(List<String>? values) {
    if (values == null || values.isEmpty) return null;
    for (final value in values) {
      final text = _readNonEmptyString(value);
      if (text != null) return text;
    }
    return null;
  }

  String? get operationId => decommissioningOperationId;

  String? get navigableOperationId {
    final id = _readNonEmptyString(decommissioningOperationId);
    if (id != null) return id;
    return _firstNonEmptyString(eventIds);
  }

  int? get itemCount => decommissionedEpcsCount ?? epcList?.length;

  bool get isSuccess => status == DecommissioningStatus.success;
  bool get isSuccessOrPartial =>
      status == DecommissioningStatus.success ||
      status == DecommissioningStatus.partialSuccess;
  bool get hasErrors =>
      status == DecommissioningStatus.failed ||
      status == DecommissioningStatus.validationError;
}
