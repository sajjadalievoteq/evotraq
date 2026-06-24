import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_user_grid_card.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_user_list_card.dart';

enum UserManagementUserCardVariant { listTile, gridSquare }

class UserManagementUserCard extends StatelessWidget {
  const UserManagementUserCard({
    super.key,
    required this.user,
    this.isToggleLoading = false,
    required this.onEdit,
    required this.onToggleStatus,
    this.variant = UserManagementUserCardVariant.listTile,
  });

  final UserResponse user;
  final bool isToggleLoading;
  final ValueChanged<UserResponse> onEdit;
  final ValueChanged<UserResponse> onToggleStatus;
  final UserManagementUserCardVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      UserManagementUserCardVariant.listTile => UserManagementUserListCard(
          user: user,
          isToggleLoading: isToggleLoading,
          onEdit: onEdit,
          onToggleStatus: onToggleStatus,
        ),
      UserManagementUserCardVariant.gridSquare => UserManagementUserGridCard(
          user: user,
          isToggleLoading: isToggleLoading,
          onEdit: onEdit,
          onToggleStatus: onToggleStatus,
        ),
    };
  }
}
