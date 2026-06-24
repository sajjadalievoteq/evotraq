import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_approval/utils/user_approval_user_formatters.dart';

class UserApprovalCardAvatar extends StatelessWidget {
  const UserApprovalCardAvatar({super.key, required this.user});

  final UserResponse user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.colors.textSecondary,
      child: Text(
        userApprovalAvatarInitial(user),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
