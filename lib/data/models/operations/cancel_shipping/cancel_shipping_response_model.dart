import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';

class CancelShippingResponse {
  CancelShippingResponse({
    this.cancelShippingOperationId,
    this.cancelShippingReference,
    this.eventIds,
    this.cancelledEpcsCount,
    this.epcList,
    this.status,
    this.processedAt,
    this.sourceGLN,
    this.destinationGLN,
    this.sourceLocation,
    this.destinationLocation,
    this.cancelReason,
    this.originalShippingReference,
    this.comments,
    this.messages,
    this.processingTimeMs,
    this.metadata,
  });

  String? cancelShippingOperationId;
  String? cancelShippingReference;
  List<String>? eventIds;
  int? cancelledEpcsCount;
  List<String>? epcList;
  OperationStatus? status;
  DateTime? processedAt;
  String? sourceGLN;
  String? destinationGLN;
  OperationGlnDisplay? sourceLocation;
  OperationGlnDisplay? destinationLocation;
  String? cancelReason;
  String? originalShippingReference;
  String? comments;
  List<String>? messages;
  int? processingTimeMs;
  Map<String, dynamic>? metadata;

  factory CancelShippingResponse.fromJson(Map<String, dynamic> json) {
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

    return CancelShippingResponse(
      cancelShippingOperationId: _readNonEmptyString(json['cancelShippingOperationId']) ??
          _readNonEmptyString(json['operationId']) ??
          _readNonEmptyString(json['id']) ??
          _readNonEmptyString(metadata?['cancel_shipping_operation_id']) ??
          _firstNonEmptyString(eventIds) ??
          _readNonEmptyString(metadata?['event_id']) ??
          _readNonEmptyString(metadata?['eventId']),
      cancelShippingReference: _readNonEmptyString(json['cancelShippingReference']),
      eventIds: eventIds,
      cancelledEpcsCount: (json['cancelledEpcsCount'] as num?)?.toInt() ??
          (json['processedEpcsCount'] as num?)?.toInt() ??
          epcList?.length,
      epcList: epcList,
      status: json['status'] != null
          ? parseOperationStatus(json['status'].toString())
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())?.toLocal()
          : null,
      sourceGLN: _readNonEmptyString(json['sourceGLN']),
      destinationGLN: _readNonEmptyString(json['destinationGLN']),
      sourceLocation: OperationGlnDisplay.fromJson(json['sourceLocation']),
      destinationLocation:
          OperationGlnDisplay.fromJson(json['destinationLocation']),
      cancelReason: _readNonEmptyString(json['cancelReason']),
      originalShippingReference:
          _readNonEmptyString(json['originalShippingReference']),
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

  String? get operationId => cancelShippingOperationId;

  String? get navigableOperationId {
    final id = _readNonEmptyString(cancelShippingOperationId);
    if (id != null) return id;
    final eventId = _firstNonEmptyString(eventIds);
    if (eventId != null) return eventId;
    return _readNonEmptyString(metadata?['event_id']) ??
        _readNonEmptyString(metadata?['eventId']);
  }

  int? get shippedItemsCount => cancelledEpcsCount;
  List<String>? get childEpcList => epcList;

  bool get isSuccess => status == OperationStatus.success;
  bool get isSuccessOrPartial =>
      status == OperationStatus.success ||
      status == OperationStatus.partialSuccess;
  bool get hasErrors =>
      status == OperationStatus.failed ||
      status == OperationStatus.validationError;
}
