import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/data/services/user_management/user_management_service.dart';
import 'package:traqtrace_app/features/automation_center/widgets/inbound/create_system_user_dialog.dart';

class SystemUsersCard extends StatefulWidget {
  const SystemUsersCard({super.key});

  @override
  State<SystemUsersCard> createState() => _SystemUsersCardState();
}

class _SystemUsersCardState extends State<SystemUsersCard> {
  final _service = UserManagementService();
  List<UserResponse> _users = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _service.getUsers(role: 'B2B_SERVICE', size: 100);
      final b2bUsers = response.users
          .where((user) => user.role == 'B2B_SERVICE')
          .toList(growable: false);
      if (mounted) setState(() => _users = b2bUsers);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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
    await _load();
  }

  Future<void> _toggle(UserResponse user) async {
    try {
      await _service.changeUserStatus(user.id, !user.enabled);
      await _load();
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
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              TextButton.icon(
                onPressed: _load,
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
