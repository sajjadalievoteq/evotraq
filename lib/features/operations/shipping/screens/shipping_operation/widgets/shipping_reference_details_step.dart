import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/shipment_reference_details_step.dart';

/// Step 1: shipping reference and location details.
class ShippingReferenceDetailsStep extends StatelessWidget {
  const ShippingReferenceDetailsStep({
    super.key,
    required this.sourceGln,
    required this.destinationGln,
    required this.sourceGlnError,
    required this.destinationGlnError,
    required this.onSourceGlnChanged,
    required this.onDestinationGlnChanged,
    required this.purchaseOrderController,
    required this.despatchAdviceController,
    required this.billOfLadingController,
    required this.carrierController,
    required this.trackingController,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
    this.showReferenceSection = true,
    this.showLocationSection = true,
    this.showDocumentSection = true,
  });

  final GLN? sourceGln;
  final GLN? destinationGln;
  final String? sourceGlnError;
  final String? destinationGlnError;
  final ValueChanged<GLN?> onSourceGlnChanged;
  final ValueChanged<GLN?> onDestinationGlnChanged;
  final TextEditingController purchaseOrderController;
  final TextEditingController despatchAdviceController;
  final TextEditingController billOfLadingController;
  final TextEditingController carrierController;
  final TextEditingController trackingController;
  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;
  final bool showPageHeader;
  final bool showReferenceSection;
  final bool showLocationSection;
  final bool showDocumentSection;

  @override
  Widget build(BuildContext context) => ShipmentReferenceDetailsStep(
        pageTitle: 'Shipping Reference Details',
        pageSubtitle:
            'Capture shipping reference, origin, destination, and dispatch details.',
        operationLabel: 'Shipping',
        referenceSectionTitle: 'Shipping Reference',
        eventTimeLabel: 'Event Date & Time',
        eventTimeEmptyLabel: 'Now',
        documentSectionTitle: 'Shipping Details (Optional)',
        sourceGln: sourceGln,
        sourceGlnLabel: 'Ship From Location',
        sourceGlnHint: 'Search and select source GLN',
        sourceGlnError: sourceGlnError,
        onSourceGlnChanged: onSourceGlnChanged,
        destinationGln: destinationGln,
        destinationGlnLabel: 'Ship To Location',
        destinationGlnHint: 'Search and select destination GLN',
        destinationGlnError: destinationGlnError,
        onDestinationGlnChanged: onDestinationGlnChanged,
        eventTime: eventTime,
        onEventTimeChanged: onEventTimeChanged,
        showPageHeader: showPageHeader,
        showReferenceSection: showReferenceSection,
        showLocationSection: showLocationSection,
        showDocumentSection: showDocumentSection,
        purchaseOrderController: purchaseOrderController,
        despatchAdviceController: despatchAdviceController,
        billOfLadingController: billOfLadingController,
        carrierController: carrierController,
        trackingController: trackingController,
      );
}
