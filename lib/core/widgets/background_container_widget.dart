import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/utils/drawer_scroll_memory.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class BackgroundContainerWidget extends StatelessWidget {
  const BackgroundContainerWidget({
    super.key,
    required this.child,
    this.showAppBar = false,
    this.appBarTitle,
    this.showDrawer,
  });
  final Widget child;
  final bool showAppBar;
  final String? appBarTitle;
  final bool? showDrawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? TraqAppBar(
              context,
              title: Text(appBarTitle ?? ''),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const TraqIcon(AppAssets.iconMenu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            )
          : null,
      drawer: showDrawer == true ? const AppDrawer() : null,
      onDrawerChanged: showDrawer == true
          ? (isOpen) {
              if (isOpen) DrawerScrollMemory.notifyDrawerOpened();
            }
          : null,
      body: child,
    );
  }
}
