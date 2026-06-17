import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_state.dart';

import '../../../../core/utils/responsive_utils.dart';

class CbvStatisticsHeader extends StatelessWidget {
  const CbvStatisticsHeader({
    super.key,
    required this.state,
  });

  final AdminCbvVocabularyState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = TraqSpacing.md;

        final isMobile = constraints.maxWidth < 700;

        final cardWidth = isMobile
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                title: 'Biz Steps',
                total: state.totalBizSteps,
                enabled: state.enabledBizSteps,
                disabled: state.disabledBizSteps,
                icon: Icons.account_tree_outlined,
                color: colors.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                title: 'Dispositions',
                total: state.totalDispositions,
                enabled: state.enabledDispositions,
                disabled: state.disabledDispositions,
                icon: Icons.label_outline,
                color: colors.secondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.total,
    required this.enabled,
    required this.disabled,
    required this.icon,
    required this.color,
  });

  final String title;
  final int total;
  final int enabled;
  final int disabled;
  final IconData icon;
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
                Icon(icon, color: color, size: 20),
                const SizedBox(width: TraqSpacing.sm),
                Text(
                  title,
                  style: context.text.h3.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: TraqSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: 'Total',
                    value: total,
                    color: colors.textPrimary,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Enabled',
                    value: enabled,
                    color: colors.success,
                  ),
                ),
                Expanded(
                  child: _Stat(
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

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: context.text.h2.copyWith(color: color),
        ),
        Text(
          label,
          style: context.text.bodySm.copyWith(color: context.colors.textMuted),
        ),
      ],
    );
  }
}
