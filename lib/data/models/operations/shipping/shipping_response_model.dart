import 'package:traqtrace_app/data/models/operations/shipping/shipping_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';

class ShippingResponse {
  ShippingResponse({
    this.shippingOperationId,
    this.shippingReference,
    this.eventIds,
    this.shippedEpcsCount,
    this.epcList,
    this.status,
    this.processedAt,
    this.sourceGLN,
    this.destinationGLN,
    this.sourceLocation,
    this.destinationLocation,
    this.carrier,
    this.trackingNumber,
    this.billOfLadingNumber,
    this.purchaseOrderNumber,
    this.despatchAdviceNumber,
    this.comments,
    this.messages,
    this.processingTimeMs,
    this.metadata,
  });

  String? shippingOperationId;
  String? shippingReference;
  List<String>? eventIds;
  int? shippedEpcsCount;
  List<String>? epcList;
  ShippingStatus? status;
  DateTime? processedAt;
  String? sourceGLN;
  String? destinationGLN;
  OperationGlnDisplay? sourceLocation;
  OperationGlnDisplay? destinationLocation;
  String? carrier;
  String? trackingNumber;
  String? billOfLadingNumber;
  String? purchaseOrderNumber;
  String? despatchAdviceNumber;
  String? comments;
  List<String>? messages;
  int? processingTimeMs;
  Map<String, dynamic>? metadata;

  factory ShippingResponse.fromJson(Map<String, dynamic> json) {
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

    return ShippingResponse(
      shippingOperationId: _readNonEmptyString(json['shippingOperationId']) ??
          _readNonEmptyString(json['operationId']) ??
          _readNonEmptyString(json['id']) ??
          _readNonEmptyString(metadata?['shippingOperationId']) ??
          _readNonEmptyString(metadata?['shipping_operation_id']) ??
          _firstNonEmptyString(eventIds) ??
          _readNonEmptyString(metadata?['event_id']) ??
          _readNonEmptyString(metadata?['eventId']),
      shippingReference: _readNonEmptyString(json['shippingReference']),
      eventIds: eventIds,
      shippedEpcsCount: (json['shippedEpcsCount'] as num?)?.toInt() ??
          (json['processedEpcsCount'] as num?)?.toInt() ??
          (json['shippedItemsCount'] as num?)?.toInt() ??
          epcList?.length,
      epcList: epcList,
      status: json['status'] != null
          ? parseShippingStatus(json['status'].toString())
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())
          : null,
      sourceGLN: _readNonEmptyString(json['sourceGLN']),
      destinationGLN: _readNonEmptyString(json['destinationGLN']),
      sourceLocation: OperationGlnDisplay.fromJson(json['sourceLocation']),
      destinationLocation:
          OperationGlnDisplay.fromJson(json['destinationLocation']),
      carrier: _readNonEmptyString(json['carrier']),
      trackingNumber: _readNonEmptyString(json['trackingNumber']),
      billOfLadingNumber: _readNonEmptyString(json['billOfLadingNumber']),
      purchaseOrderNumber: _readNonEmptyString(json['purchaseOrderNumber']),
      despatchAdviceNumber: _readNonEmptyString(json['despatchAdviceNumber']),
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

  String? get operationId => shippingOperationId;

  /// ID used for list selection and detail navigation.
  String? get navigableOperationId {
    final id = _readNonEmptyString(shippingOperationId);
    if (id != null) return id;
    final eventId = _firstNonEmptyString(eventIds);
    if (eventId != null) return eventId;
    return _readNonEmptyString(metadata?['event_id']) ??
        _readNonEmptyString(metadata?['eventId']);
  }

  // Legacy compatibility aliases.
  int? get shippedItemsCount => shippedEpcsCount;
  List<String>? get childEpcList => epcList;

  bool get isSuccess => status == ShippingStatus.success;
  bool get isSuccessOrPartial =>
      status == ShippingStatus.success || status == ShippingStatus.partialSuccess;
  bool get hasErrors =>
      status == ShippingStatus.failed || status == ShippingStatus.validationError;
}
