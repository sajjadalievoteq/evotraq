import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_email_recipients_field.dart';

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

  bool get _editable => widget.canUpdate && !widget.busy && widget.onSave != null;

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
    if (widget.isLoading) return const _NotificationsSkeleton();
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Email notifications', style: context.text.h3.copyWith(fontSize: 16)),
        const SizedBox(height: TraqSpacing.sm),
        Text(
          'Emails are sent only to the addresses below. Each enabled type uses its own subject and body.',
          style: context.text.bodySm.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: TraqSpacing.sm),
        _NotificationSwitch(
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
        _NotificationSwitch(
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
        _NotificationSwitch(
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

class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSkeletonBox(width: 140, height: 18, color: muted),
          const SizedBox(height: TraqSpacing.sm),
          AppSkeletonBox(width: double.infinity, height: 12, color: muted),
          const SizedBox(height: TraqSpacing.sm),
          const _SwitchRowSkeleton(),
          const _SwitchRowSkeleton(),
          const _SwitchRowSkeleton(),
          const SizedBox(height: TraqSpacing.md),
          AppSkeletonBox(width: 110, height: 14, color: muted),
          const SizedBox(height: TraqSpacing.sm),
          Wrap(
            spacing: TraqSpacing.xs,
            children: [
              AppSkeletonBox(width: 140, height: 28, radius: 14, color: muted),
              AppSkeletonBox(width: 160, height: 28, radius: 14, color: muted),
              AppSkeletonBox(width: 120, height: 28, radius: 14, color: muted),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwitchRowSkeleton extends StatelessWidget {
  const _SwitchRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.45,
                  child: AppSkeletonBox(height: 14, color: muted),
                ),
                const SizedBox(height: TraqSpacing.xs),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.7,
                  child: AppSkeletonBox(height: 12, color: muted),
                ),
              ],
            ),
          ),
          AppSkeletonBox(width: 52, height: 28, radius: 14, color: muted),
        ],
      ),
    );
  }
}
