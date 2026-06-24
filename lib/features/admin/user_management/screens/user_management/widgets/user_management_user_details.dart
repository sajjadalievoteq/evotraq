import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_management/utils/user_management_constants.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_user_info_badge.dart';

enum UserManagementUserDetailsDensity { comfy, compact }

class UserManagementUserDetails extends StatelessWidget {
  const UserManagementUserDetails({
    super.key,
    required this.user,
    required this.density,
  });

  final UserResponse user;
  final UserManagementUserDetailsDensity density;

  @override
  Widget build(BuildContext context) {
    final name = '${user.firstName} ${user.lastName}'.trim();
    final spacingSm = density == UserManagementUserDetailsDensity.compact ? 2.0 : 4.0;
    final spacingMd = density == UserManagementUserDetailsDensity.compact ? 8.0 : 12.0;
    final colors = context.colors;

    final Color roleColor = switch (user.role) {
      'ADMIN' => Colors.purple,
      'MANUFACTURER' => colors.primary,
      'DISTRIBUTOR' => Colors.orange,
      'RETAILER' => Colors.teal,
      _ => colors.success,
    };

    final Color statusColor =
        user.enabled ? colors.success : colors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (density == UserManagementUserDetailsDensity.comfy) ...[
          Text(
            name.isEmpty ? user.username : name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: spacingSm),
          Text(
            user.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacingSm),
          Text(
            'Username: ${user.username}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
          ),
          SizedBox(height: spacingMd),
        ] else ...[
          Text(
            user.email,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: spacingMd),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            UserManagementUserInfoBadge(
              label: 'Role',
              value: user.role,
              valueColor: roleColor,
            ),
            UserManagementUserInfoBadge(
              label: 'Status',
              value: user.enabled
                  ? UserManagementConstants.activeStatus
                  : UserManagementConstants.inactiveStatus,
              valueColor: statusColor,
            ),
            if (user.approvalStatus == UserManagementConstants.pendingStatus)
              UserManagementUserInfoBadge(
                label: 'Approval',
                value: UserManagementConstants.pendingStatus,
                valueColor: Colors.orange.shade800,
              ),
          ],
        ),
      ],
    );
  }
}

String userManagementResolveInitial(String firstName) {
  if (firstName.isEmpty) return 'U';
  return firstName.characters.first.toUpperCase();
}
