import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_awaiting_selection.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_body.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_skeleton.dart';

class CommissioningDetailContent extends StatelessWidget {
  const CommissioningDetailContent({
    super.key,
    required this.awaitingSelection,
    required this.listLoading,
    required this.isLoading,
    required this.errorMessage,
    required this.batch,
    required this.items,
    required this.onRetry,
  });

  final bool awaitingSelection;
  final bool listLoading;
  final bool isLoading;
  final String? errorMessage;
  final CommissioningBatch? batch;
  final List<CommissioningBatchItem> items;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection) {
      return listLoading
          ? const CommissioningDetailSkeleton()
          : const CommissioningDetailAwaitingSelection();
    }
    if (isLoading) return const CommissioningDetailSkeleton();
    if (errorMessage != null) {
      return CommissioningDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (batch == null) return const CommissioningDetailAwaitingSelection();
    return CommissioningDetailBody(batch: batch!, items: items);
  }
}
