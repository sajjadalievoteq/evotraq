import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_user_actions.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_user_avatar.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_user_details.dart';

class UserManagementUserListCard extends StatelessWidget {
  const UserManagementUserListCard({
    super.key,
    required this.user,
    required this.isToggleLoading,
    required this.onEdit,
    required this.onToggleStatus,
  });

  final UserResponse user;
  final bool isToggleLoading;
  final ValueChanged<UserResponse> onEdit;
  final ValueChanged<UserResponse> onToggleStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final details = UserManagementUserDetails(
              user: user,
              density: UserManagementUserDetailsDensity.comfy,
            );
            final actions = UserManagementUserActions(
              user: user,
              isToggleLoading: isToggleLoading,
              onEdit: onEdit,
              onToggleStatus: onToggleStatus,
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserManagementUserAvatar(
                        initial: userManagementResolveInitial(user.firstName),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: details),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: actions),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserManagementUserAvatar(
                  initial: userManagementResolveInitial(user.firstName),
                ),
                const SizedBox(width: 16),
                Expanded(child: details),
                const SizedBox(width: 16),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}
