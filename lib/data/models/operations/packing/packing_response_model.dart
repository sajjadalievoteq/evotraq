import 'package:traqtrace_app/data/models/operations/packing/packing_status.dart';

class PackingResponse {
  String? packingOperationId;
  String? packingReference;
  List<String>? eventIds;
  String? parentContainerId;
  int? packedItemsCount;
  List<String>? childEpcList;
  PackingStatus? status;
  DateTime? processedAt;
  String? packingLocationGLN;
  String? workOrderNumber;
  String? batchNumber;
  String? productionOrder;
  String? packingLine;
  String? operatorId;
  String? comments;
  List<String>? messages;
  int? processingTimeMs;
  Map<String, dynamic>? metadata;

  PackingResponse({
    this.packingOperationId,
    this.packingReference,
    this.eventIds,
    this.parentContainerId,
    this.packedItemsCount,
    this.childEpcList,
    this.status,
    this.processedAt,
    this.packingLocationGLN,
    this.workOrderNumber,
    this.batchNumber,
    this.productionOrder,
    this.packingLine,
    this.operatorId,
    this.comments,
    this.messages,
    this.processingTimeMs,
    this.metadata,
  });

  factory PackingResponse.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'] as Map)
        : null;

    final eventIds = json['eventIds'] != null
        ? List<String>.from(json['eventIds'])
        : null;

    return PackingResponse(
      packingOperationId: _readNonEmptyString(json['packingOperationId']) ??
          _readNonEmptyString(json['operationId']) ??
          _readNonEmptyString(json['id']) ??
          _readNonEmptyString(metadata?['packingOperationId']) ??
          _readNonEmptyString(metadata?['packing_operation_id']) ??
          _firstNonEmptyString(eventIds) ??
          _readNonEmptyString(metadata?['event_id']) ??
          _readNonEmptyString(metadata?['eventId']),
      packingReference: json['packingReference'],
      eventIds: eventIds,
      parentContainerId: json['parentContainerId'],
      packedItemsCount: json['packedItemsCount'],
      childEpcList: json['childEpcList'] != null
          ? List<String>.from(json['childEpcList'])
          : null,
      status: json['status'] != null
          ? parsePackingStatus(json['status'])
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      packingLocationGLN: json['packingLocationGLN'],
      workOrderNumber: json['workOrderNumber'],
      batchNumber: json['batchNumber'],
      productionOrder: json['productionOrder'],
      packingLine: json['packingLine'],
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

  String? get operationId => packingOperationId;

  /// ID used for list selection and detail navigation.
  String? get navigableOperationId {
    final id = _readNonEmptyString(packingOperationId);
    if (id != null) return id;
    final eventId = _firstNonEmptyString(eventIds);
    if (eventId != null) return eventId;
    return _readNonEmptyString(metadata?['event_id']) ??
        _readNonEmptyString(metadata?['eventId']);
  }

  bool get isSuccess => status == PackingStatus.success;
  bool get isSuccessOrPartial =>
      status == PackingStatus.success || status == PackingStatus.partialSuccess;
  bool get hasErrors =>
      status == PackingStatus.failed || status == PackingStatus.validationError;
}
