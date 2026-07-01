import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_awaiting_selection.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_body.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_detail_loading_skeleton.dart';

/// Resolves which detail view to show based on loading/selection state.
class ReturnReceivingDetailContent extends StatelessWidget {
  const ReturnReceivingDetailContent({
    super.key,
    required this.awaitingSelection,
    required this.listLoading,
    required this.isLoading,
    required this.errorMessage,
    required this.operation,
    required this.sourceGlnDetails,
    required this.receivingGlnDetails,
    required this.onRetry,
  });

  final bool awaitingSelection;
  final bool listLoading;
  final bool isLoading;
  final String? errorMessage;
  final ReturnReceivingResponse? operation;
  final GLN? sourceGlnDetails;
  final GLN? receivingGlnDetails;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection || isLoading) {
      return const OperationDetailLoadingSkeleton();
    }
    if (errorMessage != null) {
      return ReturnReceivingDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) return const OperationDetailLoadingSkeleton();

    return ReturnReceivingDetailBody(
      operation: operation!,
      sourceGlnDetails: sourceGlnDetails,
      receivingGlnDetails: receivingGlnDetails,
    );
  }
}

