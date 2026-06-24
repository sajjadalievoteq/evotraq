import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_awaiting_selection.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_body.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_skeleton.dart';

/// Resolves which detail view to show based on loading/selection state.
class ReceivingDetailContent extends StatelessWidget {
  const ReceivingDetailContent({
    super.key,
    required this.awaitingSelection,
    required this.listLoading,
    required this.isLoading,
    required this.errorMessage,
    required this.operation,
    required this.sourceGlnDetails,
    required this.receivingGlnDetails,
    required this.showAllEpcs,
    required this.onShowAllEpcs,
    required this.onRetry,
  });

  final bool awaitingSelection;
  final bool listLoading;
  final bool isLoading;
  final String? errorMessage;
  final ReceivingResponse? operation;
  final GLN? sourceGlnDetails;
  final GLN? receivingGlnDetails;
  final bool showAllEpcs;
  final VoidCallback onShowAllEpcs;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection) {
      return ReceivingDetailAwaitingSelection(listLoading: listLoading);
    }
    if (isLoading) return const ReceivingDetailSkeleton();
    if (errorMessage != null) {
      return ReceivingDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) return const ReceivingDetailSkeleton();

    return ReceivingDetailBody(
      operation: operation!,
      sourceGlnDetails: sourceGlnDetails,
      receivingGlnDetails: receivingGlnDetails,
      showAllEpcs: showAllEpcs,
      onShowAllEpcs: onShowAllEpcs,
    );
  }
}
