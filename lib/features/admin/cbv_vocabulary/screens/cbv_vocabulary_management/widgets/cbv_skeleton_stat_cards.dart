import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_skeleton_stat_card.dart';

class CbvSkeletonStatCards extends StatelessWidget {
  const CbvSkeletonStatCards({required this.base, super.key});

  final Color base;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final cardWidth = isMobile
            ? constraints.maxWidth
            : (constraints.maxWidth - TraqSpacing.md) / 2;
        return Wrap(
          spacing: TraqSpacing.md,
          runSpacing: TraqSpacing.md,
          children: [
            SizedBox(
              width: cardWidth,
              child: CbvSkeletonStatCard(base: base),
            ),
            SizedBox(
              width: cardWidth,
              child: CbvSkeletonStatCard(base: base),
            ),
          ],
        );
      },
    );
  }
}
