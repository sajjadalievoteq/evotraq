import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_input_parser.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

class GtinPackedIntoRow extends StatelessWidget {
  const GtinPackedIntoRow({required this.epc, super.key});

  final String epc;

  @override
  Widget build(BuildContext context) {
    final route = _detailRouteForEpc(epc);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              'Packed Into',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: route != null ? () => context.push(route) : null,
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
                          decoration: route != null
                              ? TextDecoration.underline
                              : null,
                        ),
                      ),
                    ),
                    if (route != null)
                      TraqIcon(
                        AppAssets.iconOpenNew,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String? _detailRouteForEpc(String epc) {
    final type = OperationEpcScanValidator.resolveEpcType(epc);
    if (type == OperationScanItemType.sscc) {
      final code = SsccInputParser.parseToSsccCode(epc);
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
}
