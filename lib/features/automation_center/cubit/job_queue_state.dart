import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';

enum JobQueueStatus { initial, loading, success, error }

enum JobQueueConnectionStatus { disconnected, connecting, connected }

/// State for the Job Queue panel. The [snapshot] is the single source of truth for everything
/// the panel's tabs render (metrics, active/queued/history lists, worker pool, health); there are
/// no parallel copies of that data here.
class JobQueueState extends Equatable {
  final JobQueueStatus status;
  final JobQueueDashboardSnapshot? snapshot;
  final JobQueueConnectionStatus connectionStatus;
  final String? error;

  const JobQueueState({
    this.status = JobQueueStatus.initial,
    this.snapshot,
    this.connectionStatus = JobQueueConnectionStatus.disconnected,
    this.error,
  });

  JobQueueState copyWith({
    JobQueueStatus? status,
    JobQueueDashboardSnapshot? snapshot,
    JobQueueConnectionStatus? connectionStatus,
    String? error,
  }) {
    return JobQueueState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      // Matches NotificationState: error is not carried forward implicitly.
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, snapshot, connectionStatus, error];
}
