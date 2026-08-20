import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class TatmeenDisabledState extends StatelessWidget {
  const TatmeenDisabledState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TraqSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: TraqRadius.input,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraqIcon(AppAssets.iconInfo, size: 20, color: colors.textMuted),
          const SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tatmeen Integration is disabled',
                  style: context.text.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: TraqSpacing.xs),
                Text(
                  'Enable the integration to prepare TraqTrace for future Tatmeen '
                  'workflows. Phase 1 does not connect to external Tatmeen services.',
                  style: context.text.bodySm.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
