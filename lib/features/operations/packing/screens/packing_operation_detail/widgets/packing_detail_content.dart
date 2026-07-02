import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_body.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_detail_loading_skeleton.dart';

/// Resolves which detail view to show based on loading/selection state.
class PackingDetailContent extends StatelessWidget {
  const PackingDetailContent({
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
  final PackingResponse? operation;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection || isLoading) {
      return const OperationDetailLoadingSkeleton();
    }
    if (errorMessage != null) {
      return PackingDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) return SizedBox(child: Text('Empty'),);
    return PackingDetailBody(operation: operation!);
  }
}
