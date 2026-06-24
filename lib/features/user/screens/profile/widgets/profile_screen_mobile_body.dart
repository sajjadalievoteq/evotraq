import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';

class ProfileScreenMobileBody extends StatelessWidget {
  const ProfileScreenMobileBody({
    super.key,
    required this.infoModule,
    required this.securityModule,
    required this.preferencesModule,
  });

  final Widget infoModule;
  final Widget securityModule;
  final Widget preferencesModule;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: UserStrings.infoTitle),
              Tab(text: UserStrings.securityTitle),
              Tab(text: UserStrings.preferencesTitle),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
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
    );
  }
}
