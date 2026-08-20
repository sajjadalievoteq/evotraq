part of 'tatmeen_credentials_form.dart';

class TatmeenCredentialsSkeleton extends StatelessWidget {
  const TatmeenCredentialsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSkeletonBox(width: 120, height: 18, color: muted),
          const SizedBox(height: TraqSpacing.sm),
          AppSkeletonBox(width: double.infinity, height: 12, color: muted),
          const SizedBox(height: TraqSpacing.md),
          const TatmeenCredentialFieldSkeleton(),
          const SizedBox(height: TraqSpacing.md),
          const TatmeenCredentialFieldSkeleton(),
          const SizedBox(height: TraqSpacing.md),
          const TatmeenCredentialFieldSkeleton(),
          const SizedBox(height: TraqSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: AppSkeletonBox(
              width: 150,
              height: 40,
              radius: 8,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}
