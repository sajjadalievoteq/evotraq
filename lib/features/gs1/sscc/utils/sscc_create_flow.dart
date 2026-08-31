import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_route_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_commissioning_prefill.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_create_mode.dart';

abstract final class SsccCreateFlow {
  static String commissioningRoute({SsccCommissioningPrefill? prefill}) {
    if (prefill == null) {
      return '${Constants.opCommissioningNewRoute}?identifierType=sscc';
    }
    final params = prefill.toQueryParameters();
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '${Constants.opCommissioningNewRoute}?$query';
  }

  static String newSsccRoute({required bool commissionAfterCreate}) {
    final params = <String, String>{'skipCreatePrompt': '1'};
    if (commissionAfterCreate) {
      params['commissionAfterCreate'] = '1';
    }
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '${SsccRouteConstants.newSscc}?$query';
  }

  static Future<void> promptAndNavigate(BuildContext context) async {
    final mode = await showSsccCreateModeDialog(context);
    if (!context.mounted || mode == null) return;

    switch (mode) {
      case SsccCreateMode.createOnly:
        context.push(newSsccRoute(commissionAfterCreate: false));
      case SsccCreateMode.createAndCommission:
        context.push(newSsccRoute(commissionAfterCreate: true));
    }
  }

  static Future<void> promptAndRun({
    required BuildContext context,
    required void Function({required bool commissionAfterCreate})
    openEmbeddedCreate,
  }) async {
    final mode = await showSsccCreateModeDialog(context);
    if (!context.mounted || mode == null) return;

    switch (mode) {
      case SsccCreateMode.createOnly:
        openEmbeddedCreate(commissionAfterCreate: false);
      case SsccCreateMode.createAndCommission:
        openEmbeddedCreate(commissionAfterCreate: true);
    }
  }
}
