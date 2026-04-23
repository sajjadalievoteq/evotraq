import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';

import '../../users/widgets/user_management_constants.dart';

class UserApprovalCard extends StatelessWidget {
  const UserApprovalCard({
    super.key,
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  final UserResponse user;
  final ValueChanged<UserResponse> onApprove;
  final ValueChanged<UserResponse> onReject;

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
                    CircleAvatar(
                      backgroundColor: AppTheme.accentColor,
                      child: Text(
                        user.firstName.isNotEmpty
                            ? user.firstName.characters.first.toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Username: ${user.username}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email: ${user.email}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (compact) ...[
                  Text(
                    '${UserManagementConstants.registeredOnLabel}: ${_registeredDate}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: UserManagementConstants.spacing,
                    runSpacing: UserManagementConstants.spacing,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 50,
                        child: CustomOutlinedButtonWidget(
                          title: UserManagementConstants.rejectLabel,
                          onTap: () => onReject(user),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        height: 50,
                        child: CustomButtonWidget(
                          onTap: () => onApprove(user),
                          title: UserManagementConstants.approveLabel,
                          icon: Icons.check_circle,
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${UserManagementConstants.registeredOnLabel}: ${_registeredDate}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                      ),
                      const SizedBox(width: UserManagementConstants.spacing),
                      SizedBox(
                        width: 150,
                        child: CustomOutlinedButtonWidget(
                          title: UserManagementConstants.rejectLabel,
                          onTap: () => onReject(user),
                        ),
                      ),
                      const SizedBox(width: UserManagementConstants.spacing),
                      SizedBox(
                        width: 150,
                        child: CustomButtonWidget(
                          onTap: () => onApprove(user),
                          title: UserManagementConstants.approveLabel,
                          icon: Icons.check_circle,
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                        ),
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

  String get _displayName {
    final fullName = '${user.firstName} ${user.lastName}'.trim();
    return fullName.isEmpty ? user.username : fullName;
  }

  String get _registeredDate {
    if (!user.createdAt.contains('T')) {
      return user.createdAt;
    }
    return user.createdAt.split('T').first;
  }
}
