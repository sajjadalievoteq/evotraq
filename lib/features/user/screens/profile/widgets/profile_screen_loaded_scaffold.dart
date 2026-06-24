import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_screen_desktop_body.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_screen_mobile_body.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';

class ProfileScreenLoadedScaffold extends StatelessWidget {
  const ProfileScreenLoadedScaffold({
    super.key,
    required this.user,
    required this.isDesktopWide,
    required this.infoModule,
    required this.securityModule,
    required this.preferencesModule,
  });

  final User user;
  final bool isDesktopWide;
  final Widget infoModule;
  final Widget securityModule;
  final Widget preferencesModule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text(UserStrings.profileManagementTitle),
        centerTitle: false,
      ),
      drawer: const AppDrawer(),
      body: isDesktopWide
          ? ProfileScreenDesktopBody(user: user)
          : ProfileScreenMobileBody(
              infoModule: infoModule,
              securityModule: securityModule,
              preferencesModule: preferencesModule,
            ),
    );
  }
}
