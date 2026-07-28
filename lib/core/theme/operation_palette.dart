import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

/// Theme-aware semantic colors for operations, statuses, and EPC/event types.
/// Resolved by [Brightness] so light and dark stay consistent across the app.
@immutable
class OperationPalette {
  const OperationPalette({
    required this.opCommissioning,
    required this.opPacking,
    required this.opUnpacking,
    required this.opShipping,
    required this.opReceiving,
    required this.opReturnShipping,
    required this.opReturnReceiving,
    required this.opCancelShipping,
    required this.opCancelReceiving,
    required this.opUpdateStatus,
    required this.statusSuccess,
    required this.statusPartialSuccess,
    required this.statusFailed,
    required this.statusValidationError,
    required this.statusAccepted,
    required this.batchPending,
    required this.batchInProgress,
    required this.itemReserved,
    required this.itemAllocated,
    required this.itemCommissioned,
    required this.itemActive,
    required this.itemInTransit,
    required this.itemReceived,
    required this.itemDispensed,
    required this.itemReturned,
    required this.itemDestroyed,
    required this.itemRecalled,
    required this.itemStolen,
    required this.itemExpired,
    required this.itemException,
    required this.ssccDraft,
    required this.ssccAllocated,
    required this.ssccActive,
    required this.ssccInTransit,
    required this.ssccReceived,
    required this.ssccDecommissioned,
    required this.ssccVoided,
    required this.epcSgtin,
    required this.epcSscc,
    required this.epcGtin,
    required this.epcInvalid,
    required this.eventObject,
    required this.eventAggregation,
    required this.eventTransactionAdmin,
    required this.eventTransactionEpcis,
    required this.eventTransformation,
    required this.eventUnknown,
    required this.severityCritical,
    required this.severityHigh,
    required this.severityMedium,
    required this.severityLow,
    required this.neutral,
    required this.supplyActive,
    required this.supplyInactive,
    required this.supplyPending,
    required this.nodeManufacturer,
    required this.nodeDistributor,
    required this.nodeRetailer,
    required this.nodeWarehouse,
    required this.bizInspecting,
    required this.bizTransforming,
    required this.journeyStart,
    required this.journeyLatest,
    required this.info,
    required this.infoSoft,
    required this.chartSeries,
  });

  final Color opCommissioning;
  final Color opPacking;
  final Color opUnpacking;
  final Color opShipping;
  final Color opReceiving;
  final Color opReturnShipping;
  final Color opReturnReceiving;
  final Color opCancelShipping;
  final Color opCancelReceiving;
  final Color opUpdateStatus;

  final Color statusSuccess;
  final Color statusPartialSuccess;
  final Color statusFailed;
  final Color statusValidationError;
  final Color statusAccepted;

  final Color batchPending;
  final Color batchInProgress;

  final Color itemReserved;
  final Color itemAllocated;
  final Color itemCommissioned;
  final Color itemActive;
  final Color itemInTransit;
  final Color itemReceived;
  final Color itemDispensed;
  final Color itemReturned;
  final Color itemDestroyed;
  final Color itemRecalled;
  final Color itemStolen;
  final Color itemExpired;
  final Color itemException;

  final Color ssccDraft;
  final Color ssccAllocated;
  final Color ssccActive;
  final Color ssccInTransit;
  final Color ssccReceived;
  final Color ssccDecommissioned;
  final Color ssccVoided;

  final Color epcSgtin;
  final Color epcSscc;
  final Color epcGtin;
  final Color epcInvalid;

  final Color eventObject;
  final Color eventAggregation;
  final Color eventTransactionAdmin;
  final Color eventTransactionEpcis;
  final Color eventTransformation;
  final Color eventUnknown;

  final Color severityCritical;
  final Color severityHigh;
  final Color severityMedium;
  final Color severityLow;
  final Color neutral;

  final Color supplyActive;
  final Color supplyInactive;
  final Color supplyPending;

  final Color nodeManufacturer;
  final Color nodeDistributor;
  final Color nodeRetailer;
  final Color nodeWarehouse;

  final Color bizInspecting;
  final Color bizTransforming;

  final Color journeyStart;
  final Color journeyLatest;

  final Color info;
  final Color infoSoft;
  final List<Color> chartSeries;

  /// Alias for [statusSuccess]; use in generic success/warning/error contexts.
  Color get success => statusSuccess;

  /// Alias for [statusPartialSuccess]; use in generic success/warning/error contexts.
  Color get warning => statusPartialSuccess;

  /// Alias for [statusFailed]; use in generic success/warning/error contexts.
  Color get error => statusFailed;

  static OperationPalette of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }

  static Color onColor(Color color) =>
      color.computeLuminance() > 0.55 ? const Color(0xFF111318) : Colors.white;

  static Color soft(Color color, [double opacity = 0.14]) =>
      color.withValues(alpha: opacity);

  Color forOperationType(OperationType type) => switch (type) {
        OperationType.commissioning => opCommissioning,
        OperationType.packing => opPacking,
        OperationType.unpacking => opUnpacking,
        OperationType.shipping => opShipping,
        OperationType.receiving => opReceiving,
        OperationType.returnShipping => opReturnShipping,
        OperationType.returnReceiving => opReturnReceiving,
        OperationType.cancelShipping => opCancelShipping,
        OperationType.cancelReceiving => opCancelReceiving,
        OperationType.updateStatus => opUpdateStatus,
      };

  Color forOperationStatus(OperationStatus status) => switch (status) {
        OperationStatus.success => statusSuccess,
        OperationStatus.partialSuccess => statusPartialSuccess,
        OperationStatus.failed => statusFailed,
        OperationStatus.validationError => statusValidationError,
        OperationStatus.accepted => statusAccepted,
      };

  Color forCommissioningBatchStatus(CommissioningBatchStatus status) =>
      switch (status) {
        CommissioningBatchStatus.success => statusSuccess,
        CommissioningBatchStatus.partialSuccess => statusPartialSuccess,
        CommissioningBatchStatus.failed => statusFailed,
        CommissioningBatchStatus.pending => batchPending,
        CommissioningBatchStatus.inProgress => batchInProgress,
      };

  Color forItemStatus(ItemStatus status) => switch (status) {
        ItemStatus.RESERVED => itemReserved,
        ItemStatus.ALLOCATED => itemAllocated,
        ItemStatus.COMMISSIONED => itemCommissioned,
        ItemStatus.ACTIVE => itemActive,
        ItemStatus.IN_TRANSIT => itemInTransit,
        ItemStatus.RECEIVED => itemReceived,
        ItemStatus.DISPENSED => itemDispensed,
        ItemStatus.RETURNED => itemReturned,
        ItemStatus.DESTROYED => itemDestroyed,
        ItemStatus.RECALLED => itemRecalled,
        ItemStatus.STOLEN => itemStolen,
        ItemStatus.EXPIRED => itemExpired,
        ItemStatus.EXCEPTION => itemException,
      };

  Color forLogisticUnitStatus(LogisticUnitStatus status) => switch (status) {
        LogisticUnitStatus.DRAFT => ssccDraft,
        LogisticUnitStatus.ALLOCATED => ssccAllocated,
        LogisticUnitStatus.ACTIVE => ssccActive,
        LogisticUnitStatus.IN_TRANSIT => ssccInTransit,
        LogisticUnitStatus.RECEIVED => ssccReceived,
        LogisticUnitStatus.DECOMMISSIONED => ssccDecommissioned,
        LogisticUnitStatus.VOIDED => ssccVoided,
      };

  Color forEpcType(OperationScanItemType type) => switch (type) {
        OperationScanItemType.sgtin => epcSgtin,
        OperationScanItemType.sscc => epcSscc,
        OperationScanItemType.gtin => epcGtin,
        OperationScanItemType.invalid => epcInvalid,
        OperationScanItemType.unknown => epcInvalid,
      };

  /// Light palette — slightly muted for white/light surfaces.
  static const light = OperationPalette(
    opCommissioning: Color(0xFF2563EB),
    opPacking: Color(0xFF4F8B3E),
    opUnpacking: Color(0xFFD97706),
    opShipping: Color(0xFF4338CA),
    opReceiving: Color(0xFF0F766E),
    opReturnShipping: Color(0xFFB45309),
    opReturnReceiving: Color(0xFF92400E),
    opCancelShipping: Color(0xFFB6362B),
    opCancelReceiving: Color(0xFF8B2A22),
    opUpdateStatus: Color(0xFF6A4FA0),
    statusSuccess: Color(0xFF4F8B3E),
    statusPartialSuccess: Color(0xFFB07A1C),
    statusFailed: Color(0xFFB6362B),
    statusValidationError: Color(0xFF8B2A22),
    statusAccepted: Color(0xFF0F766E),
    batchPending: Color(0xFF2563EB),
    batchInProgress: Color(0xFF0F766E),
    itemReserved: Color(0xFF9CA3AF),
    itemAllocated: Color(0xFF60A5FA),
    itemCommissioned: Color(0xFF2563EB),
    itemActive: Color(0xFF4F8B3E),
    itemInTransit: Color(0xFFD97706),
    itemReceived: Color(0xFF0F766E),
    itemDispensed: Color(0xFF6A4FA0),
    itemReturned: Color(0xFFB45309),
    itemDestroyed: Color(0xFF7F1D1D),
    itemRecalled: Color(0xFFC2410C),
    itemStolen: Color(0xFF7F1D1D),
    itemExpired: Color(0xFF78716C),
    itemException: Color(0xFFB6362B),
    ssccDraft: Color(0xFF64748B),
    ssccAllocated: Color(0xFF3B82F6),
    ssccActive: Color(0xFF4F8B3E),
    ssccInTransit: Color(0xFFD97706),
    ssccReceived: Color(0xFF0F766E),
    ssccDecommissioned: Color(0xFF78716C),
    ssccVoided: Color(0xFF7F1D1D),
    epcSgtin: Color(0xFF2563EB),
    epcSscc: Color(0xFF0F766E),
    epcGtin: Color(0xFFD97706),
    epcInvalid: Color(0xFF9CA3AF),
    eventObject: Color(0xFF2563EB),
    eventAggregation: Color(0xFF4F8B3E),
    eventTransactionAdmin: Color(0xFFB6362B),
    eventTransactionEpcis: Color(0xFFD97706),
    eventTransformation: Color(0xFF6A4FA0),
    eventUnknown: Color(0xFF9CA3AF),
    severityCritical: Color(0xFF7F1D1D),
    severityHigh: Color(0xFFB6362B),
    severityMedium: Color(0xFFD97706),
    severityLow: Color(0xFF2563EB),
    neutral: Color(0xFF9CA3AF),
    supplyActive: Color(0xFF4F8B3E),
    supplyInactive: Color(0xFFB6362B),
    supplyPending: Color(0xFFD97706),
    nodeManufacturer: Color(0xFF2563EB),
    nodeDistributor: Color(0xFF4F8B3E),
    nodeRetailer: Color(0xFFD97706),
    nodeWarehouse: Color(0xFF6A4FA0),
    bizInspecting: Color(0xFF0891B2),
    bizTransforming: Color(0xFF0F766E),
    journeyStart: Color(0xFF4F8B3E),
    journeyLatest: Color(0xFF3071A8),
    info: Color(0xFF2563EB),
    infoSoft: Color(0xFFDBEAFE),
    chartSeries: [
      Color(0xFF2563EB),
      Color(0xFF4F8B3E),
      Color(0xFFB6362B),
      Color(0xFF6A4FA0),
      Color(0xFFD97706),
      Color(0xFF0F766E),
      Color(0xFF6A4FA0),
      Color(0xFF4338CA),
    ],
  );

  /// Dark palette — brighter accents for dark surfaces.
  static const dark = OperationPalette(
    opCommissioning: Color(0xFF60A5FA),
    opPacking: Color(0xFF7BD389),
    opUnpacking: Color(0xFFFBBF24),
    opShipping: Color(0xFF818CF8),
    opReceiving: Color(0xFF5BC2B5),
    opReturnShipping: Color(0xFFE6B454),
    opReturnReceiving: Color(0xFFC9973A),
    opCancelShipping: Color(0xFFE85C4A),
    opCancelReceiving: Color(0xFFC94A3B),
    opUpdateStatus: Color(0xFFA89DDC),
    statusSuccess: Color(0xFF7BD389),
    statusPartialSuccess: Color(0xFFE6B454),
    statusFailed: Color(0xFFE85C4A),
    statusValidationError: Color(0xFFC94A3B),
    statusAccepted: Color(0xFF5BC2B5),
    batchPending: Color(0xFF60A5FA),
    batchInProgress: Color(0xFF5BC2B5),
    itemReserved: Color(0xFF9CA3AF),
    itemAllocated: Color(0xFF93C5FD),
    itemCommissioned: Color(0xFF60A5FA),
    itemActive: Color(0xFF7BD389),
    itemInTransit: Color(0xFFFBBF24),
    itemReceived: Color(0xFF5BC2B5),
    itemDispensed: Color(0xFFA89DDC),
    itemReturned: Color(0xFFE6B454),
    itemDestroyed: Color(0xFFF87171),
    itemRecalled: Color(0xFFFB923C),
    itemStolen: Color(0xFFEF4444),
    itemExpired: Color(0xFFA8A29E),
    itemException: Color(0xFFE85C4A),
    ssccDraft: Color(0xFF94A3B8),
    ssccAllocated: Color(0xFF60A5FA),
    ssccActive: Color(0xFF7BD389),
    ssccInTransit: Color(0xFFFBBF24),
    ssccReceived: Color(0xFF5BC2B5),
    ssccDecommissioned: Color(0xFFA8A29E),
    ssccVoided: Color(0xFFF87171),
    epcSgtin: Color(0xFF60A5FA),
    epcSscc: Color(0xFF5BC2B5),
    epcGtin: Color(0xFFFBBF24),
    epcInvalid: Color(0xFF9CA3AF),
    eventObject: Color(0xFF60A5FA),
    eventAggregation: Color(0xFF7BD389),
    eventTransactionAdmin: Color(0xFFE85C4A),
    eventTransactionEpcis: Color(0xFFFBBF24),
    eventTransformation: Color(0xFFA89DDC),
    eventUnknown: Color(0xFF9CA3AF),
    severityCritical: Color(0xFFEF4444),
    severityHigh: Color(0xFFE85C4A),
    severityMedium: Color(0xFFE6B454),
    severityLow: Color(0xFF60A5FA),
    neutral: Color(0xFF9CA3AF),
    supplyActive: Color(0xFF7BD389),
    supplyInactive: Color(0xFFE85C4A),
    supplyPending: Color(0xFFE6B454),
    nodeManufacturer: Color(0xFF60A5FA),
    nodeDistributor: Color(0xFF7BD389),
    nodeRetailer: Color(0xFFFBBF24),
    nodeWarehouse: Color(0xFFA89DDC),
    bizInspecting: Color(0xFF22D3EE),
    bizTransforming: Color(0xFF5BC2B5),
    journeyStart: Color(0xFF7BD389),
    journeyLatest: Color(0xFF6FB7DC),
    info: Color(0xFF60A5FA),
    infoSoft: Color(0xFF1E3A5F),
    chartSeries: [
      Color(0xFF60A5FA),
      Color(0xFF7BD389),
      Color(0xFFE85C4A),
      Color(0xFFA89DDC),
      Color(0xFFE6B454),
      Color(0xFF5BC2B5),
      Color(0xFFA89DDC),
      Color(0xFF818CF8),
    ],
  );
}
