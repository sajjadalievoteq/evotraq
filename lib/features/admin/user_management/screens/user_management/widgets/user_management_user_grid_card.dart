import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_user_actions.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_user_avatar.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_user_details.dart';

class UserManagementUserGridCard extends StatelessWidget {
  const UserManagementUserGridCard({
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
    final actions = UserManagementUserActions(
      user: user,
      isToggleLoading: isToggleLoading,
      onEdit: onEdit,
      onToggleStatus: onToggleStatus,
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                UserManagementUserAvatar(
                  initial: userManagementResolveInitial(user.firstName),
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ('${user.firstName} ${user.lastName}').trim().isEmpty
                        ? user.username
                        : ('${user.firstName} ${user.lastName}').trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            UserManagementUserDetails(
              user: user,
              density: UserManagementUserDetailsDensity.compact,
            ),
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerRight, child: actions),
          ],
        ),
      ),
    );
  }
}
