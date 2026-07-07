import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

abstract final class JourneyStepStyle {
  // ── Colours ────────────────────────────────────────────────────────────────

  static Color colorFor(BuildContext context, String businessStep) {
    final c = context.colors;
    // if (s.contains('commissioning'))    return c.primary;
    // // unpacking MUST come before packing ('packing' ⊂ 'unpacking')
    // if (s.contains('unpacking'))         return c.primary; // amber – opening
    // if (s.contains('packing'))           return c.primary; // purple – sealing
    // if (s.contains('shipping'))          return c.primary; // teal – out
    // if (s.contains('receiving'))        return c.primary; // green – arrival
    // if (s.contains('accepting'))         return c.primary;// green – formal acceptance
    // if (s.contains('returning'))        return c.primary; // deep-orange – return
    // if (s.contains('loading'))          return c.primary; // cyan – loading
    // if (s.contains('unloading'))         return c.primary;// blue – unloading
    // if (s.contains('dispatching'))     return c.primary; // teal – dispatch
    // if (s.contains('transporting'))   return c.primary; // teal – in-transit
    // if (s.contains('holding'))           return c.primary;// grey – on-hold
    // if (s.contains('encoding'))          return c.primary;// blue – data
    // if (s.contains('decommissioning'))   return c.primary; // grey-blue
    // if (s.contains('update_status'))    return c.primary; // light-blue
    // if (s.contains('destroying'))       return c.primary;
    // if (s.contains('inspecting'))       return c.primary; // cyan – checking
    // if (s.contains('storing'))          return c.primary; // brown – storage
    // if (s.contains('picking'))          return c.primary; // indigo – selection
    // if (s.contains('cancel'))           return c.primary; // pink – cancelled
    return c.primary;
  }

  // ── Human-readable title ───────────────────────────────────────────────────

  static String titleFor(String businessStep) {
    final s = businessStep.toLowerCase();
    if (s.contains('commissioning'))    return 'Commissioning';
    if (s.contains('unpacking'))        return 'Unpacking';
    if (s.contains('packing'))          return 'Packing';
    if (s.contains('shipping'))         return 'Shipping';
    if (s.contains('receiving'))        return 'Receiving';
    if (s.contains('accepting'))        return 'Accepting';
    if (s.contains('returning'))        return 'Returning';
    if (s.contains('loading'))          return 'Loading';
    if (s.contains('unloading'))        return 'Unloading';
    if (s.contains('dispatching'))      return 'Dispatching';
    if (s.contains('transporting'))     return 'Transporting';
    if (s.contains('holding'))          return 'Holding';
    if (s.contains('encoding'))         return 'Encoding';
    if (s.contains('decommissioning'))  return 'Decommissioning';
    if (s.contains('update_status'))    return 'Status Update';
    if (s.contains('destroying'))       return 'Destroying';
    if (s.contains('inspecting'))       return 'Inspecting';
    if (s.contains('storing'))          return 'Storing';
    if (s.contains('picking'))          return 'Picking';
    if (s.contains('cancel'))           return 'Cancelled';

    // ── Fallback: extract the human name from any GS1 URI format ─────────────
    // Handles both colon-style  urn:epcglobal:cbv:bizstep:accepting
    // and URL-style             http://ns.gs1.org/cbv/BizStep-accepting
    String raw = businessStep;
    // URL format: extract after the last '/'
    if (raw.contains('/')) raw = raw.split('/').last;
    // BizStep-foo or bizstep-foo
    if (raw.toLowerCase().startsWith('bizstep-')) {
      raw = raw.substring('bizstep-'.length);
    }
    // Colon URN format: take the last segment
    if (raw.contains(':')) raw = raw.split(':').last;
    // Humanise: replace _ and - with spaces, title-case each word
    return raw
        .split(RegExp(r'[_\-]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // ── Icons — semantically matched to each operation ─────────────────────────

  static String iconFor(String businessStep) {
    final s = businessStep.toLowerCase();
    if (s.contains('commissioning'))    return AppAssets.iconPrecisionManufacturing;
    if (s.contains('unpacking'))        return AppAssets.iconUnpacking;
    if (s.contains('packing'))          return AppAssets.iconPackingSealed;
    if (s.contains('shipping'))         return AppAssets.iconShipment;
    if (s.contains('receiving'))        return AppAssets.iconReceivingInbound;
    if (s.contains('accepting'))        return AppAssets.iconAccepting;
    if (s.contains('returning'))        return AppAssets.iconReturning;
    if (s.contains('loading'))          return AppAssets.iconLoadingCargo;
    if (s.contains('unloading'))        return AppAssets.iconUnloadingCargo;
    if (s.contains('dispatching'))      return AppAssets.iconDispatching;
    if (s.contains('transporting'))     return AppAssets.iconTruck;
    if (s.contains('holding'))          return AppAssets.iconHolding;
    if (s.contains('encoding'))         return AppAssets.iconQr;
    if (s.contains('decommissioning'))  return AppAssets.iconDecommissioning;
    if (s.contains('update_status'))    return AppAssets.iconRefresh;
    if (s.contains('destroying'))       return AppAssets.iconFlame;
    if (s.contains('inspecting'))       return AppAssets.iconInspecting;
    if (s.contains('storing'))          return AppAssets.iconWarehouse;
    if (s.contains('picking'))          return AppAssets.iconCart;
    if (s.contains('cancel'))           return AppAssets.iconXCircle;
    return AppAssets.iconEvent;
  }

  // ── Type colour for SGTIN / SSCC / GTIN chips ─────────────────────────────

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
