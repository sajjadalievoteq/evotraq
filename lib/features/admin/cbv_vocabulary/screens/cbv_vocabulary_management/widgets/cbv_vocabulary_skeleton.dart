import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_skeleton_pairing_row.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_skeleton_stat_cards.dart';

class CbvVocabularySkeleton extends StatelessWidget {
  const CbvVocabularySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = AppShimmer.defaultBaseColor(context);
    final horizontalPadding = context.padding.left;
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: context.padding.top),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CbvSkeletonStatCards(base: base),
              const SizedBox(height: TraqSpacing.lg),
              SkeletonBox(base, height: 44, radius: 8),
              const SizedBox(height: TraqSpacing.md),
              Row(
                children: [
                  SkeletonBox(base, width: 80, height: 20, radius: 4),
                  const SizedBox(width: TraqSpacing.xl),
                  SkeletonBox(base, width: 80, height: 20, radius: 4),
                  const SizedBox(width: TraqSpacing.xl),
                  SkeletonBox(base, width: 100, height: 20, radius: 4),
                ],
              ),
              const Divider(height: TraqSpacing.xl),
              for (var index = 0; index < 10; index++) ...[
                CbvSkeletonPairingRow(base: base, chipCount: 2 + (index % 4)),
                const Divider(height: 1),
              ],
              const SizedBox(height: TraqSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
