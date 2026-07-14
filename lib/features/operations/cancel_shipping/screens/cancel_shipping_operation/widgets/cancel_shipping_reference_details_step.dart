import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/cancel_operation_widgets.dart';
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
        extraContent: CancelOperationExtras(
          isReceiving: false,
          cancelReasonController: cancelReasonController,
          originalReferenceController: originalReferenceController,
        ),
      );
}
