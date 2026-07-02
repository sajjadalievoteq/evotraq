import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_body.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_detail_loading_skeleton.dart';

/// Resolves which detail view to show based on loading/selection state.
class UnpackingDetailContent extends StatelessWidget {
  const UnpackingDetailContent({
    super.key,
    required this.awaitingSelection,
    required this.listLoading,
    required this.isLoading,
    required this.errorMessage,
    required this.operation,
    required this.onRetry,
  });

  final bool awaitingSelection;
  final bool listLoading;
  final bool isLoading;
  final String? errorMessage;
  final UnpackingResponse? operation;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection || isLoading) {
      if (isLoading) return const OperationDetailLoadingSkeleton();
    }

    if (errorMessage != null) {
      return UnpackingDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) return const OperationDetailLoadingSkeleton();

    return UnpackingDetailBody(operation: operation!);
  }
}
