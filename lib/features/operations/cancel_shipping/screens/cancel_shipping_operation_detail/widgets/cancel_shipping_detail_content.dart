import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_body.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_details_loading_widget.dart';

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
    if (listLoading) {
      return const AppEmptyDetail(
        title: 'Select a cancel shipping operation',
        subtitle: 'Choose one from the list to view its details.',
        iconAsset: AppAssets.iconPackage,
        loading: true,
      );
    }
    if (awaitingSelection) {
      return const AppEmptyDetail(
        title: 'Select a cancel shipping operation',
        subtitle: 'Choose one from the list to view its details.',
        iconAsset: AppAssets.iconPackage,
      );
    }
    if (isLoading) {
      return const OperationDetailsLoadingWidget();
    }
    if (errorMessage != null) {
      return OperationDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) {
      return const AppEmptyDetail(
        title: 'Select a cancel shipping operation',
        subtitle: 'Choose one from the list to view its details.',
        iconAsset: AppAssets.iconPackage,
      );
    }

    return CancelShippingDetailBody(operation: operation!);
  }
}
