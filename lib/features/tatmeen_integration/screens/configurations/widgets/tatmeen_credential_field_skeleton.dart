part of 'tatmeen_credentials_form.dart';

class TatmeenCredentialFieldSkeleton extends StatelessWidget {
  const TatmeenCredentialFieldSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(
      height: 56,
      radius: 4,
      color: AppShimmer.defaultBaseColor(context),
    );
  }
}
