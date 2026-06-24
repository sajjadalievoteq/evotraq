import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_screen_loading_shimmer.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';

class ProfileScreenLoadingScaffold extends StatelessWidget {
  const ProfileScreenLoadingScaffold({
    super.key,
    required this.isDesktopWide,
    required this.padding,
  });

  final bool isDesktopWide;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
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
}
