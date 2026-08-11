import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_state.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';

/// Cross-cutting health rollup — no duplicated tab content (metrics, activity
/// feeds, live toggles, or job dashboards live on their own tabs).
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_health_dashboard.dart';

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
          return AutomationHealthDashboard(
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
            return AutomationHealthDashboard(
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
