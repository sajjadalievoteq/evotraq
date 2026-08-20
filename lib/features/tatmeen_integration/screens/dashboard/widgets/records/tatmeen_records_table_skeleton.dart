import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_widgets.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class TatmeenRecordsTableSkeleton extends StatelessWidget {
  const TatmeenRecordsTableSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: context.gutter),
        itemCount: 8,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: context.colors.border),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              TraqSpacing.lg,
              0,
              index == 7 ? context.gutter : 0,
            ),
            child: TraqCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeletonBox(width: 140, height: 12, color: muted),
                          const SizedBox(height: TraqSpacing.xs),
                          AppSkeletonBox(width: 180, height: 14, color: muted),
                          const SizedBox(height: TraqSpacing.xs),
                          AppSkeletonBox(width: 120, height: 12, color: muted),
                          const SizedBox(height: TraqSpacing.xs),
                          AppSkeletonBox(width: 160, height: 12, color: muted),
                          const SizedBox(height: TraqSpacing.xs),
                          AppSkeletonBox(
                            width: double.infinity,
                            height: 12,
                            color: muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: TraqSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppSkeletonBox(
                          width: 72,
                          height: 24,
                          radius: 12,
                          color: muted,
                        ),
                        const SizedBox(height: TraqSpacing.lg),
                        AppSkeletonBox(
                          width: 72,
                          height: 36,
                          radius: 8,
                          color: muted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
