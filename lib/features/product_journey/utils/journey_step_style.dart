import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';

abstract final class JourneyStepStyle {

  static Color colorFor(BuildContext context, String businessStep) {
    final c = context.colors;
    return c.primary;
  }

  /// CBV biz-step token (e.g. `decommissioning`), not substring matching.
  /// `decommissioning` must not match `commissioning`.
  static String? bizStepToken(String businessStep) =>
      CbvDisplayUtils.shortName(businessStep)?.toLowerCase();

  static String titleFor(String businessStep) {
    final token = bizStepToken(businessStep);
    if (token != null) {
      return switch (token) {
        'commissioning' => 'Commissioning',
        'decommissioning' => 'Decommissioning',
        'unpacking' => 'Unpacking',
        'packing' => 'Packing',
        'shipping' => 'Shipping',
        'receiving' => 'Receiving',
        'accepting' => 'Accepting',
        'returning' => 'Returning',
        'loading' => 'Loading',
        'unloading' => 'Unloading',
        'dispatching' => 'Dispatching',
        'transporting' => 'Transporting',
        'holding' => 'Holding',
        'encoding' => 'Encoding',
        'update_status' => 'Status Update',
        'destroying' => 'Destroying',
        'inspecting' => 'Inspecting',
        'storing' => 'Storing',
        'picking' => 'Picking',
        'cancel' => 'Cancelled',
        _ => CbvDisplayUtils.displayBizStep(businessStep),
      };
    }

    final s = businessStep.toLowerCase();
    if (s.contains('unpacking')) return 'Unpacking';
    if (s.contains('packing')) return 'Packing';
    return CbvDisplayUtils.displayBizStep(businessStep);
  }

  static String iconFor(String businessStep) {
    final token = bizStepToken(businessStep);
    if (token != null) {
      return switch (token) {
        'commissioning' => AppAssets.iconPrecisionManufacturing,
        'decommissioning' => AppAssets.iconDecommissioning,
        'unpacking' => AppAssets.iconUnpacking,
        'packing' => AppAssets.iconPackingSealed,
        'shipping' => AppAssets.iconShipment,
        'receiving' => AppAssets.iconReceivingInbound,
        'accepting' => AppAssets.iconAccepting,
        'returning' => AppAssets.iconReturning,
        'loading' => AppAssets.iconLoadingCargo,
        'unloading' => AppAssets.iconUnloadingCargo,
        'dispatching' => AppAssets.iconDispatching,
        'transporting' => AppAssets.iconTruck,
        'holding' => AppAssets.iconHolding,
        'encoding' => AppAssets.iconQr,
        'update_status' => AppAssets.iconRefresh,
        'destroying' => AppAssets.iconFlame,
        'inspecting' => AppAssets.iconInspecting,
        'storing' => AppAssets.iconWarehouse,
        'picking' => AppAssets.iconCart,
        'cancel' => AppAssets.iconXCircle,
        _ => AppAssets.iconEvent,
      };
    }

    final s = businessStep.toLowerCase();
    if (s.contains('unpacking')) return AppAssets.iconUnpacking;
    if (s.contains('packing')) return AppAssets.iconPackingSealed;
    return AppAssets.iconEvent;
  }


  static Color typeColor(BuildContext context, String type) {
    final c = context.colors;
    return switch (type.toUpperCase()) {
      'SGTIN' => c.identifierSgtin,
      'SSCC'  => c.identifierSscc,
      'GTIN'  => c.identifierGtin,
      _       => c.textMuted,
    };
  }
}
