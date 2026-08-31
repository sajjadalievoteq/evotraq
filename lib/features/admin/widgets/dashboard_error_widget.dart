import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/error_state/app_error_state.dart';

class DashboardErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const DashboardErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      message: message,
      iconAsset: AppAssets.iconDashboard,
      onRetry: onRetry,
      retryLabel: 'Retry',
    );
  }
}
