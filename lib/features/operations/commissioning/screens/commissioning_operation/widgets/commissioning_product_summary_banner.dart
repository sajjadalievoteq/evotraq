import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CommissioningProductSummaryBanner extends StatelessWidget {
  const CommissioningProductSummaryBanner({
    super.key,
    required this.identifiedType,
    required this.primaryParsed,
    required this.batchLotController,
  });

  final EPCType? identifiedType;
  final EPCParseResult? primaryParsed;
  final TextEditingController batchLotController;

  @override
  Widget build(BuildContext context) {
    final typeLabel = identifiedType?.name.toUpperCase() ?? 'EPC';
    final detail = switch (identifiedType) {
      EPCType.sgtin =>
        'GTIN: ${primaryParsed?.gtin ?? '—'} · Batch: ${batchLotController.text}',
      EPCType.sscc => 'SSCC: ${primaryParsed?.sscc ?? '—'}',
      _ => primaryParsed?.epc ?? 'Identify an EPC in step 1',
    };

    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            TraqIcon(AppAssets.iconPackage, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeLabel,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    detail,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
