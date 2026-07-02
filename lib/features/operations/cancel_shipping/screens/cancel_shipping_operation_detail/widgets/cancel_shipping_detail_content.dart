import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_body.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_detail_loading_skeleton.dart';

/// Resolves which detail view to show based on loading/selection state.
class CancelShippingDetailContent extends StatelessWidget {
  const CancelShippingDetailContent({
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
  final CancelShippingResponse? operation;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection || isLoading) {
      return const OperationDetailLoadingSkeleton();
    }
    if (errorMessage != null) {
      return CancelShippingDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) return const OperationDetailLoadingSkeleton();

    return CancelShippingDetailBody(operation: operation!);
  }
}
