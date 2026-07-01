import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

/// Step 3: review all shipping details before submission.
class ReturnShippingReviewStep extends StatelessWidget {
  const ReturnShippingReviewStep({
    super.key,
    required this.sourceGln,
    required this.destinationGln,
    required this.returnAuthorizationNumber,
    required this.purchaseOrder,
    required this.despatchAdvice,
    required this.billOfLading,
    required this.carrier,
    required this.trackingNumber,
    required this.eventTime,
    required this.scannedEpcs,
    this.showPageHeader = true,
  });
  final GLN? sourceGln;
  final GLN? destinationGln;
  final String returnAuthorizationNumber;
  final String purchaseOrder;
  final String despatchAdvice;
  final String billOfLading;
  final String carrier;
  final String trackingNumber;
  final DateTime? eventTime;
  final List<String> scannedEpcs;
  final bool showPageHeader;
  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: ResponsiveUtils.paddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Review Return Shipping'),
          if (showPageHeader) ...[
            const SizedBox(height: 8),
            const Text(
              'Please review all details before submitting.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
          const SizedBox(height: 16),
          Gs1GroupCard(
            title: 'Operation Details',
            outlineColor: outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _row('Return Shipping Reference', 'Auto-generated on submit'),
                const SizedBox(height: 12),
                _row('Ship From', sourceGln?.glnCode ?? '-'),
                if (sourceGln?.locationName.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      sourceGln!.locationName,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 12),
                const Center(child: TraqIcon(AppAssets.iconArrowD, size: 20)),
                const SizedBox(height: 12),
                _row('Ship To', destinationGln?.glnCode ?? '-'),
                if (destinationGln?.locationName.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      destinationGln!.locationName,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                if (returnAuthorizationNumber.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _row('Return Authorization', returnAuthorizationNumber),
                ],
                if (purchaseOrder.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _row('Purchase Order', purchaseOrder),
                ],
                if (despatchAdvice.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _row('Despatch Advice', despatchAdvice),
                ],
                if (billOfLading.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _row('Bill of Lading', billOfLading),
                ],
                if (carrier.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _row('Carrier', carrier),
                ],
                if (trackingNumber.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _row('Tracking Number', trackingNumber),
                ],
                const SizedBox(height: 12),
                _row(
                  'Event Time',
                  eventTime != null
                      ? '${eventTime!.toLocal()}'.substring(0, 16)
                      : 'At time of submission',
                ),
              ],
            ),
          ),
          EpcContentsCard(
            title: 'Items to Return (${scannedEpcs.length})',
            epcs: scannedEpcs,
            emptyMessage: 'No EPCs added yet',
            hierarchyScreenTitle: 'Return Shipment Hierarchy',
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}