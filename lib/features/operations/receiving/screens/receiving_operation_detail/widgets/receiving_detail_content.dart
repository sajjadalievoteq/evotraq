import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_awaiting_selection.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_body.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_detail_loading_skeleton.dart';

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
    required this.onRetry,
    this.onOperationUpdated,
  });

  final bool awaitingSelection;
  final bool listLoading;
  final bool isLoading;
  final String? errorMessage;
  final ReceivingResponse? operation;
  final GLN? sourceGlnDetails;
  final GLN? receivingGlnDetails;
  final VoidCallback onRetry;
  final ValueChanged<ReceivingResponse>? onOperationUpdated;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection || isLoading) {
      return const OperationDetailLoadingSkeleton();
    }

    if (errorMessage != null) {
      return ReceivingDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) return const OperationDetailLoadingSkeleton();

    return ReceivingDetailBody(
      operation: operation!,
      sourceGlnDetails: sourceGlnDetails,
      receivingGlnDetails: receivingGlnDetails,
      onOperationUpdated: onOperationUpdated,
    );
  }
}
