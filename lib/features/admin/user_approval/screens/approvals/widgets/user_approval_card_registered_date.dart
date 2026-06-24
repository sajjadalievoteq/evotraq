import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_approval/utils/user_approval_constants.dart';
import 'package:traqtrace_app/features/admin/user_approval/utils/user_approval_user_formatters.dart';

class UserApprovalCardRegisteredDate extends StatelessWidget {
  const UserApprovalCardRegisteredDate({super.key, required this.user});

  final UserResponse user;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${UserApprovalConstants.registeredOnLabel}: ${userApprovalRegisteredDate(user)}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[700],
          ),
    );
  }
}
