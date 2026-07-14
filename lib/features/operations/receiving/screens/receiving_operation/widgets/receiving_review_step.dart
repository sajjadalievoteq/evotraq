import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_rows.dart';

class ReceivingReviewStep extends StatelessWidget {
  const ReceivingReviewStep({
    super.key,
    required this.sourceGln,
    required this.receivingGln,
    required this.purchaseOrder,
    required this.despatchAdvice,
    required this.receivingAdvice,
    required this.invoiceNumber,
    required this.billOfLading,
    required this.carrier,
    required this.trackingNumber,
    required this.notes,
    this.eventTime,
    required this.scannedEpcs,
    this.showPageHeader = true,
  });
  final GLN? sourceGln;
  final GLN? receivingGln;
  final String purchaseOrder;
  final String despatchAdvice;
  final String receivingAdvice;
  final String invoiceNumber;
  final String billOfLading;
  final String carrier;
  final String trackingNumber;
  final String notes;
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
            title: 'Review Receiving Operation',
            showPageHeader: showPageHeader,
          ),
          Gs1GroupCard(
            title: 'Operation Details',
            outlineColor: outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OperationReviewInfoRow(
                  'Receiving Reference',
                  'Auto-generated on submit',
                ),
                const SizedBox(height: 12),
                OperationReviewGlnTransfer(
                  sourceLabel: 'Ship From',
                  sourceGln: sourceGln,
                  destinationLabel: 'Received At',
                  destinationGln: receivingGln,
                ),
                OperationReviewOptionalFields([
                  OperationReviewField('Purchase Order', purchaseOrder),
                  OperationReviewField('Despatch Advice', despatchAdvice),
                  OperationReviewField(
                    'Receiving Advice (RECADV)',
                    receivingAdvice,
                  ),
                  OperationReviewField('Invoice Number', invoiceNumber),
                  OperationReviewField('Bill of Lading', billOfLading),
                  OperationReviewField('Carrier', carrier),
                  OperationReviewField('Tracking Number', trackingNumber),
                  OperationReviewField('Notes', notes),
                ]),
                const SizedBox(height: 12),
                OperationReviewInfoRow(
                  'Event Time',
                  eventTime != null
                      ? '${eventTime!.toLocal()}'.substring(0, 16)
                      : 'At time of submission',
                ),
              ],
            ),
          ),
          OperationReviewEpcBadgeList(
            epcs: scannedEpcs,
            outlineColor: outline,
          ),
        ],
      ),
    );
  }
}
