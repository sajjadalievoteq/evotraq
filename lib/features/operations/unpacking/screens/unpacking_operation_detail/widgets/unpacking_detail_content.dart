import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_body.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_details_loading_widget.dart';

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
    if (listLoading) {
      return const AppEmptyDetail(
        title: 'Select an unpacking operation',
        subtitle: 'Choose one from the list to view its details.',
        iconAsset: AppAssets.iconPackage,
        loading: true,
      );
    }
    if (awaitingSelection) {
      return const AppEmptyDetail(
        title: 'Select an unpacking operation',
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
        title: 'Select an unpacking operation',
        subtitle: 'Choose one from the list to view its details.',
        iconAsset: AppAssets.iconPackage,
      );
    }

    return UnpackingDetailBody(operation: operation!);
  }
}
