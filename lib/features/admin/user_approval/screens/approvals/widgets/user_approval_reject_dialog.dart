import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_approval/utils/user_approval_constants.dart';
import 'package:traqtrace_app/features/admin/user_approval/utils/user_approval_user_formatters.dart';

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
    final displayName = userApprovalDisplayName(user);

    return AlertDialog(
      title: const Text(UserApprovalConstants.rejectDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to reject $displayName\'s registration?',
          ),
          const SizedBox(height: 16),
          const Text(UserApprovalConstants.rejectDialogActionSummary),
          const SizedBox(height: 8),
          const Text('• ${UserApprovalConstants.rejectActionOne}'),
          const Text('• ${UserApprovalConstants.rejectActionTwo}'),
          const Text('• ${UserApprovalConstants.rejectActionThree}'),
        ],
      ),
      actions: [
        CustomTextButtonWidget(
          title: UserApprovalConstants.cancelLabel,
          onTap: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text(
            UserApprovalConstants.rejectLabel,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
