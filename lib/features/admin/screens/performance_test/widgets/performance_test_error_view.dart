import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/error_state/app_error_state.dart';

class PerformanceTestErrorView extends StatelessWidget {
  const PerformanceTestErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: 'Unable to load performance tests',
      message: message,
      iconAsset: AppAssets.iconTimer,
      onRetry: onRetry,
      retryLabel: 'Retry',
    );
  }
}
