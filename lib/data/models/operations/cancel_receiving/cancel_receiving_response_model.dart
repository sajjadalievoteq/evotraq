import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';

class CancelReceivingResponse {
  CancelReceivingResponse({
    this.cancelReceivingOperationId,
    this.cancelReceivingReference,
    this.eventIds,
    this.cancelledEpcsCount,
    this.epcList,
    this.status,
    this.processedAt,
    this.sourceGLN,
    this.receivingGLN,
    this.sourceLocation,
    this.receivingLocation,
    this.cancelReason,
    this.originalReceivingReference,
    this.comments,
    this.messages,
    this.processingTimeMs,
    this.metadata,
  });

  String? cancelReceivingOperationId;
  String? cancelReceivingReference;
  List<String>? eventIds;
  int? cancelledEpcsCount;
  List<String>? epcList;
  CancelReceivingStatus? status;
  DateTime? processedAt;
  String? sourceGLN;
  String? receivingGLN;
  OperationGlnDisplay? sourceLocation;
  OperationGlnDisplay? receivingLocation;
  String? cancelReason;
  String? originalReceivingReference;
  String? comments;
  List<String>? messages;
  int? processingTimeMs;
  Map<String, dynamic>? metadata;

  factory CancelReceivingResponse.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'] as Map)
        : null;

    final eventIds = json['eventIds'] != null
        ? List<String>.from((json['eventIds'] as List).map((e) => e.toString()))
        : null;

    final epcList = (json['epcList'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['childEpcList'] as List?)?.map((e) => e.toString()).toList();

    return CancelReceivingResponse(
      cancelReceivingOperationId:
          _readNonEmptyString(json['cancelReceivingOperationId']) ??
              _readNonEmptyString(json['operationId']) ??
              _readNonEmptyString(json['id']) ??
              _readNonEmptyString(metadata?['cancel_receiving_operation_id']) ??
              _firstNonEmptyString(eventIds) ??
              _readNonEmptyString(metadata?['event_id']) ??
              _readNonEmptyString(metadata?['eventId']),
      cancelReceivingReference:
          _readNonEmptyString(json['cancelReceivingReference']),
      eventIds: eventIds,
      cancelledEpcsCount: (json['cancelledEpcsCount'] as num?)?.toInt() ??
          (json['processedEpcsCount'] as num?)?.toInt() ??
          epcList?.length,
      epcList: epcList,
      status: json['status'] != null
          ? parseCancelReceivingStatus(json['status'].toString())
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())
          : null,
      sourceGLN: _readNonEmptyString(json['sourceGLN']),
      receivingGLN: _readNonEmptyString(json['receivingGLN']),
      sourceLocation: OperationGlnDisplay.fromJson(json['sourceLocation']),
      receivingLocation: OperationGlnDisplay.fromJson(json['receivingLocation']),
      cancelReason: _readNonEmptyString(json['cancelReason']),
      originalReceivingReference:
          _readNonEmptyString(json['originalReceivingReference']),
      comments: _readNonEmptyString(json['comments']),
      messages: (json['messages'] as List?)?.map((e) => e.toString()).toList(),
      processingTimeMs: (json['processingTimeMs'] as num?)?.toInt(),
      metadata: metadata,
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

  String? get operationId => cancelReceivingOperationId;

  String? get navigableOperationId {
    final id = _readNonEmptyString(cancelReceivingOperationId);
    if (id != null) return id;
    final eventId = _firstNonEmptyString(eventIds);
    if (eventId != null) return eventId;
    return _readNonEmptyString(metadata?['event_id']) ??
        _readNonEmptyString(metadata?['eventId']);
  }

  int? get shippedItemsCount => cancelledEpcsCount;
  List<String>? get childEpcList => epcList;

  bool get isSuccess => status == CancelReceivingStatus.success;
  bool get isSuccessOrPartial =>
      status == CancelReceivingStatus.success ||
      status == CancelReceivingStatus.partialSuccess;
  bool get hasErrors =>
      status == CancelReceivingStatus.failed ||
      status == CancelReceivingStatus.validationError;
}
