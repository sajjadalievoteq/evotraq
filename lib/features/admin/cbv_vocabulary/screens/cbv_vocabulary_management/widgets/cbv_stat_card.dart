import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_stat.dart';

class CbvStatCard extends StatelessWidget {
  const CbvStatCard({
    super.key,
    required this.title,
    required this.total,
    required this.enabled,
    required this.disabled,
    required this.iconAsset,
    required this.color,
  });
  final String title;
  final int total;
  final int enabled;
  final int disabled;
  final String iconAsset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(iconAsset, color: color, size: 20),
                const SizedBox(width: TraqSpacing.sm),
                Text(title, style: context.text.h3.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: TraqSpacing.md),
            Row(
              children: [
                Expanded(
                  child: CbvStat(
                    label: 'Total',
                    value: total,
                    color: colors.textPrimary,
                  ),
                ),
                Expanded(
                  child: CbvStat(
                    label: 'Enabled',
                    value: enabled,
                    color: colors.success,
                  ),
                ),
                Expanded(
                  child: CbvStat(
                    label: 'Disabled',
                    value: disabled,
                    color: disabled > 0 ? colors.warning : colors.textFaint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
