import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/app_drawer_navigation_icon.dart';

class AppDrawerOperationItem extends StatelessWidget {
  const AppDrawerOperationItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.onNavigate,
    super.key,
  });

  final String icon;
  final String label;
  final String route;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32),
      leading: AppDrawerNavigationIcon(icon),
      title: Text(label),
      onTap: () => onNavigate(route),
    );
  }
}
