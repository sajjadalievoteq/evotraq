import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class NotificationCenterError extends StatelessWidget {
  const NotificationCenterError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.lg),
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
              'Error loading delivery activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: c.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TraqSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.textMuted,
                  ),
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
