import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_email_recipients_field.dart';

import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_notification_switch.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_notifications_skeleton.dart';

class TatmeenNotificationsSettings extends StatefulWidget {
  const TatmeenNotificationsSettings({
    super.key,
    required this.canUpdate,
    this.isLoading = false,
    this.settings,
    this.busy = false,
    this.onSave,
  });

  final bool canUpdate;
  final bool isLoading;
  final TatmeenIntegrationSettings? settings;
  final bool busy;
  final Future<void> Function(UpdateTatmeenIntegrationSettingsRequest request)?
  onSave;

  @override
  State<TatmeenNotificationsSettings> createState() =>
      _TatmeenNotificationsSettingsState();
}

class _TatmeenNotificationsSettingsState
    extends State<TatmeenNotificationsSettings> {
  late bool _failedSync;
  late bool _connectionErrors;
  late bool _dailyDigest;
  late List<String> _emails;

  @override
  void initState() {
    super.initState();
    _syncFromSettings(widget.settings);
  }

  @override
  void didUpdateWidget(covariant TatmeenNotificationsSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.settings;
    final prev = oldWidget.settings;
    if (next == prev) return;
    if (next == null) return;
    if (prev != null &&
        listEquals(prev.notificationEmails, next.notificationEmails) &&
        prev.notifyFailedSync == next.notifyFailedSync &&
        prev.notifyConnectionErrors == next.notifyConnectionErrors &&
        prev.notifyDailyDigest == next.notifyDailyDigest) {
      return;
    }
    _syncFromSettings(next);
  }

  void _syncFromSettings(TatmeenIntegrationSettings? settings) {
    _failedSync = settings?.notifyFailedSync ?? true;
    _connectionErrors = settings?.notifyConnectionErrors ?? true;
    _dailyDigest = settings?.notifyDailyDigest ?? false;
    _emails = List<String>.from(settings?.notificationEmails ?? const []);
  }

  bool get _editable =>
      widget.canUpdate && !widget.busy && widget.onSave != null;

  Future<void> _persist({
    List<String>? emails,
    bool? failedSync,
    bool? connectionErrors,
    bool? dailyDigest,
  }) async {
    final onSave = widget.onSave;
    if (onSave == null) return;
    await onSave(
      UpdateTatmeenIntegrationSettingsRequest(
        notificationEmails: emails ?? _emails,
        notifyFailedSync: failedSync ?? _failedSync,
        notifyConnectionErrors: connectionErrors ?? _connectionErrors,
        notifyDailyDigest: dailyDigest ?? _dailyDigest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return const TatmeenNotificationsSkeleton();
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Email notifications',
          style: context.text.h3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: TraqSpacing.sm),
        Text(
          'Emails are sent only to the addresses below. Each enabled type uses its own subject and body.',
          style: context.text.bodySm.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: TraqSpacing.sm),
        TatmeenNotificationSwitch(
          label: 'Failed sync items',
          subtitle:
              'Email when a record fails to synchronize, with the failure details in the body.',
          value: _failedSync,
          onChanged: _editable
              ? (value) {
                  setState(() => _failedSync = value);
                  _persist(failedSync: value);
                }
              : null,
        ),
        TatmeenNotificationSwitch(
          label: 'Connection errors',
          subtitle:
              'Email when Tatmeen connectivity fails, with the connection error in the body.',
          value: _connectionErrors,
          onChanged: _editable
              ? (value) {
                  setState(() => _connectionErrors = value);
                  _persist(connectionErrors: value);
                }
              : null,
        ),
        TatmeenNotificationSwitch(
          label: 'Daily digest',
          subtitle:
              'Email a once-daily summary of sync results to the same recipients.',
          value: _dailyDigest,
          onChanged: _editable
              ? (value) {
                  setState(() => _dailyDigest = value);
                  _persist(dailyDigest: value);
                }
              : null,
        ),
        const SizedBox(height: TraqSpacing.md),
        TatmeenEmailRecipientsField(
          emails: _emails,
          enabled: _editable,
          onChanged: (emails) {
            setState(() => _emails = emails);
            _persist(emails: emails);
          },
        ),
      ],
    );
  }
}
