import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_compliance_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_field.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_gln_transfer.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_optional_fields.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_step_header.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';


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
                  sourceLabel: isReceiving ? 'Original Sender' : 'Ship From',
                  sourceGln: sourceGln,
                  destinationLabel: isReceiving
                      ? 'Receive-At Location'
                      : 'Ship To',
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
