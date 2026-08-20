part of 'tatmeen_stats_row.dart';

class TatmeenStatsSkeleton extends StatelessWidget {
  const TatmeenStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = AppShimmer.defaultBaseColor(context);
    final width = _tatmeenKpiCardWidth(context);
    return AppShimmer(
      child: Wrap(
        spacing: TraqSpacing.md,
        runSpacing: TraqSpacing.md,
        alignment: WrapAlignment.spaceBetween,
        children: List.generate(
          4,
          (_) => SizedBox(
            width: width,
            child: TraqCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppSkeletonBox(
                        width: 18,
                        height: 18,
                        radius: 9,
                        color: base,
                      ),
                      const SizedBox(width: TraqSpacing.xs),
                      Expanded(
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.6,
                          child: AppSkeletonBox(height: 14, color: base),
                        ),
                      ),
                      AppSkeletonBox(
                        width: 14,
                        height: 14,
                        radius: 4,
                        color: base,
                      ),
                    ],
                  ),
                  const SizedBox(height: TraqSpacing.sm),
                  AppSkeletonBox(width: 96, height: 28, color: base),
                  const SizedBox(height: TraqSpacing.xs),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.4,
                    child: AppSkeletonBox(height: 12, color: base),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
