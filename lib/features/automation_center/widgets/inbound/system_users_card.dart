import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/data/services/user_management/user_management_service.dart';
import 'package:traqtrace_app/features/automation_center/widgets/inbound/create_system_user_dialog.dart';

/// Survives Outbound ↔ Inbound panel remounts within the same app session.
List<UserResponse> _sessionB2bUsers = const [];

class SystemUsersCard extends StatefulWidget {
  const SystemUsersCard({super.key});

  @override
  State<SystemUsersCard> createState() => _SystemUsersCardState();
}

class _SystemUsersCardState extends State<SystemUsersCard> {
  late final UserManagementService _service;
  List<UserResponse> _users = _sessionB2bUsers;
  bool _loading = _sessionB2bUsers.isEmpty;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = getIt<UserManagementService>();
    _load(force: _sessionB2bUsers.isEmpty);
  }

  Future<void> _load({bool force = true}) async {
    // Keep the existing list visible on remount / soft refresh.
    if (!force && _users.isNotEmpty) return;

    setState(() {
      _loading = _users.isEmpty;
      _error = null;
    });
    try {
      final response = await _service.getUsers(role: 'B2B_SERVICE', size: 100);
      final b2bUsers = response.users
          .where((user) => user.role == 'B2B_SERVICE')
          .toList(growable: false);
      _sessionB2bUsers = b2bUsers;
      if (!mounted) return;
      setState(() {
        _users = b2bUsers;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    final credentials = await CreateSystemUserDialog.show(
      context,
      service: _service,
    );
    if (credentials == null || !mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('B2B Service user created'),
        content: SelectableText(
          'Copy these credentials now. The password will not be shown again.\n\n'
          'Username: ${credentials.username}\nPassword: ${credentials.password}',
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(
                  text:
                      'Username: ${credentials.username}\nPassword: ${credentials.password}',
                ),
              );
              if (dialogContext.mounted) {
                dialogContext.showSuccess('Credentials copied');
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy credentials'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    await _load(force: true);
  }

  Future<void> _toggle(UserResponse user) async {
    try {
      await _service.changeUserStatus(user.id, !user.enabled);
      await _load(force: true);
    } catch (error) {
      if (mounted) {
        context.showError(error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('B2B Test Accounts', style: context.text.h3),
                ),
                FilledButton.icon(
                  onPressed: _create,
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text('Create B2B Service User'),
                ),
              ],
            ),
            const SizedBox(height: TraqSpacing.sm),
            Text(
              'B2B Service users can exercise the documented integration APIs directly (never through this web app) and cannot access administrative endpoints.',
              style: context.text.body.copyWith(
                color: context.colors.textMuted,
              ),
            ),
            const SizedBox(height: TraqSpacing.md),
            if (_loading)
              const _B2bUsersListSkeleton()
            else if (_error != null)
              TextButton.icon(
                onPressed: () => _load(force: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry loading B2B service users'),
              )
            else if (_users.isEmpty)
              const Text('No B2B Service users have been created.')
            else
              ..._users.map(
                (user) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(user.username),
                  subtitle: Text('${user.email} • ${user.createdAt}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(user.enabled ? 'Enabled' : 'Revoked'),
                      Switch(
                        value: user.enabled,
                        onChanged: (_) => _toggle(user),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _B2bUsersListSkeleton extends StatelessWidget {
  const _B2bUsersListSkeleton();

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.surfaceMuted;
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: TraqSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonBox(
                        width: 120 + (i * 24),
                        height: 14,
                        radius: 4,
                        color: muted,
                      ),
                      const SizedBox(height: TraqSpacing.xs),
                      AppSkeletonBox(
                        width: 200,
                        height: 12,
                        radius: 4,
                        color: muted,
                      ),
                    ],
                  ),
                ),
                AppSkeletonBox(width: 56, height: 12, radius: 4, color: muted),
                const SizedBox(width: TraqSpacing.md),
                AppSkeletonBox(width: 40, height: 24, radius: 12, color: muted),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
