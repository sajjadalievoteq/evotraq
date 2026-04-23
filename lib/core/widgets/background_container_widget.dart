import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';

/// Full-screen background (image + light overlay). Use behind the navigator in
/// [MaterialApp.router] `builder` so every route shares the same backdrop.
class AppBackgroundLayer extends StatelessWidget {
  const AppBackgroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Constants.loginBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: ColoredBox(
        color: Colors.black.withOpacity(0.05),
      ),
    );
  }
}

/// Optional scaffold shell (app bar / drawer) on top of the global background.
/// The decorative image is provided by [AppBackgroundLayer] in `main.dart`.
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
      backgroundColor: Colors.transparent,
      appBar: showAppBar
          ? AppBar(
              title: Text(appBarTitle ?? ''),
              backgroundColor: ColorManager.primary(context),
              foregroundColor: Colors.white,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            )
          : null,
      drawer: showDrawer == true ? const AppDrawer() : null,
      body: child,
    );
  }
}
