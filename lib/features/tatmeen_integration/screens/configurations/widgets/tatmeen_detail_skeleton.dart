import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_credentials_form.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_notifications_settings.dart';

class TatmeenDetailSkeleton extends StatelessWidget {
  const TatmeenDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: context.colors.border),
      ),
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSkeletonBox(
                    width: double.infinity,
                    height: 12,
                    color: muted,
                  ),
                  const SizedBox(height: TraqSpacing.xs),
                  AppSkeletonBox(width: 280, height: 12, color: muted),
                  const SizedBox(height: TraqSpacing.md),
                  Row(
                    children: [
                      AppSkeletonBox(width: 90, height: 16, color: muted),
                      const Spacer(),
                      AppSkeletonBox(width: 28, height: 14, color: muted),
                      const SizedBox(width: TraqSpacing.xs),
                      AppSkeletonBox(
                        width: 52,
                        height: 28,
                        radius: 14,
                        color: muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: TraqSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppSkeletonBox(
                      width: 160,
                      height: 28,
                      radius: 14,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TraqSpacing.md),
            TatmeenCredentialsForm(
              settings: null,
              canUpdate: false,
              busy: false,
              isLoading: true,
              onSave: (_) async => false,
              onRemovePassword: () async {},
              onRemoveApiKey: () async {},
            ),
            const SizedBox(height: TraqSpacing.lg),
            AppShimmer(
              child: AppSkeletonBox(
                width: double.infinity,
                height: 40,
                radius: 8,
                color: muted,
              ),
            ),
            const SizedBox(height: TraqSpacing.lg),
            const TatmeenNotificationsSettings(
              canUpdate: false,
              isLoading: true,
            ),
          ],
        ),
      ),
    );
  }
}
