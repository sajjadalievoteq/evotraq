import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';

/// Builds a [JobQueueDashboardSnapshot] from live job-queue panel state.
JobQueueDashboardSnapshot buildJobQueueDashboardSnapshot({
  required Map<String, dynamic> dashboardData,
  required Map<String, dynamic> workerPoolStats,
  required Map<String, dynamic> queueHealth,
  required List<Map<String, dynamic>> activeJobs,
  required List<Map<String, dynamic>> queuedJobs,
  required List<Map<String, dynamic>> jobHistory,
  required List<double> activeSparkline,
  required List<double> queuedSparkline,
  required DateTime? lastUpdated,
  required bool autoRefresh,
}) {
  final workerPool =
      dashboardData['workerPool'] as Map<String, dynamic>? ?? {};
  final priorityRaw = dashboardData['priorityDistribution'] as Map? ?? {};
  final typeRaw = dashboardData['jobTypeDistribution'] as Map? ?? {};

  final priority = <String, int>{
    for (final e in priorityRaw.entries)
      '${e.key}': (e.value as num?)?.toInt() ?? 0,
  };
  final types = <String, int>{
    for (final e in typeRaw.entries)
      '${e.key}': (e.value as num?)?.toInt() ?? 0,
  };

  final workerActive = (workerPool['activeThreads'] as num?)?.toInt() ??
      (workerPoolStats['active'] as num?)?.toInt() ??
      (workerPoolStats['activeCount'] as num?)?.toInt() ??
      0;
  final workerMax = (workerPool['maxPoolSize'] as num?)?.toInt() ??
      (workerPoolStats['maximumPoolSize'] as num?)?.toInt() ??
      (workerPoolStats['total'] as num?)?.toInt() ??
      0;
  final workerPoolSize = (workerPool['poolSize'] as num?)?.toInt() ??
      (workerPoolStats['poolSize'] as num?)?.toInt() ??
      0;

  final utilRaw = queueHealth['workerUtilization'];
  double utilization = workerMax > 0 ? workerActive / workerMax : 0.0;
  if (utilRaw is String) {
    utilization =
        (double.tryParse(utilRaw.replaceAll('%', '')) ?? 0) / 100.0;
  } else if (utilRaw is num) {
    utilization =
        utilRaw.toDouble() > 1 ? utilRaw / 100.0 : utilRaw.toDouble();
  }

  final failed = jobHistory
      .where((j) => '${j['status']}'.toUpperCase() == 'FAILED')
      .length;
  final completedFromHistory = jobHistory
      .where((j) => '${j['status']}'.toUpperCase() == 'COMPLETED')
      .length;
  final completed =
      (dashboardData['completedJobs'] as num?)?.toInt() ?? completedFromHistory;

  final issues = (queueHealth['issues'] as List?)
          ?.map((e) => '$e')
          .toList() ??
      const <String>[];

  return JobQueueDashboardSnapshot(
    healthy: queueHealth['healthy'] as bool? ?? true,
    processingPaused: dashboardData['processingPaused'] as bool? ??
        queueHealth['processingPaused'] as bool? ??
        false,
    queuedJobs:
        (dashboardData['queuedJobs'] as num?)?.toInt() ?? queuedJobs.length,
    activeJobs:
        (dashboardData['activeJobs'] as num?)?.toInt() ?? activeJobs.length,
    completedJobs: completed,
    failedJobs: failed,
    workerActive: workerActive,
    workerPoolSize: workerPoolSize,
    workerMax: workerMax <= 0 ? 20 : workerMax,
    queueSize: (queueHealth['queueSize'] as num?)?.toInt() ??
        (dashboardData['queuedJobs'] as num?)?.toInt() ??
        0,
    queueCapacity: (queueHealth['queueCapacity'] as num?)?.toInt() ?? 1000,
    workerUtilization: utilization,
    priorityDistribution: priority,
    jobTypeDistribution: types,
    activeJobsList: activeJobs,
    recentHistory: jobHistory,
    issues: issues,
    activeSparkline: List<double>.from(activeSparkline),
    queuedSparkline: List<double>.from(queuedSparkline),
    lastUpdated: lastUpdated,
    autoRefresh: autoRefresh,
  );
}
