import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/user/presentation/widgets/responsive_modules_row.dart';
import 'package:traqtrace_app/features/user/presentation/widgets/profile_info_module.dart';
import 'package:traqtrace_app/features/user/presentation/widgets/profile_security_module.dart';
import 'package:traqtrace_app/features/user/presentation/widgets/profile_preferences_module.dart';
import 'package:traqtrace_app/features/user/presentation/widgets/profile_screen_loading_shimmer.dart';
import 'package:traqtrace_app/features/user/presentation/widgets/user_section_card.dart';
import 'package:traqtrace_app/features/user/utils/user_ui_constants.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';

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
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopWide =
                constraints.maxWidth >= UserUiConstants.desktopBreakpoint;
            final padding = ResponsiveUtils.paddingAll(context);

            final user = authState.user;
            if (user == null) {
              return Scaffold(
                appBar: TraqAppBar(
                  context,
                  title: const Text(UserStrings.profileManagementTitle),
                  centerTitle: true,
                ),
                drawer: const AppDrawer(),
                body: ProfileScreenLoadingShimmer(
                  isDesktopWide: isDesktopWide,
                  padding: padding,
                ),
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

            final modules = [infoModule, securityModule, preferencesModule];

            return Scaffold(
              appBar: TraqAppBar(
                context,
                title: const Text(UserStrings.profileManagementTitle),
                centerTitle: false,
              ),
              drawer: const AppDrawer(),
              body: isDesktopWide
                  ? SizedBox(
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

                            Expanded(
                              child: UserSectionCard(
                                title: UserStrings.securityTitle,
                                child: ProfileSecurityModule(),
                              ),
                            ),

                            Expanded(
                              child: UserSectionCard(
                                title: UserStrings.preferencesTitle,
                                child: ProfilePreferencesModule(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          TabBar(
                            labelPadding: EdgeInsets.zero,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: const [
                              Tab(text: UserStrings.infoTitle),
                              Tab(text: UserStrings.securityTitle),
                              Tab(text: UserStrings.preferencesTitle),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                Padding(
                                  padding: ResponsiveUtils.paddingAll(context),
                                  child: infoModule,
                                ),
                                Padding(
                                  padding: ResponsiveUtils.paddingAll(context),
                                  child: securityModule,
                                ),
                                Padding(
                                  padding: ResponsiveUtils.paddingAll(context),
                                  child: preferencesModule,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}
