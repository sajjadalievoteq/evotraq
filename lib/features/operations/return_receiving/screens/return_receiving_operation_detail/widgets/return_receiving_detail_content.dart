import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_body.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_details_loading_widget.dart';

class ReturnReceivingDetailContent extends StatelessWidget {
  const ReturnReceivingDetailContent({
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
  final ReturnReceivingResponse? operation;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (listLoading || isLoading) {
      return const OperationDetailsLoadingWidget();
    }
    if (awaitingSelection) {
      return AppEmptyDetail(
        title: 'Select a return receiving operation',
        subtitle: 'Choose one from the list to view its details.',
        iconAsset: NavIcons.returnReceiving,
      );
    }
    if (errorMessage != null) {
      return OperationDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) {
      return AppEmptyDetail(
        title: 'Select a return receiving operation',
        subtitle: 'Choose one from the list to view its details.',
        iconAsset: NavIcons.returnReceiving,
      );
    }

    return ReturnReceivingDetailBody(operation: operation!);
  }
}
