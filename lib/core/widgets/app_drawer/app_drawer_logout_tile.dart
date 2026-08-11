import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/logout_confirm_dialog.dart';

class AppDrawerLogoutTile extends StatelessWidget {
  const AppDrawerLogoutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CustomButtonWidget(
        onTap: () {
          final router = GoRouter.of(context);
          Navigator.pop(context);
          final host = router.routerDelegate.navigatorKey.currentContext;
          showLogoutConfirmDialog(host ?? context);
        },
        title: 'Log Out',
        iconAsset: NavIcons.logout,
      ),
    );
  }
}
