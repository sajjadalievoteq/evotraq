part of 'tatmeen_detail_pane.dart';

class TatmeenDetailContent extends StatelessWidget {
  const TatmeenDetailContent({
    super.key,
    required this.state,
    required this.canUpdate,
    required this.onToggle,
    required this.onSaveCredentials,
    required this.onRemovePassword,
    required this.onRemoveApiKey,
    required this.onTestConnection,
  });

  final TatmeenIntegrationState state;
  final bool canUpdate;
  final ValueChanged<bool> onToggle;
  final Future<bool> Function(UpdateTatmeenIntegrationSettingsRequest request)
  onSaveCredentials;
  final Future<void> Function() onRemovePassword;
  final Future<void> Function() onRemoveApiKey;
  final VoidCallback onTestConnection;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = state.isEnabled;
    final settings = state.settings;
    final updatedAt = settings?.updatedAt;
    final updatedBy = settings?.updatedBy;
    final busy =
        state.status == TatmeenIntegrationStatus.updating ||
        state.status == TatmeenIntegrationStatus.testingConnection;
    final testing = state.status == TatmeenIntegrationStatus.testingConnection;
    final canTest =
        canUpdate &&
        !busy &&
        (settings?.credentialsComplete ?? false) &&
        !testing;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Configure encrypted Tatmeen credentials, verify connectivity, '
              'control whether the integration is active, and choose alerts.',
              style: context.text.bodySm.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: TraqSpacing.md),
            Row(
              children: [
                Text('Integration', style: context.text.body),
                const Spacer(),
                Text(
                  enabled ? 'On' : 'Off',
                  style: context.text.bodySm.copyWith(
                    color: context.colors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: TraqSpacing.xs),
                Switch.adaptive(
                  value: enabled,
                  onChanged: canUpdate && !busy ? onToggle : null,
                ),
              ],
            ),
            if (!canUpdate)
              Padding(
                padding: const EdgeInsets.only(top: TraqSpacing.xs),
                child: Text(
                  'Integration status updates require admin access.',
                  style: context.text.bodySm.copyWith(color: colors.textMuted),
                ),
              ),
            const SizedBox(height: TraqSpacing.sm),
            TatmeenConnectionStatusChip(enabled: enabled),
            if (!enabled) ...[
              const SizedBox(height: TraqSpacing.md),
              const TatmeenDisabledState(),
            ],
            const SizedBox(height: TraqSpacing.md),
            TatmeenCredentialsForm(
              settings: settings,
              canUpdate: canUpdate,
              busy: state.status == TatmeenIntegrationStatus.updating,
              onSave: onSaveCredentials,
              onRemovePassword: onRemovePassword,
              onRemoveApiKey: onRemoveApiKey,
            ),
            if (canUpdate) ...[
              const SizedBox(height: TraqSpacing.lg),
              OutlinedButton.icon(
                onPressed: canTest ? onTestConnection : null,
                icon: testing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const TraqIcon(AppAssets.iconLink, size: 18),
                label: Text(
                  testing ? 'Testing connection…' : 'Test connection',
                ),
              ),
              if (state.connectionTestResult != null) ...[
                const SizedBox(height: TraqSpacing.sm),
                TatmeenConnectionResultBanner(
                  result: state.connectionTestResult!,
                ),
              ],
            ],
            const SizedBox(height: TraqSpacing.lg),
            TatmeenNotificationsSettings(
              canUpdate: canUpdate,
              settings: settings,
              busy: busy,
              onSave: canUpdate
                  ? (request) async {
                      await onSaveCredentials(request);
                    }
                  : null,
            ),
            if (updatedAt != null || (updatedBy?.isNotEmpty ?? false)) ...[
              const SizedBox(height: TraqSpacing.lg),
              Text(
                _auditLabel(updatedAt, updatedBy),
                style: context.text.bodySm.copyWith(color: colors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _auditLabel(DateTime? updatedAt, String? updatedBy) {
    final parts = <String>[];
    if (updatedAt != null) {
      final local = updatedAt.toLocal();
      parts.add(
        'Updated ${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}',
      );
    }
    if (updatedBy != null && updatedBy.isNotEmpty) {
      parts.add('by $updatedBy');
    }
    return parts.join(' ');
  }
}
