import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';

import '../../../../../../core/consts/app_consts.dart';
import '../../users/widgets/user_management_constants.dart';

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
                    CircleAvatar(
                      backgroundColor: context.colors.textSecondary,
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Username: ${user.username}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email: ${user.email}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[700]),
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                 Column(
                    spacing: Constants.spacing,
                    children: [
                      SizedBox(

                        width: double.infinity,
                        child: CustomOutlinedButtonWidget(
                          title: UserManagementConstants.rejectLabel,
                          onTap: () => onReject(user),
                        ),
                      ),
                      SizedBox(

                        width: double.infinity,
                        child: CustomButtonWidget(
                          onTap: () => onApprove(user),
                          title: UserManagementConstants.approveLabel,
                          iconWidget: SvgPicture.asset(
                            AppAssets.iconCheck,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          backgroundColor: context.colors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${UserManagementConstants.registeredOnLabel}: ${_registeredDate}',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: Constants.spacing),
                      Row(
                        children: [
                          Expanded(
                            child: CustomOutlinedButtonWidget(
                              title: UserManagementConstants.rejectLabel,
                              onTap: () => onReject(user),
                            ),
                          ),
                          const SizedBox(width: Constants.spacing),
                          Expanded(
                            child: CustomButtonWidget(
                              onTap: () => onApprove(user),
                              title: UserManagementConstants.approveLabel,
                              iconWidget: SvgPicture.asset(
                                AppAssets.iconCheck,
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              backgroundColor: context.colors.success,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
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

