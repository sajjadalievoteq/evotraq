import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approval_card_actions_compact.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approval_card_actions_row.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approval_card_avatar.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approval_card_registered_date.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approval_card_user_info.dart';

enum UserApprovalCardVariant { list, gridSquare }

class UserApprovalCard extends StatelessWidget {
  const UserApprovalCard({
    super.key,
    required this.user,
    required this.onApprove,
    required this.onReject,
    this.variant = UserApprovalCardVariant.list,
  });

  final UserResponse user;
  final ValueChanged<UserResponse> onApprove;
  final ValueChanged<UserResponse> onReject;
  final UserApprovalCardVariant variant;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserApprovalCardAvatar(user: user),
                    const SizedBox(width: 16),
                    Expanded(child: UserApprovalCardUserInfo(user: user)),
                  ],
                ),
                const SizedBox(height: 16),
                if (compact) ...[
                  UserApprovalCardRegisteredDate(user: user),
                  const SizedBox(height: 12),
                  UserApprovalCardActionsCompact(
                    user: user,
                    onApprove: onApprove,
                    onReject: onReject,
                  ),
                ] else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserApprovalCardRegisteredDate(user: user),
                      const SizedBox(height: Constants.spacing),
                      UserApprovalCardActionsRow(
                        user: user,
                        onApprove: onApprove,
                        onReject: onReject,
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
