import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class TatmeenActivityRowsSkeleton extends StatelessWidget {
  const TatmeenActivityRowsSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...List.generate(5, (_) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
              child: Row(
                children: [
                  AppSkeletonBox(
                    width: 18,
                    height: 18,
                    radius: 9,
                    color: muted,
                  ),
                  const SizedBox(width: TraqSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.72,
                          child: AppSkeletonBox(height: 14, color: muted),
                        ),
                        const SizedBox(height: TraqSpacing.xs),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.45,
                          child: AppSkeletonBox(height: 12, color: muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: TraqSpacing.sm),
                  AppSkeletonBox(width: 72, height: 12, color: muted),
                ],
              ),
            );
          }),
          Align(
            alignment: Alignment.centerRight,
            child: AppSkeletonBox(
              width: 72,
              height: 32,
              radius: 8,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}
