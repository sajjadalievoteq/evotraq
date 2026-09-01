import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_screen_desktop_body.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_screen_mobile_body.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';

class ProfileScreenLoadedScaffold extends StatefulWidget {
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
  State<ProfileScreenLoadedScaffold> createState() =>
      _ProfileScreenLoadedScaffoldState();
}

class _ProfileScreenLoadedScaffoldState extends State<ProfileScreenLoadedScaffold>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    UserStrings.infoTitle,
    UserStrings.securityTitle,
    UserStrings.preferencesTitle,
  ];

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    if (!widget.isDesktopWide) {
      _tabController = TabController(length: _tabs.length, vsync: this);
    }
  }

  @override
  void didUpdateWidget(covariant ProfileScreenLoadedScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDesktopWide == widget.isDesktopWide) return;

    _tabController?.dispose();
    _tabController = widget.isDesktopWide
        ? null
        : TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text(UserStrings.profileManagementTitle),
        centerTitle: false,
        bottom: widget.isDesktopWide
            ? null
            : TabBar(
                controller: _tabController,
                tabs: _tabs.map((label) => Tab(text: label)).toList(),
              ),
      ),
      drawer: const AppDrawer(),
      body: widget.isDesktopWide
          ? ProfileScreenDesktopBody(user: widget.user)
          : ProfileScreenMobileBody(
              tabController: _tabController!,
              infoModule: widget.infoModule,
              securityModule: widget.securityModule,
              preferencesModule: widget.preferencesModule,
            ),
    );
  }
}
