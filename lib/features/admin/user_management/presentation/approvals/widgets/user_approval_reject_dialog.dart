import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

import '../../users/widgets/user_management_constants.dart';

class UserApprovalRejectDialog extends StatelessWidget {
  const UserApprovalRejectDialog({
    super.key,
    required this.user,
    required this.onConfirm,
  });

  final UserResponse user;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final fullName = '${user.firstName} ${user.lastName}'.trim();

    return AlertDialog(
      title: const Text(UserManagementConstants.rejectDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to reject ${fullName.isEmpty ? user.username : fullName}\'s registration?',
          ),
          const SizedBox(height: 16),
          const Text(UserManagementConstants.rejectDialogActionSummary),
          const SizedBox(height: 8),
          const Text('• ${UserManagementConstants.rejectActionOne}'),
          const Text('• ${UserManagementConstants.rejectActionTwo}'),
          const Text('• ${UserManagementConstants.rejectActionThree}'),
        ],
      ),
      actions: [
        CustomTextButtonWidget(
          title: UserManagementConstants.cancelLabel,
          onTap: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text(
            UserManagementConstants.rejectLabel,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
