import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_status.dart';

class ReturnReceivingResponse {
  ReturnReceivingResponse({
    this.returnReceivingOperationId,
    this.returnReceivingReference,
    this.eventIds,
    this.processedEpcsCount,
    this.epcList,
    this.status,
    this.processedAt,
    this.sourceGLN,
    this.receivingGLN,
    this.purchaseOrderNumber,
    this.despatchAdviceNumber,
    this.receivingAdviceNumber,
    this.invoiceNumber,
    this.billOfLadingNumber,
    this.carrier,
    this.trackingNumber,
    this.comments,
    this.messages,
    this.processingTimeMs,
  });

  String? returnReceivingOperationId;
  String? returnReceivingReference;
  List<String>? eventIds;
  int? processedEpcsCount;
  List<String>? epcList;
  ReturnReceivingStatus? status;
  DateTime? processedAt;
  String? sourceGLN;
  String? receivingGLN;
  String? purchaseOrderNumber;
  String? despatchAdviceNumber;
  String? receivingAdviceNumber;
  String? invoiceNumber;
  String? billOfLadingNumber;
  String? carrier;
  String? trackingNumber;
  String? comments;
  List<String>? messages;
  int? processingTimeMs;

  factory ReturnReceivingResponse.fromJson(Map<String, dynamic> json) {
    final eventIds = json['eventIds'] != null
        ? List<String>.from(
            (json['eventIds'] as List).map((e) => e.toString()),
          )
        : null;

    final epcList = (json['epcList'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['childEpcList'] as List?)?.map((e) => e.toString()).toList();

    return ReturnReceivingResponse(
      returnReceivingOperationId: _str(json['returnReceivingOperationId']) ??
          _str(json['navigableOperationId']) ??
          _str(json['operationId']),
      returnReceivingReference: _str(json['returnReceivingReference']),
      eventIds: eventIds,
      processedEpcsCount: (json['processedEpcsCount'] as num?)?.toInt() ??
          (json['shippedEpcsCount'] as num?)?.toInt() ??
          epcList?.length,
      epcList: epcList,
      status: json['status'] != null
          ? parseReturnReceivingStatus(json['status'].toString())
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())
          : null,
      sourceGLN: _str(json['sourceGLN']),
      receivingGLN: _str(json['receivingGLN']),
      purchaseOrderNumber: _str(json['purchaseOrderNumber']),
      despatchAdviceNumber: _str(json['despatchAdviceNumber']),
      receivingAdviceNumber: _str(json['receivingAdviceNumber']),
      invoiceNumber: _str(json['invoiceNumber']),
      billOfLadingNumber: _str(json['billOfLadingNumber']),
      carrier: _str(json['carrier']),
      trackingNumber: _str(json['trackingNumber']),
      comments: _str(json['comments']),
      messages:
          (json['messages'] as List?)?.map((e) => e.toString()).toList(),
      processingTimeMs: (json['processingTimeMs'] as num?)?.toInt(),
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  String? get navigableOperationId {
    final id = _str(returnReceivingOperationId);
    if (id != null) return id;
    return eventIds?.isNotEmpty == true ? _str(eventIds!.first) : null;
  }

  bool get isSuccess => status == ReturnReceivingStatus.success;
  bool get isSuccessOrPartial =>
      status == ReturnReceivingStatus.success ||
      status == ReturnReceivingStatus.partialSuccess;
  bool get hasErrors =>
      status == ReturnReceivingStatus.failed ||
      status == ReturnReceivingStatus.validationError;
}
