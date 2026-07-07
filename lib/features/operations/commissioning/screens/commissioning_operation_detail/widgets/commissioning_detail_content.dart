import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_body.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_awaiting_selection.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_details_loading_widget.dart';

class CommissioningDetailContent extends StatelessWidget {
  const CommissioningDetailContent({
    super.key,
    required this.awaitingSelection,
    required this.listLoading,
    required this.isLoading,
    required this.errorMessage,
    required this.batch,
    required this.items,
    required this.itemStatuses,
    required this.onRetry,
  });

  final bool awaitingSelection;
  final bool listLoading;
  final bool isLoading;
  final String? errorMessage;
  final CommissioningBatch? batch;
  final List<CommissioningBatchItem> items;
  final Map<String, ItemStatus> itemStatuses;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection || isLoading) {
      return const OperationDetailsLoadingWidget();

    }

    if (errorMessage != null) {
      return OperationDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (batch == null) {
      return const OperationDetailAwaitingSelection(operationLabel: 'commissioning');
    }
    return CommissioningDetailBody(batch: batch!, items: items, itemStatuses: itemStatuses);
  }
}
