import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey_details/widgets/journey_product_summary_row.dart';

class JourneyProductDetailRows extends StatelessWidget {
  const JourneyProductDetailRows({
    super.key,
    required this.info,
    required this.journey,
    required this.isSscc,
  });
  final ProductInfo? info;
  final ProductJourney journey;
  final bool isSscc;

  @override
  Widget build(BuildContext context) {
    if (!isSscc) {
      return Column(
        children: [
          JourneyProductSummaryRow(label: 'GTIN', value: info?.gtin),
          JourneyProductSummaryRow(
            label: 'Serial Number',
            value: info?.serialNumber,
          ),
          JourneyProductSummaryRow(
            label: 'Batch / Lot',
            value: info?.batchLotNumber,
          ),
          JourneyProductSummaryRow(
            label: 'Expiry Date',
            value: info?.expiryDate == null
                ? null
                : DateFormat('MMM dd, yyyy').format(info!.expiryDate!),
          ),
          if (info?.gtin == null && info?.serialNumber == null)
            JourneyProductSummaryRow(
              label: 'Identifier',
              value: journey.identifier,
            ),
        ],
      );
    }
    final childCount =
        info?.itemCount ??
        ((info?.childSgtins?.length ?? 0) + (info?.childSsccs?.length ?? 0));
    return Column(
      children: [
        JourneyProductSummaryRow(label: 'SSCC', value: info?.sscc),
        JourneyProductSummaryRow(
          label: 'Packaging Level',
          value: info?.packagingLevel ?? info?.unitType ?? info?.containerType,
        ),
        JourneyProductSummaryRow(
          label: 'Parent Container',
          value: info?.parentSSCC,
        ),
        JourneyProductSummaryRow(
          label: 'Child Count',
          value: childCount > 0 ? childCount.toString() : null,
        ),
      ],
    );
  }
}
