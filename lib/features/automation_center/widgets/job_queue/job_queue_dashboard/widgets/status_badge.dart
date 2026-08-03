import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

enum JobQueueStatusTone { ok, warn, err, muted, info }

class JobQueueStatusBadge extends StatelessWidget {
  const JobQueueStatusBadge({
    super.key,
    required this.label,
    this.tone = JobQueueStatusTone.muted,
    this.pulse = false,
  });

  final String label;
  final JobQueueStatusTone tone;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Semantics(
      label: 'Status $label',

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TraqSpacing.md,
          vertical: TraqSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius:  TraqRadius.button,
          border: Border.all(color: color.withValues(alpha: 0.35)),
          // boxShadow: pulse
          //     ? [
          //         BoxShadow(
          //           color: color.withValues(alpha: 0.25),
          //           blurRadius: 8,
          //           spreadRadius: 0,
          //         ),
          //       ]
          //     : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: TraqSpacing.sm),
            Text(
              label,
              style: context.text.cap.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _color(BuildContext context) {
    switch (tone) {
      case JobQueueStatusTone.ok:
        return AppColorMapper.successColor(context);
      case JobQueueStatusTone.warn:
        return AppColorMapper.warningColor(context);
      case JobQueueStatusTone.err:
        return AppColorMapper.errorColor(context);
      case JobQueueStatusTone.info:
        return AppColorMapper.infoColor(context);
      case JobQueueStatusTone.muted:
        return context.colors.textMuted;
    }
  }
}

/// Compact status pill for job rows (color + label, never color-only).
class JobQueueStatusBadgeInline extends StatelessWidget {
  const JobQueueStatusBadgeInline({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TraqSpacing.sm,
          vertical: TraqSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: TraqRadius.chip,
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: context.text.cap.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: c.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
