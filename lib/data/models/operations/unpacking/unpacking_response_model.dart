import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';

class UnpackingResponse {
  String? unpackingOperationId;
  String? unpackingReference;
  List<String>? eventIds;
  String? parentContainerId;
  int? unpackedItemsCount;
  List<String>? childEpcList;
  UnpackingStatus? status;
  DateTime? processedAt;
  String? unpackingLocationGLN;
  OperationGlnDisplay? operationLocation;
  String? workOrderNumber;
  String? batchNumber;
  String? productionOrder;
  String? unpackingLine;
  String? operatorId;
  String? comments;
  List<String>? messages;
  int? processingTimeMs;
  Map<String, dynamic>? metadata;

  UnpackingResponse({
    this.unpackingOperationId,
    this.unpackingReference,
    this.eventIds,
    this.parentContainerId,
    this.unpackedItemsCount,
    this.childEpcList,
    this.status,
    this.processedAt,
    this.unpackingLocationGLN,
    this.operationLocation,
    this.workOrderNumber,
    this.batchNumber,
    this.productionOrder,
    this.unpackingLine,
    this.operatorId,
    this.comments,
    this.messages,
    this.processingTimeMs,
    this.metadata,
  });

  factory UnpackingResponse.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'] as Map)
        : null;

    final eventIds = json['eventIds'] != null
        ? List<String>.from(json['eventIds'])
        : null;

    return UnpackingResponse(
      unpackingOperationId: _readNonEmptyString(json['unpackingOperationId']) ??
          _readNonEmptyString(json['operationId']) ??
          _readNonEmptyString(json['id']) ??
          _readNonEmptyString(metadata?['unpackingOperationId']) ??
          _readNonEmptyString(metadata?['unpacking_operation_id']) ??
          _firstNonEmptyString(eventIds) ??
          _readNonEmptyString(metadata?['event_id']) ??
          _readNonEmptyString(metadata?['eventId']),
      unpackingReference: json['unpackingReference'],
      eventIds: eventIds,
      parentContainerId: json['parentContainerId'],
      unpackedItemsCount: json['unpackedItemsCount'],
      childEpcList: json['childEpcList'] != null
          ? List<String>.from(json['childEpcList'])
          : null,
      status: json['status'] != null
          ? parseUnpackingStatus(json['status'])
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      unpackingLocationGLN: json['unpackingLocationGLN'],
      operationLocation: OperationGlnDisplay.fromJson(json['operationLocation']),
      workOrderNumber: json['workOrderNumber'],
      batchNumber: json['batchNumber'],
      productionOrder: json['productionOrder'],
      unpackingLine: json['unpackingLine'],
      operatorId: json['operatorId'],
      comments: json['comments'],
      messages: json['messages'] != null
          ? List<String>.from(json['messages'])
          : null,
      processingTimeMs: json['processingTimeMs'],
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

  String? get operationId => unpackingOperationId;

  /// ID used for list selection and detail navigation.
  String? get navigableOperationId {
    final id = _readNonEmptyString(unpackingOperationId);
    if (id != null) return id;
    final eventId = _firstNonEmptyString(eventIds);
    if (eventId != null) return eventId;
    return _readNonEmptyString(metadata?['event_id']) ??
        _readNonEmptyString(metadata?['eventId']);
  }

  bool get isSuccess => status == UnpackingStatus.success;
  bool get isSuccessOrPartial =>
      status == UnpackingStatus.success || status == UnpackingStatus.partialSuccess;
  bool get hasErrors =>
      status == UnpackingStatus.failed || status == UnpackingStatus.validationError;
}
