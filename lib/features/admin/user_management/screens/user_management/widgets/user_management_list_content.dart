import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_user_card.dart';
import 'package:traqtrace_app/features/admin/user_management/utils/user_management_constants.dart';

class UserManagementListContent extends StatelessWidget {
  const UserManagementListContent({
    super.key,
    required this.users,
    required this.togglingUserId,
    required this.onEditUser,
    required this.onToggleStatus,
  });

  final List<UserResponse> users;
  final int? togglingUserId;
  final ValueChanged<UserResponse> onEditUser;
  final ValueChanged<UserResponse> onToggleStatus;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          UserManagementConstants.noUsersFound,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      );
    }

    final g = context.gutter;

    return ListView.separated(
      padding: EdgeInsets.all(g),
      physics: const ClampingScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => SizedBox(height: g),
      itemBuilder: (context, index) {
        final user = users[index];
        return UserManagementUserCard(
          user: user,
          isToggleLoading: togglingUserId == user.id,
          onEdit: onEditUser,
          onToggleStatus: onToggleStatus,
          variant: UserManagementUserCardVariant.listTile,
        );
      },
    );
  }
}
