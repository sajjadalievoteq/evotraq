import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

/// Compact empty-state used across job-queue dashboard cards and tabs.
class JobQueueEmptyPanel extends StatelessWidget {
  const JobQueueEmptyPanel({
    super.key,
    required this.title,
    this.subtitle,
    this.iconAsset = AppAssets.iconList,
  });

  final String title;
  final String? subtitle;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(iconAsset, size: 28, color: c.textMuted),
          const SizedBox(height: TraqSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: TraqSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: c.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
