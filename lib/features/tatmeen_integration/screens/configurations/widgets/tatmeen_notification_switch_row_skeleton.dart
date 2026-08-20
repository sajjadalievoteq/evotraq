part of 'tatmeen_notifications_settings.dart';

class TatmeenNotificationSwitchRowSkeleton extends StatelessWidget {
  const TatmeenNotificationSwitchRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.45,
                  child: AppSkeletonBox(height: 14, color: muted),
                ),
                const SizedBox(height: TraqSpacing.xs),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.7,
                  child: AppSkeletonBox(height: 12, color: muted),
                ),
              ],
            ),
          ),
          AppSkeletonBox(width: 52, height: 28, radius: 14, color: muted),
        ],
      ),
    );
  }
}
