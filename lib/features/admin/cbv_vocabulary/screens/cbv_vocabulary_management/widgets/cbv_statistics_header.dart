import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_stat_card.dart';

class CbvStatisticsHeader extends StatelessWidget {
  const CbvStatisticsHeader({super.key, required this.state});

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
              child: CbvStatCard(
                title: 'Biz Steps',
                total: state.totalBizSteps,
                enabled: state.enabledBizSteps,
                disabled: state.disabledBizSteps,
                iconAsset: NavIcons.aggregationHierarchy,
                color: colors.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: CbvStatCard(
                title: 'Dispositions',
                total: state.totalDispositions,
                enabled: state.enabledDispositions,
                disabled: state.disabledDispositions,
                iconAsset: AppAssets.iconTag,
                color: colors.secondary,
              ),
            ),
          ],
        );
      },
    );
  }
}
