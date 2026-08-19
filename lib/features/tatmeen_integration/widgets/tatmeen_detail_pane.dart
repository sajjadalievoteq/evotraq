import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_state.dart';
import 'package:traqtrace_app/features/tatmeen_integration/utils/tatmeen_integration_sections.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_dashboard.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_credentials_form.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_disabled_state.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_notifications_settings.dart';

class TatmeenDetailPane extends StatelessWidget {
  const TatmeenDetailPane({
    super.key,
    required this.state,
    required this.canUpdate,
    required this.selectedSection,
    required this.onToggle,
    required this.onRetry,
    required this.onSaveCredentials,
    required this.onRemovePassword,
    required this.onRemoveApiKey,
    required this.onTestConnection,
  });

  final TatmeenIntegrationState state;
  final bool canUpdate;
  final String selectedSection;
  final ValueChanged<bool> onToggle;
  final VoidCallback onRetry;
  final Future<bool> Function(UpdateTatmeenIntegrationSettingsRequest request)
  onSaveCredentials;
  final Future<void> Function() onRemovePassword;
  final Future<void> Function() onRemoveApiKey;
  final VoidCallback onTestConnection;

  @override
  Widget build(BuildContext context) {
    final normalizedSection = TatmeenIntegrationSections.normalize(
      selectedSection,
    );
    if (normalizedSection == TatmeenIntegrationSections.dashboard) {
      return const TatmeenDashboard();
    }
    return switch (state.status) {
      TatmeenIntegrationStatus.initial ||
      TatmeenIntegrationStatus.loading => const _TatmeenDetailSkeleton(),
      TatmeenIntegrationStatus.error => SubscriptionErrorView(
        title: 'Unable to load Tatmeen settings',
        message: state.error ?? 'Unknown error',
        onRetry: onRetry,
        padding: EdgeInsets.zero,
      ),
      TatmeenIntegrationStatus.loaded ||
      TatmeenIntegrationStatus.updating ||
      TatmeenIntegrationStatus.testingConnection => _TatmeenDetailContent(
        state: state,
        canUpdate: canUpdate,
        onToggle: onToggle,
        onSaveCredentials: onSaveCredentials,
        onRemovePassword: onRemovePassword,
        onRemoveApiKey: onRemoveApiKey,
        onTestConnection: onTestConnection,
      ),
    };
  }
}

class _TatmeenDetailContent extends StatelessWidget {
  const _TatmeenDetailContent({
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
            _StatusChip(enabled: enabled),
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
                _ConnectionResultBanner(result: state.connectionTestResult!),
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

class _ConnectionResultBanner extends StatelessWidget {
  const _ConnectionResultBanner({required this.result});

  final TatmeenConnectionTestResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final success = result.success;
    final bg = success
        ? colors.success.withValues(alpha: 0.12)
        : colors.error.withValues(alpha: 0.12);
    final fg = success ? colors.success : colors.error;
    return Container(
      padding: const EdgeInsets.all(TraqSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: TraqRadius.chip,
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Text(
        result.message,
        style: context.text.bodySm.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = enabled
        ? colors.success.withValues(alpha: 0.12)
        : colors.textMuted.withValues(alpha: 0.12);
    final fg = enabled ? colors.success : colors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: TraqSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: TraqRadius.chip,
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(
            enabled ? AppAssets.iconCheckCircle : AppAssets.iconPause,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: TraqSpacing.xs),
          Text(
            enabled ? 'Integration enabled' : 'Integration disabled',
            style: context.text.bodySm.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TatmeenDetailSkeleton extends StatelessWidget {
  const _TatmeenDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: context.colors.border),
      ),
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSkeletonBox(
                    width: double.infinity,
                    height: 12,
                    color: muted,
                  ),
                  const SizedBox(height: TraqSpacing.xs),
                  AppSkeletonBox(width: 280, height: 12, color: muted),
                  const SizedBox(height: TraqSpacing.md),
                  Row(
                    children: [
                      AppSkeletonBox(width: 90, height: 16, color: muted),
                      const Spacer(),
                      AppSkeletonBox(width: 28, height: 14, color: muted),
                      const SizedBox(width: TraqSpacing.xs),
                      AppSkeletonBox(
                        width: 52,
                        height: 28,
                        radius: 14,
                        color: muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: TraqSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppSkeletonBox(
                      width: 160,
                      height: 28,
                      radius: 14,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TraqSpacing.md),
            TatmeenCredentialsForm(
              settings: null,
              canUpdate: false,
              busy: false,
              isLoading: true,
              onSave: (_) async => false,
              onRemovePassword: () async {},
              onRemoveApiKey: () async {},
            ),
            const SizedBox(height: TraqSpacing.lg),
            AppShimmer(
              child: AppSkeletonBox(
                width: double.infinity,
                height: 40,
                radius: 8,
                color: muted,
              ),
            ),
            const SizedBox(height: TraqSpacing.lg),
            const TatmeenNotificationsSettings(canUpdate: false, isLoading: true),
          ],
        ),
      ),
    );
  }
}
