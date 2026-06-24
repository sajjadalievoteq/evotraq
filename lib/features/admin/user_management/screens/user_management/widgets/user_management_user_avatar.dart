import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class UserManagementUserAvatar extends StatelessWidget {
  const UserManagementUserAvatar({
    super.key,
    required this.initial,
    this.radius = 20,
  });

  final String initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.colors.textSecondary,
      radius: radius,
      child: Text(initial, style: const TextStyle(color: Colors.white)),
    );
  }
}
