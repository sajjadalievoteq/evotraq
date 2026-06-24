import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_info_module.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_preferences_module.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_security_module.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';
import 'package:traqtrace_app/features/user/widgets/user_section_card.dart';

class ProfileScreenDesktopBody extends StatelessWidget {
  const ProfileScreenDesktopBody({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: ResponsiveUtils.paddingAll(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: [
            Expanded(
              child: UserSectionCard(
                title: UserStrings.infoTitle,
                child: ProfileInfoModule(user: user),
              ),
            ),
            const Expanded(
              child: UserSectionCard(
                title: UserStrings.securityTitle,
                child: ProfileSecurityModule(),
              ),
            ),
            const Expanded(
              child: UserSectionCard(
                title: UserStrings.preferencesTitle,
                child: ProfilePreferencesModule(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
