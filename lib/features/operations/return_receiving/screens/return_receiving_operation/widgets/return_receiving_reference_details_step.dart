import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/shipment_reference_details_step.dart';

class ReturnReceivingReferenceDetailsStep extends StatelessWidget {
  const ReturnReceivingReferenceDetailsStep({
    super.key,
    required this.sourceGln,
    required this.receivingGln,
    required this.sourceGlnError,
    required this.receivingGlnError,
    required this.onSourceGlnChanged,
    required this.onReturnReceivingGlnChanged,
    required this.returnAuthorizationController,
    required this.purchaseOrderController,
    required this.despatchAdviceController,
    required this.receivingAdviceController,
    required this.invoiceController,
    required this.billOfLadingController,
    required this.carrierController,
    required this.trackingController,
    required this.notesController,
    required this.gincNumberController,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
    this.showReferenceSection = true,
    this.showLocationSection = true,
    this.showDocumentSection = true,
    this.readOnlyLocations = false,
    this.returnReasonLabel,
    this.productGtin,
    this.productLotNumber,
    this.productExpiryDate,
    this.productQuantity,
    this.productDescription,
    this.productEpcs = const [],
  });

  final GLN? sourceGln;
  final GLN? receivingGln;
  final String? sourceGlnError;
  final String? receivingGlnError;
  final ValueChanged<GLN?> onSourceGlnChanged;
  final ValueChanged<GLN?> onReturnReceivingGlnChanged;
  final TextEditingController returnAuthorizationController;
  final TextEditingController purchaseOrderController;
  final TextEditingController despatchAdviceController;
  final TextEditingController receivingAdviceController;
  final TextEditingController invoiceController;
  final TextEditingController billOfLadingController;
  final TextEditingController carrierController;
  final TextEditingController trackingController;
  final TextEditingController notesController;
  final TextEditingController gincNumberController;
  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;
  final bool showPageHeader;
  final bool showReferenceSection;
  final bool showLocationSection;
  final bool showDocumentSection;
  final bool readOnlyLocations;
  final String? returnReasonLabel;
  final String? productGtin;
  final String? productLotNumber;
  final DateTime? productExpiryDate;
  final int? productQuantity;
  final String? productDescription;
  final List<String> productEpcs;

  @override
  Widget build(BuildContext context) => ShipmentReferenceDetailsStep(
        pageTitle: 'Return Receiving Details',
        pageSubtitle:
            'Capture Return Receiving Reference, ship-from/received-at locations, and shipment details.',
        operationLabel: 'Return Receiving',
        referenceSectionTitle: 'Return Receiving Reference',
        eventTimeLabel: 'Received On',
        documentSectionTitle: 'Return Receiving Details (Optional)',
        sourceGln: sourceGln,
        sourceGlnLabel: 'Returned From Location',
        sourceGlnHint: 'Search and select source GLN',
        sourceGlnError: sourceGlnError,
        onSourceGlnChanged: onSourceGlnChanged,
        destinationGln: receivingGln,
        destinationGlnLabel: 'Receiving Location (Received At)',
        destinationGlnHint: 'Search and select Return Receiving GLN',
        destinationGlnError: receivingGlnError,
        onDestinationGlnChanged: onReturnReceivingGlnChanged,
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
        receivingAdviceController: receivingAdviceController,
        invoiceController: invoiceController,
        billOfLadingController: billOfLadingController,
        carrierController: carrierController,
        trackingController: trackingController,
        notesController: notesController,
        gincNumberController: gincNumberController,
        returnReasonLabel: returnReasonLabel,
        productGtin: productGtin,
        productLotNumber: productLotNumber,
        productExpiryDate: productExpiryDate,
        productQuantity: productQuantity,
        productDescription: productDescription,
        productEpcs: productEpcs,
      );
}
