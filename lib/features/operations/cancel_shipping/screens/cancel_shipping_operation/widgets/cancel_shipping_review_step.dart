import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/cancel_operation_widgets.dart';

class CancelShippingReviewStep extends StatelessWidget {
  const CancelShippingReviewStep({
    super.key,
    required this.sourceGln,
    required this.destinationGln,
    required this.cancelReason,
    required this.originalReference,
    required this.comments,
    required this.eventTime,
    required this.scannedEpcs,
    this.showPageHeader = true,
  });

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
    return CancelOperationReviewStep(
      isReceiving: false,
      sourceGln: sourceGln,
      destinationGln: destinationGln,
      cancelReason: cancelReason,
      originalReference: originalReference,
      comments: comments,
      eventTime: eventTime,
      scannedEpcs: scannedEpcs,
      showPageHeader: showPageHeader,
    );
  }
}
