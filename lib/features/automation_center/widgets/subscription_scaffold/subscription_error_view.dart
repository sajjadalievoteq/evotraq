import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_widgets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

/// Shared retryable error card used by subscription lists and the job queue.
class SubscriptionErrorView extends StatelessWidget {
  const SubscriptionErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.padding = const EdgeInsets.symmetric(vertical: TraqSpacing.lg),
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  /// Outer padding. Defaults to vertical-only large spacing (subscription
  /// panels and embedded job queue). Pass [TraqSpacing.pagePad] for the
  /// standalone job-queue page layout.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: padding,
      child: TraqCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TraqIcon(
              AppAssets.iconAlert,
              size: 48,
              color: AppColorMapper.errorColor(context).withValues(alpha: 0.7),
            ),
            const SizedBox(height: TraqSpacing.lg),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: c.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TraqSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: TraqSpacing.xl),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
