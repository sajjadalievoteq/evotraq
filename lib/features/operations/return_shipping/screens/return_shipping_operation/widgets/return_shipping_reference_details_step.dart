import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/models/pharma_return_reason.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/shipment_reference_details_step.dart';

/// Step 1: shipping reference and location details.
class ReturnShippingReferenceDetailsStep extends StatelessWidget {
  const ReturnShippingReferenceDetailsStep({
    super.key,
    required this.sourceGln,
    required this.destinationGln,
    required this.sourceGlnError,
    required this.destinationGlnError,
    required this.onSourceGlnChanged,
    required this.onDestinationGlnChanged,
    required this.returnAuthorizationController,
    required this.purchaseOrderController,
    required this.despatchAdviceController,
    required this.billOfLadingController,
    required this.carrierController,
    required this.trackingController,
    required this.gincNumberController,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
    this.showReferenceSection = true,
    this.showLocationSection = true,
    this.showDocumentSection = true,
    this.readOnlyLocations = false,
    this.selectedReturnReason,
    this.onReturnReasonChanged,
    this.showReturnReasonField = false,
    this.productGtin,
    this.productLotNumber,
    this.productExpiryDate,
    this.productQuantity,
    this.productDescription,
    this.productEpcs = const [],
  });

  final GLN? sourceGln;
  final GLN? destinationGln;
  final String? sourceGlnError;
  final String? destinationGlnError;
  final ValueChanged<GLN?> onSourceGlnChanged;
  final ValueChanged<GLN?> onDestinationGlnChanged;
  final TextEditingController returnAuthorizationController;
  final TextEditingController purchaseOrderController;
  final TextEditingController despatchAdviceController;
  final TextEditingController billOfLadingController;
  final TextEditingController carrierController;
  final TextEditingController trackingController;
  final TextEditingController gincNumberController;
  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;
  final bool showPageHeader;
  final bool showReferenceSection;
  final bool showLocationSection;
  final bool showDocumentSection;
  final bool readOnlyLocations;
  final PharmaReturnReason? selectedReturnReason;
  final ValueChanged<PharmaReturnReason?>? onReturnReasonChanged;
  final bool showReturnReasonField;
  final String? productGtin;
  final String? productLotNumber;
  final DateTime? productExpiryDate;
  final int? productQuantity;
  final String? productDescription;
  final List<String> productEpcs;

  @override
  Widget build(BuildContext context) => ShipmentReferenceDetailsStep(
        pageTitle: 'Return Shipping Details',
        pageSubtitle:
            'Capture shipping reference, origin, destination, and dispatch details.',
        operationLabel: 'Return Shipping',
        referenceSectionTitle: 'Return Shipping Reference',
        eventTimeLabel: 'Event Date & Time',
        eventTimeEmptyLabel: 'Now',
        documentSectionTitle: 'Return Details (Optional)',
        sourceGln: sourceGln,
        sourceGlnLabel: 'Return From Location',
        sourceGlnHint: 'Search and select source GLN',
        sourceGlnError: sourceGlnError,
        onSourceGlnChanged: onSourceGlnChanged,
        destinationGln: destinationGln,
        destinationGlnLabel: 'Return To Location',
        destinationGlnHint: 'Search and select destination GLN',
        destinationGlnError: destinationGlnError,
        onDestinationGlnChanged: onDestinationGlnChanged,
        eventTime: eventTime,
        onEventTimeChanged: onEventTimeChanged,
        showPageHeader: showPageHeader,
        showReferenceSection: showReferenceSection,
        showLocationSection: showLocationSection,
        showDocumentSection: showDocumentSection,
        readOnlyLocations: readOnlyLocations,
        returnAuthorizationController: returnAuthorizationController,
        purchaseOrderController: purchaseOrderController,
        despatchAdviceController: despatchAdviceController,
        billOfLadingController: billOfLadingController,
        carrierController: carrierController,
        trackingController: trackingController,
        gincNumberController: gincNumberController,
        showReturnReasonField: showReturnReasonField,
        selectedReturnReason: selectedReturnReason,
        onReturnReasonChanged: onReturnReasonChanged,
        productGtin: productGtin,
        productLotNumber: productLotNumber,
        productExpiryDate: productExpiryDate,
        productQuantity: productQuantity,
        productDescription: productDescription,
        productEpcs: productEpcs,
      );
}
