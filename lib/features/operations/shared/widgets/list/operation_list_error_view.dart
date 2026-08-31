import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/error_state/app_error_state.dart';

class OperationListErrorView extends StatelessWidget {
  const OperationListErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.iconAsset = AppAssets.iconAlert,
  });

  final String errorMessage;
  final VoidCallback onRetry;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      message: errorMessage,
      iconAsset: iconAsset,
      onRetry: onRetry,
      retryLabel: 'Retry',
    );
  }
}
