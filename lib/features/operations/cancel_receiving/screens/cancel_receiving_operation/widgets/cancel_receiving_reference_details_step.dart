import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/shipment_reference_details_step.dart';

class CancelReceivingReferenceDetailsStep extends StatelessWidget {
  const CancelReceivingReferenceDetailsStep({
    super.key,
    required this.sourceGln,
    required this.receivingGln,
    required this.sourceGlnError,
    required this.receivingGlnError,
    required this.onSourceGlnChanged,
    required this.onReceivingGlnChanged,
    required this.cancelReasonController,
    required this.originalReferenceController,
    required this.commentsController,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
  });

  final GLN? sourceGln;
  final GLN? receivingGln;
  final String? sourceGlnError;
  final String? receivingGlnError;
  final ValueChanged<GLN?> onSourceGlnChanged;
  final ValueChanged<GLN?> onReceivingGlnChanged;
  final TextEditingController cancelReasonController;
  final TextEditingController originalReferenceController;
  final TextEditingController commentsController;
  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;
  final bool showPageHeader;

  @override
  Widget build(BuildContext context) => ShipmentReferenceDetailsStep(
        pageTitle: 'Cancel Receiving',
        pageSubtitle: 'Digitally cancels a receiving record in EPCIS (GS1 CBV 2.0 §8.5). '
            'Use only when a receiving event was recorded in error.',
        operationLabel: 'Cancel Receiving',
        referenceSectionTitle: 'Cancel Reference',
        eventTimeLabel: 'Cancel Event Time',
        eventTimeEmptyLabel: 'Now',
        documentSectionTitle: 'Cancellation Details',
        sourceGln: sourceGln,
        sourceGlnLabel: 'Original Sender (Ship-From GLN)',
        sourceGlnHint: 'Search and select the original sender\'s GLN',
        sourceGlnError: sourceGlnError,
        onSourceGlnChanged: onSourceGlnChanged,
        destinationGln: receivingGln,
        destinationGlnLabel: 'Receive-At Location (Your Site)',
        destinationGlnHint: 'Search and select the receiver\'s GLN',
        destinationGlnError: receivingGlnError,
        onDestinationGlnChanged: onReceivingGlnChanged,
        eventTime: eventTime,
        onEventTimeChanged: onEventTimeChanged,
        showPageHeader: showPageHeader,
        showReferenceSection: true,
        showLocationSection: true,
        showDocumentSection: true,
        notesController: commentsController,
        extraContent: _CancelReceivingExtras(
          cancelReasonController: cancelReasonController,
          originalReferenceController: originalReferenceController,
        ),
      );
}

class _CancelReceivingExtras extends StatelessWidget {
  const _CancelReceivingExtras({
    required this.cancelReasonController,
    required this.originalReferenceController,
  });

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
                  const Expanded(
                    child: Text(
                      'This records a GS1 cancel receiving event — a digital cancellation '
                      'of a receiving record in the EPCIS traceability system only. '
                      'It does NOT physically return goods to the sender.',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Only use this if a receiving event was recorded in error '
                '(e.g. goods were scanned twice, or the wrong items were received). '
                'The system will mark the items as back in transit.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TraqIcon(AppAssets.iconTruck, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'If goods need to be physically returned to the sender, use:\n'
                        '1. Return Shipping (at your site) to record the outbound return.\n'
                        '2. Coordinate receipt confirmation with the original sender.',
                        style: TextStyle(fontSize: 12),
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
            labelText: 'Original Receiving Reference (GINC)',
            hintText: 'e.g. GINC-2026-0001 or urn:epc:id:ginc:…',
            helperText:
                'Required for DSCSA — enter the GINC from the original receiving event.',
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
            hintText:
                'e.g. Duplicate scan — receiving event recorded in error',
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
