import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/shipment_reference_details_step.dart';

class CancelShippingReferenceDetailsStep extends StatelessWidget {
  const CancelShippingReferenceDetailsStep({
    super.key,
    required this.sourceGln,
    required this.destinationGln,
    required this.sourceGlnError,
    required this.destinationGlnError,
    required this.onSourceGlnChanged,
    required this.onDestinationGlnChanged,
    required this.cancelReasonController,
    required this.originalReferenceController,
    required this.commentsController,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
  });

  final GLN? sourceGln;
  final GLN? destinationGln;
  final String? sourceGlnError;
  final String? destinationGlnError;
  final ValueChanged<GLN?> onSourceGlnChanged;
  final ValueChanged<GLN?> onDestinationGlnChanged;
  final TextEditingController cancelReasonController;
  final TextEditingController originalReferenceController;
  final TextEditingController commentsController;
  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;
  final bool showPageHeader;

  @override
  Widget build(BuildContext context) => ShipmentReferenceDetailsStep(
        pageTitle: 'Cancel Shipping',
        pageSubtitle: 'Digitally cancels a shipment in EPCIS (GS1 CBV 2.0 §8.5). '
            'Use only when goods have NOT left your premises.',
        operationLabel: 'Cancel Shipping',
        referenceSectionTitle: 'Cancel Reference',
        eventTimeLabel: 'Cancel Event Time',
        eventTimeEmptyLabel: 'Now',
        documentSectionTitle: 'Cancellation Details',
        sourceGln: sourceGln,
        sourceGlnLabel: 'Original Ship-From Location (Shipper)',
        sourceGlnHint: 'Search and select the original source GLN',
        sourceGlnError: sourceGlnError,
        onSourceGlnChanged: onSourceGlnChanged,
        destinationGln: destinationGln,
        destinationGlnLabel: 'Originally Intended Ship-To Location',
        destinationGlnHint: 'Search and select the intended recipient GLN',
        destinationGlnError: destinationGlnError,
        onDestinationGlnChanged: onDestinationGlnChanged,
        eventTime: eventTime,
        onEventTimeChanged: onEventTimeChanged,
        showPageHeader: showPageHeader,
        showReferenceSection: true,
        showLocationSection: true,
        showDocumentSection: true,
        notesController: commentsController,
        extraContent: _CancelShippingExtras(
          cancelReasonController: cancelReasonController,
          originalReferenceController: originalReferenceController,
        ),
      );
}

class _CancelShippingExtras extends StatelessWidget {
  const _CancelShippingExtras({
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
                      'This records a GS1 cancel shipping event — a digital cancellation '
                      'in the EPCIS traceability system only. '
                      'It does NOT physically return goods to you.',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Only use this if goods have NOT yet left your premises '
                '(e.g. shipment was staged but never dispatched). '
                'The system will mark the items as back in your possession.',
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
                        'If goods have already left your site, you must:\n'
                        '1. Coordinate physical return with the carrier.\n'
                        '2. Record a Return Shipping operation once goods arrive back.',
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
            labelText: 'Original Shipping Reference (GINC)',
            hintText: 'e.g. GINC-2026-0001 or urn:epc:id:ginc:0614141.xyz…',
            helperText:
                'Required for DSCSA — enter the GINC from the original shipment.',
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
                'e.g. Shipment staged but never dispatched — cancelled before pickup',
            helperText: 'Required — stored in EPCIS ILMD for DSCSA/FMD audit.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: outline),
            ),
            prefixIcon: const TraqIcon(AppAssets.iconDocument),
          ),
        ),
        SizedBox(height: 32,)
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
