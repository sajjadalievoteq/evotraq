import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';

import 'user_management_constants.dart';
import 'user_status_toggle_button.dart';

class UserManagementUserCard extends StatelessWidget {
  const UserManagementUserCard({
    super.key,
    required this.user,
    this.isToggleLoading = false,
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
            final details = _UserDetails(user: user);
            final actions = _UserActions(
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
                      _UserAvatar(initial: _resolveInitial(user.firstName)),
                      const SizedBox(width: 12),
                      Expanded(child: details),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: actions,
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserAvatar(initial: _resolveInitial(user.firstName)),
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

  String _resolveInitial(String firstName) {
    if (firstName.isEmpty) {
      return 'U';
    }
    return firstName.characters.first.toUpperCase();
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppTheme.accentColor,
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class _UserDetails extends StatelessWidget {
  const _UserDetails({required this.user});

  final UserResponse user;

  @override
  Widget build(BuildContext context) {
    final name = '${user.firstName} ${user.lastName}'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isEmpty ? user.username : name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(user.email),
        const SizedBox(height: 4),
        Text(
          'Username: ${user.username}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              label: user.role,
              backgroundColor: _roleBackgroundColor(user.role),
              foregroundColor: _roleForegroundColor(user.role),
            ),
            _StatusChip(
              label: user.enabled
                  ? UserManagementConstants.activeStatus
                  : UserManagementConstants.inactiveStatus,
              backgroundColor: user.enabled
                  ? AppTheme.successColor.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.18),
              foregroundColor:
                  user.enabled ? AppTheme.successColor : Colors.grey[800]!,
            ),
            if (user.approvalStatus == UserManagementConstants.pendingStatus)
              _StatusChip(
                label: UserManagementConstants.pendingStatus,
                backgroundColor: AppTheme.warningColor.withValues(alpha: 0.15),
                foregroundColor: AppTheme.warningColor,
              ),
          ],
        ),
      ],
    );
  }

  static Color _roleBackgroundColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.purple.withValues(alpha: 0.15);
      case 'VIEWER':
        return AppTheme.infoColor.withValues(alpha: 0.15);
      default:
        return AppTheme.successColor.withValues(alpha: 0.15);
    }
  }

  static Color _roleForegroundColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.purple;
      case 'VIEWER':
        return AppTheme.infoColor;
      default:
        return AppTheme.successColor;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.w600,
      ),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}

class _UserActions extends StatelessWidget {
  const _UserActions({
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
          padding: EdgeInsets.all(1),
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
          onPressed: () => onEdit(user),
        ),
        UserStatusToggleButton(
          value: user.enabled,
          isLoading: isToggleLoading,
          onChanged: (_) => onToggleStatus(user),
        ),
      ],
    );
  }
}
