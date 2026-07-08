import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_input_parser.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

class GtinSupplyChainCard extends StatelessWidget {
  const GtinSupplyChainCard({super.key, required this.gtin});

  final GTIN gtin;

  @override
  Widget build(BuildContext context) {
    final locationLabel = gtin.currentLocation?.locationName ??
        gtin.currentLocationName ??
        gtin.currentLocationGln ??
        gtin.currentLocation?.glnCode ??
        'Unknown';
    final packedIn = gtin.currentPackedInEpc?.trim();
    final hasPackedIn = packedIn != null && packedIn.isNotEmpty;

    return Gs1GroupCard(
      title: 'Supply Chain Context',
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row('Current Location', locationLabel),
          if (gtin.currentLocation?.glnCode != null &&
              gtin.currentLocation!.locationName != locationLabel)
            _row('Location GLN', gtin.currentLocation!.glnCode),
          if (hasPackedIn)
            _packedIntoRow(context, packedIn),
        ],
      ),
    );
  }

  Widget _packedIntoRow(BuildContext context, String epc) {
    final route = _detailRouteForEpc(epc);
    final value = InkWell(
      onTap: route != null ? () => context.go(route) : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                epc,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: route != null
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  decoration:
                      route != null ? TextDecoration.underline : null,
                ),
              ),
            ),
            if (route != null)
              TraqIcon(AppAssets.iconOpenNew, color: Theme.of(context).colorScheme.primary, size: 16),
          ],
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text('Packed Into', style: TextStyle(color: Colors.grey[700])),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  static String? _detailRouteForEpc(String epc) {
    final type = OperationEpcScanValidator.resolveEpcType(epc);
    if (type == OperationScanItemType.sscc) {
      final code = epc.toLowerCase().startsWith('urn:epc:id:sscc:')
          ? SsccInputParser.parseToSsccCode(epc)
          : null;
      if (code != null && code.isNotEmpty) {
        return '${Constants.gs1SsccsRoute}/$code';
      }
    }
    if (type == OperationScanItemType.sgtin) {
      final serial = Gs1Converter.epcToSerial(epc);
      if (serial != null && serial.isNotEmpty) {
        return '${Constants.gs1SgtinsRoute}/$serial';
      }
    }
    return null;
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: label == 'Current Location' ? null : 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
