import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/error_state/app_error_state.dart';

class CbvErrorView extends StatelessWidget {
  const CbvErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: 'Failed to load CBV vocabulary',
      message: message,
      iconAsset: AppAssets.iconTag,
      onRetry: onRetry,
      retryLabel: 'Retry',
    );
  }
}
