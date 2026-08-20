part of 'tatmeen_error_summary.dart';

class TatmeenErrorSummarySkeleton extends StatelessWidget {
  const TatmeenErrorSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: Column(
        children: List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
            child: Row(
              children: [
                Expanded(child: AppSkeletonBox(height: 16, color: muted)),
                const SizedBox(width: TraqSpacing.sm),
                AppSkeletonBox(width: 36, height: 22, radius: 12, color: muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
