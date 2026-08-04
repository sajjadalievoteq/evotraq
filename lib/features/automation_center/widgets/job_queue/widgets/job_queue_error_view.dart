import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JobQueueErrorView extends StatelessWidget {
  const JobQueueErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.embedded = false,
  });

  final String message;
  final VoidCallback onRetry;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: embedded
          ? const EdgeInsets.symmetric(vertical: TraqSpacing.lg)
          : TraqSpacing.pagePad,
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
              'Unable to load job queue',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: c.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TraqSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TraqSpacing.xl),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
