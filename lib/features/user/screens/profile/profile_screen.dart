import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/user/cubit/profile_cubit.dart';
import 'package:traqtrace_app/features/user/cubit/profile_state.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_info_module.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_preferences_module.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_screen_loaded_scaffold.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_screen_loading_scaffold.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_security_module.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';
import 'package:traqtrace_app/features/user/utils/user_ui_constants.dart';
import 'package:traqtrace_app/features/user/widgets/user_section_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktopWide =
                    constraints.maxWidth >= UserUiConstants.desktopBreakpoint;
                final padding = ResponsiveUtils.paddingAll(context);

                final user = profileState.user ?? authState.user;
                if (user == null) {
                  return ProfileScreenLoadingScaffold(
                    isDesktopWide: isDesktopWide,
                    padding: padding,
                  );
                }

                final infoModule = UserSectionCard(
                  title: UserStrings.infoTitle,
                  child: ProfileInfoModule(user: user),
                );
                const securityModule = UserSectionCard(
                  title: UserStrings.securityTitle,
                  child: ProfileSecurityModule(),
                );
                const preferencesModule = UserSectionCard(
                  title: UserStrings.preferencesTitle,
                  child: ProfilePreferencesModule(),
                );

                return ProfileScreenLoadedScaffold(
                  user: user,
                  isDesktopWide: isDesktopWide,
                  infoModule: infoModule,
                  securityModule: securityModule,
                  preferencesModule: preferencesModule,
                );
              },
            );
          },
        );
      },
    );
  }
}
