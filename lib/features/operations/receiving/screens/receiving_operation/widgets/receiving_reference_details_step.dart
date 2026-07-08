import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/shipment_reference_details_step.dart';

class ReceivingReferenceDetailsStep extends StatelessWidget {
  const ReceivingReferenceDetailsStep({
    super.key,
    required this.sourceGln,
    required this.receivingGln,
    required this.sourceGlnError,
    required this.receivingGlnError,
    required this.onSourceGlnChanged,
    required this.onReceivingGlnChanged,
    required this.purchaseOrderController,
    required this.despatchAdviceController,
    required this.receivingAdviceController,
    required this.invoiceController,
    required this.billOfLadingController,
    required this.carrierController,
    required this.trackingController,
    required this.notesController,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
    this.showReferenceSection = true,
    this.showLocationSection = true,
    this.showDocumentSection = true,
  });

  final GLN? sourceGln;
  final GLN? receivingGln;
  final String? sourceGlnError;
  final String? receivingGlnError;
  final ValueChanged<GLN?> onSourceGlnChanged;
  final ValueChanged<GLN?> onReceivingGlnChanged;
  final TextEditingController purchaseOrderController;
  final TextEditingController despatchAdviceController;
  final TextEditingController receivingAdviceController;
  final TextEditingController invoiceController;
  final TextEditingController billOfLadingController;
  final TextEditingController carrierController;
  final TextEditingController trackingController;
  final TextEditingController notesController;
  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;
  final bool showPageHeader;
  final bool showReferenceSection;
  final bool showLocationSection;
  final bool showDocumentSection;

  @override
  Widget build(BuildContext context) => ShipmentReferenceDetailsStep(
        pageTitle: 'Receiving Reference Details',
        pageSubtitle:
            'Capture receiving reference, ship-from/received-at locations, and shipment details.',
        operationLabel: 'Receiving',
        referenceSectionTitle: 'Receiving Reference',
        eventTimeLabel: 'Received On',
        documentSectionTitle: 'Shipment Details (Optional)',
        sourceGln: sourceGln,
        sourceGlnLabel: 'Ship From Location',
        sourceGlnHint: 'Search and select source GLN',
        sourceGlnError: sourceGlnError,
        onSourceGlnChanged: onSourceGlnChanged,
        destinationGln: receivingGln,
        destinationGlnLabel: 'Receiving Location (Received At)',
        destinationGlnHint: 'Search and select receiving GLN',
        destinationGlnError: receivingGlnError,
        onDestinationGlnChanged: onReceivingGlnChanged,
        eventTime: eventTime,
        onEventTimeChanged: onEventTimeChanged,
        showPageHeader: showPageHeader,
        showReferenceSection: showReferenceSection,
        showLocationSection: showLocationSection,
        showDocumentSection: showDocumentSection,
        purchaseOrderController: purchaseOrderController,
        despatchAdviceController: despatchAdviceController,
        receivingAdviceController: receivingAdviceController,
        invoiceController: invoiceController,
        billOfLadingController: billOfLadingController,
        carrierController: carrierController,
        trackingController: trackingController,
        notesController: notesController,
      );
}
