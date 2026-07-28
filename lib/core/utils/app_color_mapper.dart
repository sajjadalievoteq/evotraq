import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

enum AppEventColorScheme { admin, epcis }

/// Generic semantic buckets, independent of any specific domain model.
enum AppSemanticState { success, warning, error, info, neutral }

/// Single source of truth for operation / status / EPC / event colors and icons.
/// All colors come from [OperationPalette] (light + dark).
abstract final class AppColorMapper {
  static OperationPalette palette(BuildContext context) =>
      OperationPalette.of(context);

  // ── Semantic state ─────────────────────────────────────────────────────────

  static Color stateColor(BuildContext context, AppSemanticState state) {
    final p = palette(context);
    return switch (state) {
      AppSemanticState.success => p.success,
      AppSemanticState.warning => p.warning,
      AppSemanticState.error => p.error,
      AppSemanticState.info => p.info,
      AppSemanticState.neutral => p.neutral,
    };
  }

  static Color infoColor(BuildContext context) => palette(context).info;

  static Color infoSoft(BuildContext context) => palette(context).infoSoft;

  static Color successColor(BuildContext context) => palette(context).success;

  static Color warningColor(BuildContext context) => palette(context).warning;

  static Color errorColor(BuildContext context) => palette(context).error;

  static Color neutralColor(BuildContext context) => palette(context).neutral;

  static Color chartColor(BuildContext context, int index) {
    final series = palette(context).chartSeries;
    return series[index.abs() % series.length];
  }

  // ── OperationType ──────────────────────────────────────────────────────────

  static Color operationTypeColor(BuildContext context, OperationType type) =>
      palette(context).forOperationType(type);

  static Color operationTypeOnColor(BuildContext context, OperationType type) =>
      OperationPalette.onColor(operationTypeColor(context, type));

  static Color operationTypeSoft(BuildContext context, OperationType type) =>
      OperationPalette.soft(operationTypeColor(context, type));

  static String operationTypeIcon(OperationType type) => switch (type) {
        OperationType.commissioning => NavIcons.commissioning,
        OperationType.packing => NavIcons.packing,
        OperationType.unpacking => NavIcons.unpacking,
        OperationType.shipping => NavIcons.shipping,
        OperationType.receiving => NavIcons.receiving,
        OperationType.returnShipping => NavIcons.returnShipping,
        OperationType.returnReceiving => NavIcons.returnReceiving,
        OperationType.cancelShipping => NavIcons.cancelShipping,
        OperationType.cancelReceiving => NavIcons.cancelReceiving,
        OperationType.updateStatus => NavIcons.updateStatus,
      };

  /// Maps a CBV / biz-step token (or raw URI fragment) to the operation palette.
  static Color bizStepColor(BuildContext context, String businessStep) {
    final p = palette(context);
    final s = businessStep.toLowerCase();
    if (s.contains('unpacking')) return p.opUnpacking;
    if (s.contains('packing') && !s.contains('unpacking')) return p.opPacking;
    if (s.contains('commission') && !s.contains('decommission')) {
      return p.opCommissioning;
    }
    if (s.contains('decommission') || s.contains('destroy')) {
      return p.statusFailed;
    }
    if (s.contains('return') && s.contains('receiv')) return p.opReturnReceiving;
    if (s.contains('return')) return p.opReturnShipping;
    if (s.contains('cancel') && s.contains('receiv')) return p.opCancelReceiving;
    if (s.contains('cancel')) return p.opCancelShipping;
    if (s.contains('receiv') || s.contains('accept') || s.contains('unload')) {
      return p.opReceiving;
    }
    if (s.contains('ship') ||
        s.contains('dispatch') ||
        s.contains('transport') ||
        s.contains('loading')) {
      return p.opShipping;
    }
    if (s.contains('update_status') || s.contains('update-status')) {
      return p.opUpdateStatus;
    }
    if (s.contains('inspect')) return p.bizInspecting;
    if (s.contains('transform')) return p.bizTransforming;
    if (s.contains('encod')) return p.opCommissioning;
    return p.neutral;
  }

  // ── OperationStatus ────────────────────────────────────────────────────────

  static Color operationStatusColor(
    BuildContext context,
    OperationStatus status,
  ) =>
      palette(context).forOperationStatus(status);

  static String operationStatusIcon(OperationStatus status) => switch (status) {
        OperationStatus.success => AppAssets.iconCheckCircle,
        OperationStatus.partialSuccess => AppAssets.iconAlert,
        OperationStatus.failed => AppAssets.iconXCircle,
        OperationStatus.validationError => AppAssets.iconXCircle,
        OperationStatus.accepted => AppAssets.iconBox,
      };

  // ── Commissioning batch ────────────────────────────────────────────────────

  static Color commissioningBatchStatusColor(
    BuildContext context,
    CommissioningBatchStatus status,
  ) =>
      palette(context).forCommissioningBatchStatus(status);

  // ── ItemStatus (SGTIN lifecycle) ───────────────────────────────────────────

  static Color itemStatusColor(BuildContext context, ItemStatus status) =>
      palette(context).forItemStatus(status);

  static String itemStatusIcon(ItemStatus status) => switch (status) {
        ItemStatus.RESERVED => AppAssets.iconClock,
        ItemStatus.ALLOCATED => AppAssets.iconTag,
        ItemStatus.COMMISSIONED => NavIcons.commissioning,
        ItemStatus.ACTIVE => AppAssets.iconCheckCircle,
        ItemStatus.IN_TRANSIT => NavIcons.shipping,
        ItemStatus.RECEIVED => NavIcons.receiving,
        ItemStatus.DISPENSED => AppAssets.iconBox,
        ItemStatus.RETURNED => NavIcons.returnReceiving,
        ItemStatus.DESTROYED => AppAssets.iconFlame,
        ItemStatus.RECALLED => AppAssets.iconAlert,
        ItemStatus.STOLEN => AppAssets.iconSecurity,
        ItemStatus.EXPIRED => AppAssets.iconClock,
        ItemStatus.EXCEPTION => AppAssets.iconXCircle,
      };

  // ── LogisticUnitStatus (SSCC) ──────────────────────────────────────────────

  static Color logisticUnitStatusColor(
    BuildContext context,
    LogisticUnitStatus status,
  ) =>
      palette(context).forLogisticUnitStatus(status);

  // ── EPC scan type ──────────────────────────────────────────────────────────

  static Color operationEpcTypeColor(
    BuildContext context,
    OperationScanItemType type,
  ) =>
      palette(context).forEpcType(type);

  // ── Event type ─────────────────────────────────────────────────────────────

  static Color eventTypeColor(
    BuildContext context,
    String eventType, {
    required AppEventColorScheme scheme,
  }) {
    final p = palette(context);
    return _eventTypeFromPalette(p, eventType, scheme);
  }

  /// Resolves a palette from either [context] or [brightness]; one of the two
  /// is required. Prefer [context] when available (e.g. inside `build`);
  /// use [brightness] in painters / non-widget code that already knows it.
  static Color eventType(
    String eventType, {
    required AppEventColorScheme scheme,
    BuildContext? context,
    Brightness? brightness,
  }) {
    if (context == null && brightness == null) {
      throw StateError(
        'AppColorMapper.eventType requires either context or brightness.',
      );
    }
    final p = context != null
        ? palette(context)
        : (brightness == Brightness.dark
            ? OperationPalette.dark
            : OperationPalette.light);
    return _eventTypeFromPalette(p, eventType, scheme);
  }

  static Color _eventTypeFromPalette(
    OperationPalette p,
    String eventType,
    AppEventColorScheme scheme,
  ) {
    final normalized = eventType.toLowerCase();
    final isObject = normalized == 'object' ||
        normalized == 'objectevent' ||
        normalized == 'object_event';
    final isAggregation = normalized == 'aggregation' ||
        normalized == 'aggregationevent' ||
        normalized == 'aggregation_event';
    final isTransaction = normalized == 'transaction' ||
        normalized == 'transactionevent' ||
        normalized == 'transaction_event';
    final isTransformation = normalized == 'transformation' ||
        normalized == 'transformationevent' ||
        normalized == 'transformation_event';

    if (isObject) return p.eventObject;
    if (isAggregation) return p.eventAggregation;
    if (isTransaction) {
      return scheme == AppEventColorScheme.admin
          ? p.eventTransactionAdmin
          : p.eventTransactionEpcis;
    }
    if (isTransformation) return p.eventTransformation;
    return p.eventUnknown;
  }

  // ── Severity / gauges ──────────────────────────────────────────────────────

  static Color severity(BuildContext context, String severity) {
    final p = palette(context);
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return p.severityCritical;
      case 'HIGH':
        return p.severityHigh;
      case 'MEDIUM':
        return p.severityMedium;
      case 'LOW':
        return p.severityLow;
      default:
        return p.neutral;
    }
  }

  static Color dashboardSeverity(BuildContext context, String severity) {
    final p = palette(context);
    switch (severity.toUpperCase()) {
      case 'LOW':
        return p.statusSuccess;
      case 'MEDIUM':
        return p.statusPartialSuccess;
      case 'HIGH':
      case 'CRITICAL':
        return p.statusFailed;
      default:
        return p.neutral;
    }
  }

  static Color score(BuildContext context, double score) {
    final p = palette(context);
    if (score >= 90) return p.statusSuccess;
    if (score >= 70) return p.statusPartialSuccess;
    return p.statusFailed;
  }

  static Color successRate(BuildContext context, double successRate) {
    final p = palette(context);
    if (successRate >= 95) return p.statusSuccess;
    if (successRate >= 90) return p.statusPartialSuccess;
    return p.statusFailed;
  }

  static Color usage(BuildContext context, double usage) {
    final p = palette(context);
    if (usage < 50) return p.statusSuccess;
    if (usage < 80) return p.statusPartialSuccess;
    return p.statusFailed;
  }

  static Color performance(
    BuildContext context,
    double value,
    double good,
    double warning, {
    bool inverted = false,
  }) {
    final p = palette(context);
    if (inverted) {
      if (value <= good) return p.statusSuccess;
      if (value <= warning) return p.statusPartialSuccess;
      return p.statusFailed;
    }
    if (value >= good) return p.statusSuccess;
    if (value >= warning) return p.statusPartialSuccess;
    return p.statusFailed;
  }

  static Color supplyChainStatus(BuildContext context, String status) {
    final p = palette(context);
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return p.supplyActive;
      case 'INACTIVE':
        return p.supplyInactive;
      case 'PENDING':
        return p.supplyPending;
      default:
        return p.neutral;
    }
  }

  static Color supplyChainNodeColor(BuildContext context, String? type) {
    final p = palette(context);
    switch (type) {
      case 'manufacturer':
        return p.nodeManufacturer;
      case 'distributor':
        return p.nodeDistributor;
      case 'retailer':
        return p.nodeRetailer;
      case 'warehouse':
        return p.nodeWarehouse;
      default:
        return p.neutral;
    }
  }

  static Color journeyStartColor(BuildContext context) =>
      palette(context).journeyStart;

  static Color journeyLatestColor(BuildContext context) =>
      palette(context).journeyLatest;
}
