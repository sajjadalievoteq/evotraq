import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class CommissioningProductSummaryBanner extends StatelessWidget {
  const CommissioningProductSummaryBanner({
    super.key,
    required this.selectedGTIN,
    required this.gtinController,
    required this.batchLotController,
  });

  final GTIN? selectedGTIN;
  final TextEditingController gtinController;
  final TextEditingController batchLotController;

  @override
  Widget build(BuildContext context) {
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
                    'GTIN: ${selectedGTIN?.gtinCode ?? gtinController.text}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Batch: ${batchLotController.text}',
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
