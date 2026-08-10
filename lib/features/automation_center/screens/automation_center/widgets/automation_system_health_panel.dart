import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_state.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';

/// Cross-cutting health rollup — no duplicated tab content (metrics, activity
/// feeds, live toggles, or job dashboards live on their own tabs).
class AutomationSystemHealthPanel extends StatelessWidget {
  const AutomationSystemHealthPanel({
    super.key,
    this.jobQueueCubit,
    this.onOpenSubscriptions,
    this.onOpenActivity,
    this.onOpenJobOperations,
  });

  final JobQueueCubit? jobQueueCubit;
  final VoidCallback? onOpenSubscriptions;
  final VoidCallback? onOpenActivity;
  final VoidCallback? onOpenJobOperations;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      buildWhen: (prev, next) =>
          prev.connectionStatus != next.connectionStatus ||
          prev.notificationLiveEnabled != next.notificationLiveEnabled ||
          prev.subscriptions != next.subscriptions ||
          prev.status != next.status,
      builder: (context, notificationState) {
        final jobCubit = jobQueueCubit;
        if (jobCubit == null) {
          return _HealthDashboard(
            notification: notificationState,
            snapshot: null,
            jobLoading: false,
            jobError: null,
            onOpenSubscriptions: onOpenSubscriptions,
            onOpenActivity: onOpenActivity,
            onOpenJobOperations: onOpenJobOperations,
          );
        }
        return BlocBuilder<JobQueueCubit, JobQueueState>(
          bloc: jobCubit,
          builder: (context, jobState) {
            return _HealthDashboard(
              notification: notificationState,
              snapshot: jobState.snapshot,
              jobLoading:
                  jobState.snapshot == null &&
                  jobState.status != JobQueueStatus.error,
              jobError: jobState.status == JobQueueStatus.error
                  ? (jobState.error ?? 'Unable to load job queue')
                  : null,
              onOpenSubscriptions: onOpenSubscriptions,
              onOpenActivity: onOpenActivity,
              onOpenJobOperations: onOpenJobOperations,
            );
          },
        );
      },
    );
  }
}

class _HealthDashboard extends StatelessWidget {
  const _HealthDashboard({
    required this.notification,
    required this.snapshot,
    required this.jobLoading,
    required this.jobError,
    required this.onOpenSubscriptions,
    required this.onOpenActivity,
    required this.onOpenJobOperations,
  });

  final NotificationState notification;
  final JobQueueDashboardSnapshot? snapshot;
  final bool jobLoading;
  final String? jobError;
  final VoidCallback? onOpenSubscriptions;
  final VoidCallback? onOpenActivity;
  final VoidCallback? onOpenJobOperations;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final summary = _buildSummary(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OverallHealthHero(summary: summary),
          const SizedBox(height: TraqSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final signals = _healthSignals(context, summary);
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < signals.length; i++) ...[
                      Expanded(child: signals[i]),
                      if (i != signals.length - 1)
                        const SizedBox(width: TraqSpacing.md),
                    ],
                  ],
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < signals.length; i++) ...[
                    signals[i],
                    if (i != signals.length - 1)
                      const SizedBox(height: TraqSpacing.md),
                  ],
                ],
              );
            },
          ),
          if (jobError != null) ...[
            const SizedBox(height: TraqSpacing.lg),
            _InlineAlert(
              tone: JobQueueStatusTone.err,
              title: 'Job queue unavailable',
              message: jobError!,
            ),
          ] else if (jobLoading) ...[
            const SizedBox(height: TraqSpacing.lg),
            _InlineAlert(
              tone: JobQueueStatusTone.info,
              title: 'Loading job queue',
              message: 'Queue health will appear shortly.',
            ),
          ],
          if (snapshot != null && snapshot!.issues.isNotEmpty) ...[
            const SizedBox(height: TraqSpacing.lg),
            _InlineAlert(
              tone: JobQueueStatusTone.warn,
              title: 'Detected issues',
              message: snapshot!.issues.join('\n'),
            ),
          ],
          const SizedBox(height: TraqSpacing.md),
          Text(
            'Use Subscriptions to manage configs, Activity for delivery events, '
            'and Job Operations for queue details.',
            style: context.text.cap.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }

  _HealthSummary _buildSummary(BuildContext context) {
    final live =
        notification.notificationLiveEnabled &&
        notification.connectionStatus == NotificationConnectionStatus.connected;
    final connecting =
        notification.notificationLiveEnabled &&
        notification.connectionStatus == NotificationConnectionStatus.connecting;
    final activeCount = notification.subscriptions
        .where((s) => s.status.toUpperCase() == 'ACTIVE')
        .length;
    final failed = notification.subscriptions.fold<int>(
      0,
      (sum, s) => sum + (s.stats?.failedNotifications ?? 0),
    );

    final deliveryOk = notification.subscriptions.isEmpty || failed == 0;
    final wsOk = live || !notification.notificationLiveEnabled;
    final queueOk = snapshot == null
        ? jobError == null
        : snapshot!.healthy && !snapshot!.processingPaused;

    final overallOk = deliveryOk && wsOk && queueOk && jobError == null;
    final overallWarn =
        connecting ||
        (snapshot?.processingPaused ?? false) ||
        (!overallOk && (deliveryOk || wsOk));

    return _HealthSummary(
      overallLabel: overallOk
          ? 'All systems healthy'
          : overallWarn
          ? 'Attention needed'
          : 'Degraded',
      overallTone: overallOk
          ? JobQueueStatusTone.ok
          : overallWarn
          ? JobQueueStatusTone.warn
          : JobQueueStatusTone.err,
      pulse: live && overallOk,
      activeSubscriptions: activeCount,
      failedDeliveries: failed,
      live: live,
      connecting: connecting,
      livePaused: !notification.notificationLiveEnabled,
      queueLabel: snapshot?.statusLabel ??
          (jobError != null
              ? 'Unavailable'
              : jobLoading
              ? 'Loading…'
              : '—'),
      queueOk: queueOk,
      queuePaused: snapshot?.processingPaused ?? false,
      workerSummary: snapshot == null
          ? '—'
          : '${snapshot!.workerActive} / ${snapshot!.workerMax} busy',
      workerUtilization: snapshot?.workerUtilization ?? 0,
      lastUpdated: snapshot?.lastUpdated,
    );
  }

  List<Widget> _healthSignals(BuildContext context, _HealthSummary s) {
    final wsValue = s.livePaused
        ? 'Paused'
        : s.connecting
        ? 'Connecting'
        : s.live
        ? 'Connected'
        : 'Offline';

    return [
      _HealthSignalTile(
        icon: NavIcons.manageSubscriptions,
        title: 'Subscriptions',
        value: '${s.activeSubscriptions} active',
        detail: s.failedDeliveries > 0
            ? '${s.failedDeliveries} failed deliveries'
            : 'Manage configs',
        tone: s.failedDeliveries > 0
            ? JobQueueStatusTone.warn
            : JobQueueStatusTone.ok,
        onTap: onOpenSubscriptions,
      ),
      _HealthSignalTile(
        icon: NavIcons.notificationCenter,
        title: 'Live feed',
        value: wsValue,
        detail: 'Delivery events',
        tone: s.live
            ? JobQueueStatusTone.ok
            : s.connecting
            ? JobQueueStatusTone.warn
            : JobQueueStatusTone.muted,
        onTap: onOpenActivity,
      ),
      _HealthSignalTile(
        icon: NavIcons.jobQueueManagement,
        title: 'Job queue',
        value: s.queueLabel,
        detail: s.queuePaused ? 'Processing paused' : 'Open Job Operations',
        tone: s.queuePaused
            ? JobQueueStatusTone.warn
            : s.queueOk
            ? JobQueueStatusTone.ok
            : JobQueueStatusTone.err,
        onTap: onOpenJobOperations,
      ),
      _HealthSignalTile(
        icon: AppAssets.iconUsers,
        title: 'Workers',
        value: s.workerSummary,
        detail: onOpenJobOperations == null
            ? 'Admin only'
            : 'Worker pool details',
        tone: s.workerUtilization > 0.9
            ? JobQueueStatusTone.warn
            : JobQueueStatusTone.ok,
        onTap: onOpenJobOperations,
      ),
    ];
  }
}

class _HealthSummary {
  const _HealthSummary({
    required this.overallLabel,
    required this.overallTone,
    required this.pulse,
    required this.activeSubscriptions,
    required this.failedDeliveries,
    required this.live,
    required this.connecting,
    required this.livePaused,
    required this.queueLabel,
    required this.queueOk,
    required this.queuePaused,
    required this.workerSummary,
    required this.workerUtilization,
    required this.lastUpdated,
  });

  final String overallLabel;
  final JobQueueStatusTone overallTone;
  final bool pulse;
  final int activeSubscriptions;
  final int failedDeliveries;
  final bool live;
  final bool connecting;
  final bool livePaused;
  final String queueLabel;
  final bool queueOk;
  final bool queuePaused;
  final String workerSummary;
  final double workerUtilization;
  final DateTime? lastUpdated;
}

class _OverallHealthHero extends StatelessWidget {
  const _OverallHealthHero({required this.summary});

  final _HealthSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final last = summary.lastUpdated == null
        ? '—'
        : DateFormat.Hms().format(summary.lastUpdated!.toLocal());

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Health',
                    style: context.text.h3.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: TraqSpacing.xs),
                  Text(
                    'Cross-cutting rollup · queue updated $last',
                    style: context.text.bodySm.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
            JobQueueStatusBadge(
              label: summary.overallLabel,
              tone: summary.overallTone,
              pulse: summary.pulse,
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthSignalTile extends StatelessWidget {
  const _HealthSignalTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.tone,
    this.onTap,
  });

  final String icon;
  final String title;
  final String value;
  final String detail;
  final JobQueueStatusTone tone;
  final VoidCallback? onTap;

  Color _toneColor(BuildContext context) => switch (tone) {
    JobQueueStatusTone.ok => AppColorMapper.successColor(context),
    JobQueueStatusTone.warn => AppColorMapper.warningColor(context),
    JobQueueStatusTone.err => AppColorMapper.errorColor(context),
    JobQueueStatusTone.info => AppColorMapper.infoColor(context),
    JobQueueStatusTone.muted => context.colors.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = _toneColor(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: TraqRadius.card,
          child: Padding(
            padding: TraqSpacing.surfacePad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TraqIcon(icon, size: 16, color: accent),
                    const SizedBox(width: TraqSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        style: context.text.cap.copyWith(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TraqSpacing.sm),
                Text(
                  value,
                  style: context.text.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: TraqSpacing.xs),
                Text(
                  detail,
                  style: context.text.cap.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineAlert extends StatelessWidget {
  const _InlineAlert({
    required this.tone,
    required this.title,
    required this.message,
  });

  final JobQueueStatusTone tone;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = switch (tone) {
      JobQueueStatusTone.ok => AppColorMapper.successColor(context),
      JobQueueStatusTone.warn => AppColorMapper.warningColor(context),
      JobQueueStatusTone.err => AppColorMapper.errorColor(context),
      JobQueueStatusTone.info => AppColorMapper.infoColor(context),
      JobQueueStatusTone.muted => c.textMuted,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: TraqRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TraqIcon(AppAssets.iconAlert, size: 18, color: color),
            const SizedBox(width: TraqSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: TraqSpacing.xs),
                  Text(
                    message,
                    style: context.text.cap.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
