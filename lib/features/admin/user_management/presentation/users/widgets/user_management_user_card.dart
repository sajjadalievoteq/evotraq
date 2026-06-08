import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';

import 'user_management_constants.dart';

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
            final details = _UserDetails(
              user: user,
              density: _UserDetailsDensity.comfy,
            );
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
                  Align(alignment: Alignment.centerRight, child: actions),
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
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 6),
            _UserDetails(
              user: user,
              density: _UserDetailsDensity.compact,
            ),
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerRight, child: actions),
          ],
        ),
      ),
    );
  }

  String _resolveInitial(String firstName) {
    if (firstName.isEmpty) return 'U';
    return firstName.characters.first.toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.initial, this.radius = 20});

  final String initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.colors.textSecondary,
      radius: radius,
      child: Text(initial, style: const TextStyle(color: Colors.white)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Details block
// ─────────────────────────────────────────────────────────────────────────────

enum _UserDetailsDensity { comfy, compact }

class _UserDetails extends StatelessWidget {
  const _UserDetails({required this.user, required this.density});

  final UserResponse user;
  final _UserDetailsDensity density;

  @override
  Widget build(BuildContext context) {
    final name = '${user.firstName} ${user.lastName}'.trim();
    final spacingSm = density == _UserDetailsDensity.compact ? 2.0 : 4.0;
    final spacingMd = density == _UserDetailsDensity.compact ? 8.0 : 12.0;
    final colors = context.colors;

    // Resolve role colour inline — no static helper needed.
    final Color roleColor = switch (user.role) {
      'ADMIN'        => Colors.purple,
      'MANUFACTURER' => colors.primary,
      'DISTRIBUTOR'  => Colors.orange,
      'RETAILER'     => Colors.teal,
      _              => colors.success, // USER and any unknown
    };

    final Color statusColor =
        user.enabled ? colors.success : colors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (density == _UserDetailsDensity.comfy) ...[
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

        // ── Role / Status / Approval badges ──────────────────────────────
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _InfoBadge(
              label: 'Role',
              value: user.role,
              valueColor: roleColor,
            ),
            _InfoBadge(
              label: 'Status',
              value: user.enabled
                  ? UserManagementConstants.activeStatus
                  : UserManagementConstants.inactiveStatus,
              valueColor: statusColor,
            ),
            if (user.approvalStatus == UserManagementConstants.pendingStatus)
              _InfoBadge(
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

// ─────────────────────────────────────────────────────────────────────────────
// Info badge  (dot + "Label: Value" — no Chip widget)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Coloured status dot
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 5, top: 1),
          decoration: BoxDecoration(
            color: valueColor,
            shape: BoxShape.circle,
          ),
        ),
        // Muted label
        Text(
          '$label: ',
          style: bodySmall?.copyWith(color: mutedColor),
        ),
        // Coloured bold value
        Text(
          value,
          style: bodySmall?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Actions (edit icon + status toggle)
// ─────────────────────────────────────────────────────────────────────────────

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
