import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

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
    final color = switch (tone) {
      JobQueueStatusTone.ok => AppColorMapper.successColor(context),
      JobQueueStatusTone.warn => AppColorMapper.warningColor(context),
      JobQueueStatusTone.err => AppColorMapper.errorColor(context),
      JobQueueStatusTone.info => AppColorMapper.infoColor(context),
      JobQueueStatusTone.muted => context.colors.textMuted,
    };
    return Semantics(
      label: 'Status $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TraqSpacing.md,
          vertical: TraqSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: TraqRadius.button,
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
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
}
