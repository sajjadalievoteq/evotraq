part of 'tatmeen_status_breakdown.dart';

class TatmeenStatusBreakdownSkeleton extends StatelessWidget {
  const TatmeenStatusBreakdownSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          final chart = AppSkeletonBox(
            width: 200,
            height: 200,
            radius: 100,
            color: muted,
          );
          final legend = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
                child: Row(
                  children: [
                    AppSkeletonBox(
                      width: 10,
                      height: 10,
                      radius: 5,
                      color: muted,
                    ),
                    const SizedBox(width: TraqSpacing.xs),
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.55,
                        child: AppSkeletonBox(height: 12, color: muted),
                      ),
                    ),
                    AppSkeletonBox(width: 40, height: 12, color: muted),
                  ],
                ),
              ),
            ),
          );
          if (compact) {
            return Column(
              children: [
                chart,
                const SizedBox(height: TraqSpacing.md),
                legend,
              ],
            );
          }
          return Row(
            children: [
              chart,
              const SizedBox(width: TraqSpacing.md),
              Expanded(child: legend),
            ],
          );
        },
      ),
    );
  }
}
