import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';

class BackgroundContainerWidget extends StatelessWidget {
  final Widget child;
  final bool? showAppBar;
  final String? appBarTitle;
  final bool? showDrawer;

  const BackgroundContainerWidget({
    super.key,
    required this.child, this.showAppBar=false, this.appBarTitle, this.showDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ==true
          ? AppBar(
        title: Text(appBarTitle??''),
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
      drawer: showDrawer==true? AppDrawer():null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Constants.loginBackground),
            fit: BoxFit.cover,
          ),
        ),
        // Overlay a slight dimming if needed
        child: Container(
          color: Colors.black.withOpacity(0.05),
          child: child,
        ),
      ),
    );
  }
}
