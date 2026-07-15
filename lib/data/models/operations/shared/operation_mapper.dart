import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';

abstract final class OperationMapper {
  static String? _gln(String? raw, [OperationGlnDisplay? location]) {
    final text = raw?.trim();
    if (text != null && text.isNotEmpty) return text;
    final fromLocation = location?.glnCode.trim();
    if (fromLocation != null && fromLocation.isNotEmpty) return fromLocation;
    return null;
  }

  static Operation fromShipping(ShippingResponse r) {
    final source = _gln(r.sourceGLN, r.sourceLocation);
    final destination = _gln(r.destinationGLN, r.destinationLocation);
    return Operation(
      operationId: r.navigableOperationId,
      operationReference: r.shippingReference,
      operationType: OperationType.shipping,
      processedItemCount: r.shippedEpcsCount ?? r.epcList?.length,
      epcList: r.epcList,
      eventIds: r.eventIds,
      status: r.status,
      processedAt: r.processedAt,
      primaryGln: source,
      primaryLocation: r.sourceLocation,
      comments: r.comments,
      messages: r.messages,
      processingTimeMs: r.processingTimeMs,
      metadata: {
        ...?r.metadata,
        'sourceGLN': source,
        'destinationGLN': destination,
        'carrier': r.carrier,
        'trackingNumber': r.trackingNumber,
        'billOfLadingNumber': r.billOfLadingNumber,
        'purchaseOrderNumber': r.purchaseOrderNumber,
        'despatchAdviceNumber': r.despatchAdviceNumber,
      },
    );
  }

  static Operation fromReceiving(ReceivingResponse r) {
    final source = _gln(r.sourceGLN, r.sourceLocation);
    final receiving = _gln(r.receivingGLN, r.receivingLocation);
    return Operation(
      operationId: r.navigableOperationId,
      operationReference: r.receivingReference,
      operationType: OperationType.receiving,
      processedItemCount: r.processedEpcsCount ?? r.epcList?.length,
      epcList: r.epcList,
      eventIds: r.eventIds,
      status: r.status,
      processedAt: r.processedAt,
      primaryGln: receiving,
      primaryLocation: r.receivingLocation,
      comments: r.comments,
      messages: r.messages,
      processingTimeMs: r.processingTimeMs,
      metadata: {
        'sourceGLN': source,
        'receivingGLN': receiving,
        'carrier': r.carrier,
        'trackingNumber': r.trackingNumber,
        'purchaseOrderNumber': r.purchaseOrderNumber,
        'despatchAdviceNumber': r.despatchAdviceNumber,
        'receivingAdviceNumber': r.receivingAdviceNumber,
        'invoiceNumber': r.invoiceNumber,
        'billOfLadingNumber': r.billOfLadingNumber,
        'acceptanceStatus': r.acceptanceStatus,
        'eventDisposition': r.eventDisposition,
        'acceptingReference': r.acceptingReference,
      },
    );
  }

  static Operation fromReturnShipping(ReturnShippingResponse r) {
    final source = _gln(r.sourceGLN, r.sourceLocation);
    final destination = _gln(r.destinationGLN, r.destinationLocation);
    return Operation(
      operationId: r.navigableOperationId,
      operationReference: r.returnReference,
      operationType: OperationType.returnShipping,
      processedItemCount: r.shippedEpcsCount ?? r.epcList?.length,
      epcList: r.epcList,
      eventIds: r.eventIds,
      status: r.status,
      processedAt: r.processedAt,
      primaryGln: source,
      primaryLocation: r.sourceLocation,
      comments: r.comments,
      messages: r.messages,
      processingTimeMs: r.processingTimeMs,
      metadata: {
        ...?r.metadata,
        'sourceGLN': source,
        'destinationGLN': destination,
        'carrier': r.carrier,
        'trackingNumber': r.trackingNumber,
      },
    );
  }

  static Operation fromReturnReceiving(ReturnReceivingResponse r) {
    final source = _gln(r.sourceGLN, r.sourceLocation);
    final receiving = _gln(r.receivingGLN, r.receivingLocation);
    return Operation(
      operationId: r.navigableOperationId,
      operationReference: r.returnReceivingReference,
      operationType: OperationType.returnReceiving,
      processedItemCount: r.processedEpcsCount ?? r.epcList?.length,
      epcList: r.epcList,
      eventIds: r.eventIds,
      status: r.status,
      processedAt: r.processedAt,
      primaryGln: receiving,
      primaryLocation: r.receivingLocation,
      comments: r.comments,
      messages: r.messages,
      processingTimeMs: r.processingTimeMs,
      metadata: {
        'sourceGLN': source,
        'receivingGLN': receiving,
        'carrier': r.carrier,
        'trackingNumber': r.trackingNumber,
        'purchaseOrderNumber': r.purchaseOrderNumber,
        'despatchAdviceNumber': r.despatchAdviceNumber,
        'receivingAdviceNumber': r.receivingAdviceNumber,
        'invoiceNumber': r.invoiceNumber,
        'billOfLadingNumber': r.billOfLadingNumber,
        'gincNumber': r.gincNumber,
      },
    );
  }

  static Operation fromCancelShipping(CancelShippingResponse r) {
    final source = _gln(r.sourceGLN, r.sourceLocation);
    final destination = _gln(r.destinationGLN, r.destinationLocation);
    return Operation(
      operationId: r.navigableOperationId,
      operationReference: r.cancelShippingReference,
      operationType: OperationType.cancelShipping,
      processedItemCount: r.cancelledEpcsCount ?? r.epcList?.length,
      epcList: r.epcList,
      eventIds: r.eventIds,
      status: r.status,
      processedAt: r.processedAt,
      primaryGln: source,
      primaryLocation: r.sourceLocation,
      comments: r.comments,
      messages: r.messages,
      processingTimeMs: r.processingTimeMs,
      metadata: {
        ...?r.metadata,
        'sourceGLN': source,
        'destinationGLN': destination,
        'originalShippingReference': r.originalShippingReference,
        'cancelReason': r.cancelReason,
      },
    );
  }

  static Operation fromCancelReceiving(CancelReceivingResponse r) {
    final source = _gln(r.sourceGLN, r.sourceLocation);
    final receiving = _gln(r.receivingGLN, r.receivingLocation);
    return Operation(
      operationId: r.navigableOperationId,
      operationReference: r.cancelReceivingReference,
      operationType: OperationType.cancelReceiving,
      processedItemCount: r.cancelledEpcsCount ?? r.epcList?.length,
      epcList: r.epcList,
      eventIds: r.eventIds,
      status: r.status,
      processedAt: r.processedAt,
      primaryGln: receiving,
      primaryLocation: r.receivingLocation,
      comments: r.comments,
      messages: r.messages,
      processingTimeMs: r.processingTimeMs,
      metadata: {
        ...?r.metadata,
        'sourceGLN': source,
        'receivingGLN': receiving,
        'originalReceivingReference': r.originalReceivingReference,
        'cancelReason': r.cancelReason,
      },
    );
  }

  static Operation fromPacking(PackingResponse r) {
    final location = _gln(r.packingLocationGLN, r.operationLocation);
    return Operation(
      operationId: r.navigableOperationId,
      operationReference: r.packingReference,
      operationType: OperationType.packing,
      processedItemCount: r.packedItemsCount ?? r.childEpcList?.length,
      epcList: r.childEpcList,
      eventIds: r.eventIds,
      status: r.status,
      processedAt: r.processedAt,
      primaryGln: location,
      primaryLocation: r.operationLocation,
      comments: r.comments,
      messages: r.messages,
      processingTimeMs: r.processingTimeMs,
      metadata: {
        ...?r.metadata,
        'parentContainerId': r.parentContainerId,
        'locationGLN': location,
        'packingLine': r.packingLine,
        'workOrderNumber': r.workOrderNumber,
        'batchNumber': r.batchNumber,
        'productionOrder': r.productionOrder,
        'operatorId': r.operatorId,
      },
    );
  }

  static Operation fromUnpacking(UnpackingResponse r) {
    final location = _gln(r.unpackingLocationGLN, r.operationLocation);
    return Operation(
      operationId: r.navigableOperationId,
      operationReference: r.unpackingReference,
      operationType: OperationType.unpacking,
      processedItemCount: r.unpackedItemsCount ?? r.childEpcList?.length,
      epcList: r.childEpcList,
      eventIds: r.eventIds,
      status: r.status,
      processedAt: r.processedAt,
      primaryGln: location,
      primaryLocation: r.operationLocation,
      comments: r.comments,
      messages: r.messages,
      processingTimeMs: r.processingTimeMs,
      metadata: {
        ...?r.metadata,
        'parentContainerId': r.parentContainerId,
        'locationGLN': location,
        'unpackingLine': r.unpackingLine,
        'workOrderNumber': r.workOrderNumber,
        'batchNumber': r.batchNumber,
        'productionOrder': r.productionOrder,
        'operatorId': r.operatorId,
      },
    );
  }

  static Operation fromUpdateStatus(UpdateStatusResponse r) {
    final location = _gln(r.locationGLN, r.operationLocation);
    return Operation(
      operationId: r.navigableOperationId,
      operationReference: r.decommissioningReference,
      operationType: OperationType.updateStatus,
      processedItemCount: r.decommissionedEpcsCount ?? r.epcList?.length,
      epcList: r.epcList,
      eventIds: r.eventIds,
      status: r.status,
      processedAt: r.processedAt,
      primaryGln: location,
      primaryLocation: r.operationLocation,
      comments: r.comments,
      messages: r.messages,
      processingTimeMs: r.processingTimeMs,
      metadata: {
        'locationGLN': location,
        'disposition': r.disposition,
        'reason': r.reason,
      },
    );
  }

  static Operation fromCommissioning(CommissioningResponse r) {
    final location = _gln(r.commissioningLocationGLN) ?? _gln(r.readPointGLN);
    return Operation(
      operationId: r.commissioningOperationId,
      operationReference: r.commissioningReference,
      operationType: OperationType.commissioning,
      processedItemCount: r.commissionedCount,
      epcList: r.epcList,
      eventIds: r.eventIds,
      status: _commissioningStatus(r.status),
      processedAt: r.processedAt,
      primaryGln: location,
      comments: r.comments,
      messages: r.messages,
      processingTimeMs: r.processingTimeMs,
      metadata: {
        'gtinCode': r.gtinCode,
        'batchLotNumber': r.batchLotNumber,
        'locationGLN': location,
        'failedCount': r.failedCount,
        'totalFailed': r.failedCount,
        'totalCommissioned': r.commissionedCount,
        'readPointGLN': r.readPointGLN,
      },
    );
  }

  static Operation fromCommissioningBatch(CommissioningBatch batch) {
    final location = _gln(batch.commissioningLocationGLN);
    return Operation(
      operationId: batch.batchId,
      operationReference: batch.commissioningReference,
      operationType: OperationType.commissioning,
      processedItemCount: batch.totalCommissioned,
      eventIds: batch.epcisEventId != null ? [batch.epcisEventId!] : null,
      processedAt: batch.completedAt ?? batch.createdAt,
      primaryGln: location,
      metadata: {
        'gtinCode': batch.gtinCode,
        'batchLotNumber': batch.batchLotNumber,
        'locationGLN': location,
        'totalCommissioned': batch.totalCommissioned,
        'totalFailed': batch.totalFailed,
        'commissioningBatchStatus': batch.status.name,
        'operatorId': batch.operatorId,
      },
    );
  }

  static OperationStatus? _commissioningStatus(CommissioningStatus? status) {
    return switch (status) {
      CommissioningStatus.success => OperationStatus.success,
      CommissioningStatus.partialSuccess => OperationStatus.partialSuccess,
      CommissioningStatus.failed => OperationStatus.failed,
      CommissioningStatus.validationError => OperationStatus.validationError,
      null => null,
    };
  }
}

extension ShippingResponseOperationX on ShippingResponse {
  Operation toOperation() => OperationMapper.fromShipping(this);
}

extension ReceivingResponseOperationX on ReceivingResponse {
  Operation toOperation() => OperationMapper.fromReceiving(this);
}

extension ReturnShippingResponseOperationX on ReturnShippingResponse {
  Operation toOperation() => OperationMapper.fromReturnShipping(this);
}

extension ReturnReceivingResponseOperationX on ReturnReceivingResponse {
  Operation toOperation() => OperationMapper.fromReturnReceiving(this);
}

extension CancelShippingResponseOperationX on CancelShippingResponse {
  Operation toOperation() => OperationMapper.fromCancelShipping(this);
}

extension CancelReceivingResponseOperationX on CancelReceivingResponse {
  Operation toOperation() => OperationMapper.fromCancelReceiving(this);
}

extension PackingResponseOperationX on PackingResponse {
  Operation toOperation() => OperationMapper.fromPacking(this);
}

extension UnpackingResponseOperationX on UnpackingResponse {
  Operation toOperation() => OperationMapper.fromUnpacking(this);
}

extension UpdateStatusResponseOperationX on UpdateStatusResponse {
  Operation toOperation() => OperationMapper.fromUpdateStatus(this);
}

extension CommissioningResponseOperationX on CommissioningResponse {
  Operation toOperation() => OperationMapper.fromCommissioning(this);
}
