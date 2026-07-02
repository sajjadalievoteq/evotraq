import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

class CancelReceivingReviewStep extends StatelessWidget {
  const CancelReceivingReviewStep({
    super.key,
    required this.sourceGln,
    required this.receivingGln,
    required this.cancelReason,
    required this.originalReference,
    required this.comments,
    required this.eventTime,
    required this.scannedEpcs,
    this.showPageHeader = true,
  });

  final GLN? sourceGln;
  final GLN? receivingGln;
  final String cancelReason;
  final String originalReference;
  final String comments;
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
          const SectionLabel('Review Cancel Receiving'),
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
                _row('Cancel Receiving Reference', 'Auto-generated on submit'),
                const SizedBox(height: 12),
                _row('GS1 bizStep', 'cancel receiving (CBV 2.0 §8.5)'),
                const SizedBox(height: 12),
                _row(
                  'Post-cancel disposition',
                  'in_transit — system marks items as back in transit. '
                  'Ensures the erroneous receiving record is corrected in EPCIS.',
                ),
                const SizedBox(height: 12),
                _complianceRow('Original GINC', originalReference),
                const SizedBox(height: 12),
                _row(
                  'Cancellation Reason',
                  cancelReason.trim().isEmpty
                      ? '(not set — required)'
                      : cancelReason,
                ),
                const SizedBox(height: 12),
                _row('Original Sender', sourceGln?.glnCode ?? '-'),
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
                _row('Receive-At Location', receivingGln?.glnCode ?? '-'),
                if (receivingGln?.locationName.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      receivingGln!.locationName,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                if (comments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _row('Comments', comments),
                ],
                const SizedBox(height: 12),
                _row(
                  'Cancel Time',
                  eventTime != null
                      ? '${eventTime!.toLocal()}'.substring(0, 16)
                      : 'At time of submission',
                ),
              ],
            ),
          ),
          EpcContentsCard(
            title: 'EPCs to Cancel (${scannedEpcs.length})',
            epcs: scannedEpcs,
            emptyMessage: 'No EPCs added yet',
            hierarchyScreenTitle: 'Cancel Receiving Hierarchy',
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

  Widget _complianceRow(String label, String value) {
    final missing = value.trim().isEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(
            missing
                ? '⚠ Not provided — DSCSA requires the original GINC'
                : value,
            style: TextStyle(color: missing ? Colors.orange[700] : null),
          ),
        ),
      ],
    );
  }
}
