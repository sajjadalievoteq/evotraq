import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';

import 'user_management_constants.dart';
import 'user_status_toggle_button.dart';

enum UserManagementUserCardVariant {
  listTile,
  gridSquare,
}

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
      UserManagementUserCardVariant.listTile => _buildListCard(context),
      UserManagementUserCardVariant.gridSquare => _buildGridSquareCard(context),
    };
  }

  Widget _buildListCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final details = _UserDetails(user: user, density: _UserDetailsDensity.comfy);
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

  Widget _buildGridSquareCard(BuildContext context) {
    final details = _UserDetails(user: user, density: _UserDetailsDensity.compact);
    final actions = _UserActions(
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
          children: [
            Row(
              children: [
                _UserAvatar(
                  initial: _resolveInitial(user.firstName),
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
            const SizedBox(height: 10),
            Expanded(child: details),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: actions,
            ),
          ],
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
  const _UserAvatar({
    required this.initial,
    this.radius = 20,
  });

  final String initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.colors.textSecondary,
      radius: radius,
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

enum _UserDetailsDensity {
  comfy,
  compact,
}

class _UserDetails extends StatelessWidget {
  const _UserDetails({
    required this.user,
    required this.density,
  });

  final UserResponse user;
  final _UserDetailsDensity density;

  @override
  Widget build(BuildContext context) {
    final name = '${user.firstName} ${user.lastName}'.trim();
    final spacingSm = density == _UserDetailsDensity.compact ? 2.0 : 4.0;
    final spacingMd = density == _UserDetailsDensity.compact ? 8.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (density == _UserDetailsDensity.comfy) ...[
          Text(
            name.isEmpty ? user.username : name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
                  color: context.colors.primary,
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
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              label: user.role,
              backgroundColor: _roleBackgroundColor(context, user.role),
              foregroundColor: _roleForegroundColor(context, user.role),
            ),
            _StatusChip(
              label: user.enabled
                  ? UserManagementConstants.activeStatus
                  : UserManagementConstants.inactiveStatus,
              backgroundColor: user.enabled
                  ? context.colors.success.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.18),
              foregroundColor:
                  user.enabled ? context.colors.success : Colors.grey[800]!,
            ),
            if (user.approvalStatus == UserManagementConstants.pendingStatus)
              _StatusChip(
                label: UserManagementConstants.pendingStatus,
                backgroundColor: context.colors.warning.withValues(alpha: 0.15),
                foregroundColor: context.colors.warning,
              ),
          ],
        ),
      ],
    );
  }

  static Color _roleBackgroundColor(BuildContext context, String role) {
    final c = context.colors;
    switch (role) {
      case 'ADMIN':
        return Colors.purple.withValues(alpha: 0.15);
      case 'VIEWER':
        return c.secondary.withValues(alpha: 0.15);
      default:
        return c.success.withValues(alpha: 0.15);
    }
  }

  static Color _roleForegroundColor(BuildContext context, String role) {
    final c = context.colors;
    switch (role) {
      case 'ADMIN':
        return Colors.purple;
      case 'VIEWER':
        return c.secondary;
      default:
        return c.success;
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
