import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_rows.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

/// Shared cancel shipping / cancel receiving UI. [isReceiving] selects copy only.
class CancelOperationReviewStep extends StatelessWidget {
  const CancelOperationReviewStep({
    super.key,
    required this.isReceiving,
    required this.sourceGln,
    required this.destinationGln,
    required this.cancelReason,
    required this.originalReference,
    required this.comments,
    required this.eventTime,
    required this.scannedEpcs,
    this.showPageHeader = true,
  });

  final bool isReceiving;
  final GLN? sourceGln;
  final GLN? destinationGln;
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
          OperationReviewStepHeader(
            title: isReceiving
                ? 'Review Cancel Receiving'
                : 'Review Cancel Shipping',
            showPageHeader: showPageHeader,
          ),
          Gs1GroupCard(
            title: 'Operation Details',
            outlineColor: outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OperationReviewInfoRow(
                  isReceiving
                      ? 'Cancel Receiving Reference'
                      : 'Cancel Shipping Reference',
                  'Auto-generated on submit',
                ),
                const SizedBox(height: 12),
                OperationReviewInfoRow(
                  'GS1 bizStep',
                  isReceiving
                      ? 'cancel receiving (CBV 2.0 §8.5)'
                      : 'cancel shipping (CBV 2.0 §8.5)',
                ),
                const SizedBox(height: 12),
                OperationReviewInfoRow(
                  'Post-cancel disposition',
                  isReceiving
                      ? 'in_transit — system marks items as back in transit. '
                          'Ensures the erroneous receiving record is corrected in EPCIS.'
                      : 'in_possession — items marked as physically at shipper site. '
                          'Ensure this matches reality before submitting.',
                ),
                const SizedBox(height: 12),
                OperationReviewComplianceRow(
                  'Original GINC',
                  originalReference,
                ),
                const SizedBox(height: 12),
                OperationReviewInfoRow(
                  'Cancellation Reason',
                  cancelReason.trim().isEmpty
                      ? '(not set — required)'
                      : cancelReason,
                ),
                const SizedBox(height: 12),
                OperationReviewGlnTransfer(
                  sourceLabel:
                      isReceiving ? 'Original Sender' : 'Ship From',
                  sourceGln: sourceGln,
                  destinationLabel:
                      isReceiving ? 'Receive-At Location' : 'Ship To',
                  destinationGln: destinationGln,
                ),
                OperationReviewOptionalFields([
                  OperationReviewField('Comments', comments),
                ]),
                const SizedBox(height: 12),
                OperationReviewInfoRow(
                  isReceiving ? 'Cancel Time' : 'Event Time',
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
            hierarchyScreenTitle: isReceiving
                ? 'Cancel Receiving Hierarchy'
                : 'Cancel Shipment Hierarchy',
          ),
        ],
      ),
    );
  }
}

class CancelOperationExtras extends StatelessWidget {
  const CancelOperationExtras({
    super.key,
    required this.isReceiving,
    required this.cancelReasonController,
    required this.originalReferenceController,
  });

  final bool isReceiving;
  final TextEditingController cancelReasonController;
  final TextEditingController originalReferenceController;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Gs1GroupCard(
          title: 'Important — Digital Record Only',
          outlineColor: Theme.of(context).colorScheme.errorContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TraqIcon(
                    AppAssets.iconAlert,
                    size: 18,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isReceiving
                          ? 'This records a GS1 cancel receiving event — a digital cancellation '
                              'of a receiving record in the EPCIS traceability system only. '
                              'It does NOT physically return goods to the sender.'
                          : 'This records a GS1 cancel shipping event — a digital cancellation '
                              'in the EPCIS traceability system only. '
                              'It does NOT physically return goods to you.',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isReceiving
                    ? 'Only use this if a receiving event was recorded in error '
                        '(e.g. goods were scanned twice, or the wrong items were received). '
                        'The system will mark the items as back in transit.'
                    : 'Only use this if goods have NOT yet left your premises '
                        '(e.g. shipment was staged but never dispatched). '
                        'The system will mark the items as back in your possession.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TraqIcon(AppAssets.iconTruck, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isReceiving
                            ? 'If goods need to be physically returned to the sender, use:\n'
                                '1. Return Shipping (at your site) to record the outbound return.\n'
                                '2. Coordinate receipt confirmation with the original sender.'
                            : 'If goods have already left your site, you must:\n'
                                '1. Coordinate physical return with the carrier.\n'
                                '2. Record a Return Shipping operation once goods arrive back.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _badge(context, 'GS1 CBV 2.0'),
                  _badge(context, 'DSCSA'),
                  _badge(context, 'EU FMD'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: originalReferenceController,
          decoration: InputDecoration(
            labelText: isReceiving
                ? 'Original Receiving Reference (GINC)'
                : 'Original Shipping Reference (GINC)',
            hintText: isReceiving
                ? 'e.g. GINC-2026-0001 or urn:epc:id:ginc:…'
                : 'e.g. GINC-2026-0001 or urn:epc:id:ginc:0614141.xyz…',
            helperText: isReceiving
                ? 'Required for DSCSA — enter the GINC from the original receiving event.'
                : 'Required for DSCSA — enter the GINC from the original shipment.',
            helperMaxLines: 2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: outline),
            ),
            prefixIcon: const TraqIcon(AppAssets.iconShipment),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: cancelReasonController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Cancellation Reason *',
            hintText: isReceiving
                ? 'e.g. Duplicate scan — receiving event recorded in error'
                : 'e.g. Shipment staged but never dispatched — cancelled before pickup',
            helperText: 'Required — stored in EPCIS ILMD for DSCSA/FMD audit.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: outline),
            ),
            prefixIcon: const TraqIcon(AppAssets.iconDocument),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _badge(BuildContext context, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
}
