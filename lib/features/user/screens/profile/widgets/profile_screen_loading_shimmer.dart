import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_info_skeleton.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_preferences_skeleton.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_security_skeleton.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';
import 'package:traqtrace_app/features/user/widgets/responsive_modules_row.dart';
import 'package:traqtrace_app/features/user/widgets/user_section_card.dart';

class ProfileScreenLoadingShimmer extends StatelessWidget {
  const ProfileScreenLoadingShimmer({
    super.key,
    required this.isDesktopWide,
    required this.padding,
  });

  final bool isDesktopWide;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final modules = const [
      UserSectionCard(
        title: UserStrings.infoTitle,
        child: ProfileInfoSkeleton(),
      ),
      UserSectionCard(
        title: UserStrings.securityTitle,
        child: ProfileSecuritySkeleton(),
      ),
      UserSectionCard(
        title: UserStrings.preferencesTitle,
        child: ProfilePreferencesSkeleton(),
      ),
    ];

    return AppShimmer(
      child: Align(
        alignment: isDesktopWide ? Alignment.center : Alignment.topCenter,
        child: SingleChildScrollView(
          padding: padding,
          child: isDesktopWide
              ? ResponsiveModulesRow(children: modules)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    modules[0],
                    const SizedBox(height: 16),
                    modules[1],
                    const SizedBox(height: 16),
                    modules[2],
                  ],
                ),
        ),
      ),
    );
  }
}
