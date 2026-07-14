import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/cancel_operation_widgets.dart';
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
        extraContent: CancelOperationExtras(
          isReceiving: true,
          cancelReasonController: cancelReasonController,
          originalReferenceController: originalReferenceController,
        ),
      );
}
