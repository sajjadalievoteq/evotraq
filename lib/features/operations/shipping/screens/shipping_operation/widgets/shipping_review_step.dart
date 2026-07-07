import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_epc_type_utils.dart';

/// Step 3: review all shipping details before submission.
class ShippingReviewStep extends StatelessWidget {
  const ShippingReviewStep({
    super.key,
    required this.sourceGln,
    required this.destinationGln,
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
          const SectionLabel('Review Shipping Operation'),
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
                _row('Shipping Reference', 'Auto-generated on submit'),
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
          Gs1GroupCard(
            title: 'EPC List (${scannedEpcs.length})',
            outlineColor: outline,
            child: scannedEpcs.isEmpty
                ? const Text('No EPCs added yet')
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: scannedEpcs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final epc = scannedEpcs[index];
                        final badgeColor = OperationEpcTypeUtils.colorFromValue(
                          epc,
                        );
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}.',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    epc,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: badgeColor.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      OperationEpcTypeUtils.labelFromValue(epc),
                                      style: TextStyle(
                                        color: badgeColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
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