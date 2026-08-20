part of 'tatmeen_sync_chart.dart';

class TatmeenChartSkeleton extends StatelessWidget {
  const TatmeenChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: SizedBox.expand(
        child: AppSkeletonBox(height: double.infinity, color: muted),
      ),
    );
  }
}
