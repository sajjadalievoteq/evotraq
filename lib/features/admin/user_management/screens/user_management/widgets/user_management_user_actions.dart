import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';

class UserManagementUserActions extends StatelessWidget {
  const UserManagementUserActions({
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: const EdgeInsets.all(1),
          icon: SvgPicture.asset(
            AppAssets.iconEdit,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color ??
                  Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
          tooltip: 'Edit User',
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onEdit(user);
            });
          },
        ),
        Switch.adaptive(
          value: user.enabled,
          onChanged: isToggleLoading ? null : (_) => onToggleStatus(user),
        ),
      ],
    );
  }
}
