import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/error_state/app_error_state.dart';

/// Shared retryable error card used by subscription lists and the job queue.
class SubscriptionErrorView extends StatelessWidget {
  const SubscriptionErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.iconAsset = AppAssets.iconNotification,
    this.padding = const EdgeInsets.symmetric(vertical: TraqSpacing.lg),
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final String iconAsset;

  /// Outer padding. Defaults to vertical-only large spacing (subscription
  /// panels and embedded job queue). Pass [TraqSpacing.pagePad] for the
  /// standalone job-queue page layout.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: AppErrorState(
        title: title,
        message: message,
        iconAsset: iconAsset,
        onRetry: onRetry,
        retryLabel: 'Retry',
      ),
    );
  }
}
