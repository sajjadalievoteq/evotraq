import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';

abstract final class OperationMapper {
  static Operation fromShipping(ShippingResponse r) => Operation(
        operationId: r.navigableOperationId,
        operationReference: r.shippingReference,
        operationType: OperationType.shipping,
        processedItemCount: r.shippedEpcsCount ?? r.epcList?.length,
        epcList: r.epcList,
        eventIds: r.eventIds,
        status: r.status,
        processedAt: r.processedAt,
        primaryGln: r.sourceGLN,
        primaryLocation: r.sourceLocation,
        comments: r.comments,
        messages: r.messages,
        processingTimeMs: r.processingTimeMs,
        metadata: {
          ...?r.metadata,
          'sourceGLN': r.sourceGLN,
          'destinationGLN': r.destinationGLN,
          'carrier': r.carrier,
          'trackingNumber': r.trackingNumber,
          'billOfLadingNumber': r.billOfLadingNumber,
          'purchaseOrderNumber': r.purchaseOrderNumber,
          'despatchAdviceNumber': r.despatchAdviceNumber,
        },
      );

  static Operation fromReceiving(ReceivingResponse r) => Operation(
        operationId: r.navigableOperationId,
        operationReference: r.receivingReference,
        operationType: OperationType.receiving,
        processedItemCount: r.processedEpcsCount ?? r.epcList?.length,
        epcList: r.epcList,
        eventIds: r.eventIds,
        status: r.status,
        processedAt: r.processedAt,
        primaryGln: r.receivingGLN,
        primaryLocation: r.receivingLocation,
        comments: r.comments,
        messages: r.messages,
        processingTimeMs: r.processingTimeMs,
        metadata: {
          'sourceGLN': r.sourceGLN,
          'receivingGLN': r.receivingGLN,
          'carrier': r.carrier,
          'trackingNumber': r.trackingNumber,
          'purchaseOrderNumber': r.purchaseOrderNumber,
          'despatchAdviceNumber': r.despatchAdviceNumber,
          'receivingAdviceNumber': r.receivingAdviceNumber,
          'acceptanceStatus': r.acceptanceStatus,
        },
      );

  static Operation fromReturnShipping(ReturnShippingResponse r) => Operation(
        operationId: r.navigableOperationId,
        operationReference: r.returnReference,
        operationType: OperationType.returnShipping,
        processedItemCount: r.shippedEpcsCount ?? r.epcList?.length,
        epcList: r.epcList,
        eventIds: r.eventIds,
        status: r.status,
        processedAt: r.processedAt,
        primaryGln: r.sourceGLN,
        primaryLocation: r.sourceLocation,
        comments: r.comments,
        messages: r.messages,
        processingTimeMs: r.processingTimeMs,
        metadata: {
          ...?r.metadata,
          'sourceGLN': r.sourceGLN,
          'destinationGLN': r.destinationGLN,
          'carrier': r.carrier,
          'trackingNumber': r.trackingNumber,
        },
      );

  static Operation fromReturnReceiving(ReturnReceivingResponse r) => Operation(
        operationId: r.navigableOperationId,
        operationReference: r.returnReceivingReference,
        operationType: OperationType.returnReceiving,
        processedItemCount: r.processedEpcsCount ?? r.epcList?.length,
        epcList: r.epcList,
        eventIds: r.eventIds,
        status: r.status,
        processedAt: r.processedAt,
        primaryGln: r.receivingGLN,
        primaryLocation: r.receivingLocation,
        comments: r.comments,
        messages: r.messages,
        processingTimeMs: r.processingTimeMs,
        metadata: {
          'sourceGLN': r.sourceGLN,
          'receivingGLN': r.receivingGLN,
        },
      );

  static Operation fromCancelShipping(CancelShippingResponse r) => Operation(
        operationId: r.navigableOperationId,
        operationReference: r.cancelShippingReference,
        operationType: OperationType.cancelShipping,
        processedItemCount: r.cancelledEpcsCount ?? r.epcList?.length,
        epcList: r.epcList,
        eventIds: r.eventIds,
        status: r.status,
        processedAt: r.processedAt,
        primaryGln: r.sourceGLN,
        primaryLocation: r.sourceLocation,
        comments: r.comments,
        messages: r.messages,
        processingTimeMs: r.processingTimeMs,
        metadata: {
          ...?r.metadata,
          'sourceGLN': r.sourceGLN,
          'destinationGLN': r.destinationGLN,
          'originalShippingReference': r.originalShippingReference,
          'cancelReason': r.cancelReason,
        },
      );

  static Operation fromCancelReceiving(CancelReceivingResponse r) => Operation(
        operationId: r.navigableOperationId,
        operationReference: r.cancelReceivingReference,
        operationType: OperationType.cancelReceiving,
        processedItemCount: r.cancelledEpcsCount ?? r.epcList?.length,
        epcList: r.epcList,
        eventIds: r.eventIds,
        status: r.status,
        processedAt: r.processedAt,
        primaryGln: r.receivingGLN,
        primaryLocation: r.receivingLocation,
        comments: r.comments,
        messages: r.messages,
        processingTimeMs: r.processingTimeMs,
        metadata: {
          'sourceGLN': r.sourceGLN,
          'receivingGLN': r.receivingGLN,
          'originalReceivingReference': r.originalReceivingReference,
          'cancelReason': r.cancelReason,
        },
      );

  static Operation fromPacking(PackingResponse r) => Operation(
        operationId: r.navigableOperationId,
        operationReference: r.packingReference,
        operationType: OperationType.packing,
        processedItemCount: r.packedItemsCount ?? r.childEpcList?.length,
        epcList: r.childEpcList,
        eventIds: r.eventIds,
        status: r.status,
        processedAt: r.processedAt,
        primaryGln: r.packingLocationGLN,
        primaryLocation: r.operationLocation,
        comments: r.comments,
        messages: r.messages,
        processingTimeMs: r.processingTimeMs,
        metadata: {
          ...?r.metadata,
          'parentContainerId': r.parentContainerId,
          'packingLine': r.packingLine,
          'workOrderNumber': r.workOrderNumber,
          'batchNumber': r.batchNumber,
          'productionOrder': r.productionOrder,
          'operatorId': r.operatorId,
        },
      );

  static Operation fromUnpacking(UnpackingResponse r) => Operation(
        operationId: r.navigableOperationId,
        operationReference: r.unpackingReference,
        operationType: OperationType.unpacking,
        processedItemCount: r.unpackedItemsCount ?? r.childEpcList?.length,
        epcList: r.childEpcList,
        eventIds: r.eventIds,
        status: r.status,
        processedAt: r.processedAt,
        primaryGln: r.unpackingLocationGLN,
        primaryLocation: r.operationLocation,
        comments: r.comments,
        messages: r.messages,
        processingTimeMs: r.processingTimeMs,
        metadata: {
          ...?r.metadata,
          'parentContainerId': r.parentContainerId,
          'unpackingLine': r.unpackingLine,
          'workOrderNumber': r.workOrderNumber,
          'batchNumber': r.batchNumber,
          'productionOrder': r.productionOrder,
          'operatorId': r.operatorId,
        },
      );

  static Operation fromUpdateStatus(UpdateStatusResponse r) => Operation(
        operationId: r.navigableOperationId,
        operationReference: r.decommissioningReference,
        operationType: OperationType.updateStatus,
        processedItemCount: r.decommissionedEpcsCount ?? r.epcList?.length,
        epcList: r.epcList,
        eventIds: r.eventIds,
        status: r.status,
        processedAt: r.processedAt,
        primaryGln: r.locationGLN,
        primaryLocation: r.operationLocation,
        comments: r.comments,
        messages: r.messages,
        processingTimeMs: r.processingTimeMs,
        metadata: {
          'locationGLN': r.locationGLN,
          'disposition': r.disposition,
          'reason': r.reason,
        },
      );

  static Operation fromCommissioning(CommissioningResponse r) => Operation(
        operationId: r.commissioningOperationId,
        operationReference: r.commissioningReference,
        operationType: OperationType.commissioning,
        processedItemCount: r.commissionedCount,
        epcList: r.epcList,
        eventIds: r.eventIds,
        status: _commissioningStatus(r.status),
        processedAt: r.processedAt,
        primaryGln: r.commissioningLocationGLN,
        comments: r.comments,
        messages: r.messages,
        processingTimeMs: r.processingTimeMs,
        metadata: {
          'gtinCode': r.gtinCode,
          'batchLotNumber': r.batchLotNumber,
          'failedCount': r.failedCount,
          'readPointGLN': r.readPointGLN,
        },
      );

  static Operation fromCommissioningBatch(CommissioningBatch batch) => Operation(
        operationId: batch.batchId,
        operationReference: batch.commissioningReference,
        operationType: OperationType.commissioning,
        processedItemCount: batch.totalCommissioned,
        processedAt: batch.createdAt,
        primaryGln: batch.commissioningLocationGLN,
        metadata: {
          'gtinCode': batch.gtinCode,
          'batchLotNumber': batch.batchLotNumber,
          'totalCommissioned': batch.totalCommissioned,
          'totalFailed': batch.totalFailed,
          'commissioningBatchStatus': batch.status.name,
        },
      );

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
