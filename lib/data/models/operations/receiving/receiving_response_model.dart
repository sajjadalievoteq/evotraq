import 'package:traqtrace_app/data/models/operations/receiving/receiving_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_gln_validators.dart';

class ReceivingResponse {
  ReceivingResponse({
    this.receivingOperationId,
    this.receivingReference,
    this.eventIds,
    this.processedEpcsCount,
    this.epcList,
    this.status,
    this.processedAt,
    this.sourceGLN,
    this.receivingGLN,
    this.sourceLocation,
    this.receivingLocation,
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
    this.eventDisposition,
    this.acceptanceStatus,
    this.acceptingReference,
  });

  String? receivingOperationId;
  String? receivingReference;
  List<String>? eventIds;
  int? processedEpcsCount;
  List<String>? epcList;
  ReceivingStatus? status;
  DateTime? processedAt;
  String? sourceGLN;
  String? receivingGLN;
  OperationGlnDisplay? sourceLocation;
  OperationGlnDisplay? receivingLocation;
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
  String? eventDisposition;
  String? acceptanceStatus;
  String? acceptingReference;

  factory ReceivingResponse.fromJson(Map<String, dynamic> json) {
    final eventIds = json['eventIds'] != null
        ? List<String>.from(
            (json['eventIds'] as List).map((e) => e.toString()),
          )
        : null;

    final epcList = (json['epcList'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['childEpcList'] as List?)?.map((e) => e.toString()).toList();

    return ReceivingResponse(
      receivingOperationId: _str(json['receivingOperationId']) ??
          _str(json['navigableOperationId']) ??
          _str(json['operationId']),
      receivingReference: _str(json['receivingReference']),
      eventIds: eventIds,
      processedEpcsCount: (json['processedEpcsCount'] as num?)?.toInt() ??
          (json['shippedEpcsCount'] as num?)?.toInt() ??
          epcList?.length,
      epcList: epcList,
      status: json['status'] != null
          ? parseReceivingStatus(json['status'].toString())
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())
          : null,
      sourceGLN: _parseGln(json['sourceGLN'] ?? json['sourceGln']),
      receivingGLN: _parseGln(
        json['receivingGLN'] ??
            json['receivingGln'] ??
            json['destinationGLN'] ??
            json['destinationGln'],
      ),
      sourceLocation: OperationGlnDisplay.fromJson(json['sourceLocation']),
      receivingLocation: OperationGlnDisplay.fromJson(json['receivingLocation']),
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
      eventDisposition: _str(json['eventDisposition']),
      acceptanceStatus: _str(json['acceptanceStatus']),
      acceptingReference: _str(json['acceptingReference']),
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static String? _parseGln(dynamic v) {
    final raw = _str(v);
    if (raw == null) return null;
    final normalized = EpcisGlnValidators.parseGlnToCode(raw);
    return normalized.trim().isEmpty ? null : normalized;
  }

  String? get navigableOperationId {
    final id = _str(receivingOperationId);
    if (id != null) return id;
    return eventIds?.isNotEmpty == true ? _str(eventIds!.first) : null;
  }

  bool get isSuccess => status == ReceivingStatus.success;
  bool get isAccepted =>
      status == ReceivingStatus.accepted ||
      acceptanceStatus?.toUpperCase() == 'ACCEPTED';
  bool get isAwaitingAcceptance {
    if (isAccepted) return false;
    final disp = eventDisposition?.toLowerCase() ?? '';
    return disp.contains('in_progress');
  }

  bool get isSuccessOrPartial =>
      status == ReceivingStatus.success ||
      status == ReceivingStatus.partialSuccess;
  bool get hasErrors =>
      status == ReceivingStatus.failed ||
      status == ReceivingStatus.validationError;
}
