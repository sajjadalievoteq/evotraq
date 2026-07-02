import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_body.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_detail_loading_skeleton.dart';

/// Resolves which detail view to show based on loading/selection state.
class ReturnShippingDetailContent extends StatelessWidget {
  const ReturnShippingDetailContent({
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
  final ReturnShippingResponse? operation;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection || isLoading) {
      return const OperationDetailLoadingSkeleton();
    }
    if (errorMessage != null) {
      return ReturnShippingDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) return const OperationDetailLoadingSkeleton();

    return ReturnShippingDetailBody(operation: operation!);
  }
}
