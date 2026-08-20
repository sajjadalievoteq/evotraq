part of 'tatmeen_notifications_settings.dart';

class TatmeenNotificationsSkeleton extends StatelessWidget {
  const TatmeenNotificationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSkeletonBox(width: 140, height: 18, color: muted),
          const SizedBox(height: TraqSpacing.sm),
          AppSkeletonBox(width: double.infinity, height: 12, color: muted),
          const SizedBox(height: TraqSpacing.sm),
          const TatmeenNotificationSwitchRowSkeleton(),
          const TatmeenNotificationSwitchRowSkeleton(),
          const TatmeenNotificationSwitchRowSkeleton(),
          const SizedBox(height: TraqSpacing.md),
          AppSkeletonBox(width: 110, height: 14, color: muted),
          const SizedBox(height: TraqSpacing.sm),
          Wrap(
            spacing: TraqSpacing.xs,
            children: [
              AppSkeletonBox(width: 140, height: 28, radius: 14, color: muted),
              AppSkeletonBox(width: 160, height: 28, radius: 14, color: muted),
              AppSkeletonBox(width: 120, height: 28, radius: 14, color: muted),
            ],
          ),
        ],
      ),
    );
  }
}
