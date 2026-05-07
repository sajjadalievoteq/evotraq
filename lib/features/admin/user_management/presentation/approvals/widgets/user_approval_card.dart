import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';

import '../../../../../../core/consts/app_consts.dart';
import '../../users/widgets/user_management_constants.dart';

enum UserApprovalCardVariant {
  list,
  gridSquare,
}

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
    if (variant == UserApprovalCardVariant.gridSquare) {
      return _GridSquareApprovalCard(
        user: user,
        onApprove: onApprove,
        onReject: onReject,
      );
    }

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
                    spacing: Constants.spacing,
                    runSpacing: Constants.spacing,
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
                      const SizedBox(width:Constants.spacing),
                      SizedBox(
                        width: 150,
                        child: CustomOutlinedButtonWidget(
                          title: UserManagementConstants.rejectLabel,
                          onTap: () => onReject(user),
                        ),
                      ),
                      const SizedBox(width: Constants.spacing),
                      SizedBox(
                        width: 150,
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

class _GridSquareApprovalCard extends StatelessWidget {
  const _GridSquareApprovalCard({
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  final UserResponse user;
  final ValueChanged<UserResponse> onApprove;
  final ValueChanged<UserResponse> onReject;

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

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.textSecondary,
                  child: Text(
                    user.firstName.isNotEmpty
                        ? user.firstName.characters.first.toUpperCase()
                        : 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall?.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${UserManagementConstants.registeredOnLabel}: $_registeredDate',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: CustomOutlinedButtonWidget(
                      title: UserManagementConstants.rejectLabel,
                      onTap: () => onReject(user),
                    ),
                  ),
                ),
                const SizedBox(width: Constants.spacing),
                Expanded(
                  child: SizedBox(
                    height: 40,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
