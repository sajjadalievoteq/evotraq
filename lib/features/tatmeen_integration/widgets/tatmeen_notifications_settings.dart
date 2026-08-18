import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class TatmeenNotificationsSettings extends StatefulWidget {
  const TatmeenNotificationsSettings({super.key, required this.canUpdate});

  final bool canUpdate;

  @override
  State<TatmeenNotificationsSettings> createState() =>
      _TatmeenNotificationsSettingsState();
}

class _TatmeenNotificationsSettingsState
    extends State<TatmeenNotificationsSettings> {
  bool _failedSync = true;
  bool _connectionErrors = true;
  bool _inAppAlerts = true;
  bool _dailyDigest = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Notifications', style: context.text.h3.copyWith(fontSize: 16)),
        const SizedBox(height: TraqSpacing.sm),
        Text(
          'Choose how TraqTrace alerts you about Tatmeen sync activity.',
          style: context.text.bodySm.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: TraqSpacing.sm),
        _NotificationSwitch(
          label: 'Failed sync items',
          subtitle: 'Notify when a record fails to synchronize.',
          value: _failedSync,
          onChanged: widget.canUpdate
              ? (value) => setState(() => _failedSync = value)
              : null,
        ),
        _NotificationSwitch(
          label: 'Connection errors',
          subtitle: 'Notify when Tatmeen connectivity fails.',
          value: _connectionErrors,
          onChanged: widget.canUpdate
              ? (value) => setState(() => _connectionErrors = value)
              : null,
        ),
        _NotificationSwitch(
          label: 'In-app alerts',
          subtitle: 'Show Tatmeen alerts in the notification center.',
          value: _inAppAlerts,
          onChanged: widget.canUpdate
              ? (value) => setState(() => _inAppAlerts = value)
              : null,
        ),
        _NotificationSwitch(
          label: 'Daily digest',
          subtitle: 'Send a once-daily summary of sync results.',
          value: _dailyDigest,
          onChanged: widget.canUpdate
              ? (value) => setState(() => _dailyDigest = value)
              : null,
        ),
      ],
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: context.text.body),
      subtitle: Text(
        subtitle,
        style: context.text.bodySm.copyWith(color: context.colors.textMuted),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
