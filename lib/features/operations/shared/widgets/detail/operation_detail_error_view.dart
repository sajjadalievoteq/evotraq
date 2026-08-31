import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/error_state/app_error_state.dart';

class OperationDetailErrorView extends StatelessWidget {
  const OperationDetailErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: 'Unable to load operation',
      message: errorMessage,
      iconAsset: AppAssets.iconPackage,
      onRetry: onRetry,
      retryLabel: 'Retry',
    );
  }
}
