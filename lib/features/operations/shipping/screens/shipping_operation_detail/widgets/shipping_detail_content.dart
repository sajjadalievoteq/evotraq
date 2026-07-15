import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_body.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_details_loading_widget.dart';

class ShippingDetailContent extends StatelessWidget {
  const ShippingDetailContent({
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
  final ShippingResponse? operation;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (listLoading) {
      return const AppEmptyDetail(
        title: 'Select a shipping operation',
        subtitle: 'Choose one from the list to view its details.',
        iconAsset: AppAssets.iconPackage,
        loading: true,
      );
    }
    if (awaitingSelection) {
      return const AppEmptyDetail(
        title: 'Select a shipping operation',
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
        title: 'Select a shipping operation',
        subtitle: 'Choose one from the list to view its details.',
        iconAsset: AppAssets.iconPackage,
      );
    }

    return ShippingDetailBody(operation: operation!);
  }
}
