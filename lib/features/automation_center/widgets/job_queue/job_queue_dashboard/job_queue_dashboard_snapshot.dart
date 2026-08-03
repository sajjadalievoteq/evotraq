/// Immutable snapshot for the Job Queue operations dashboard (UI-only).
/// All fields are derived from existing job-queue API payloads.
class JobQueueDashboardSnapshot {
  const JobQueueDashboardSnapshot({
    required this.healthy,
    required this.processingPaused,
    required this.queuedJobs,
    required this.activeJobs,
    required this.completedJobs,
    required this.failedJobs,
    required this.workerActive,
    required this.workerPoolSize,
    required this.workerMax,
    required this.queueSize,
    required this.queueCapacity,
    required this.workerUtilization,
    required this.priorityDistribution,
    required this.jobTypeDistribution,
    required this.activeJobsList,
    required this.recentHistory,
    required this.issues,
    required this.activeSparkline,
    required this.queuedSparkline,
    required this.lastUpdated,
    required this.autoRefresh,
  });

  final bool healthy;
  final bool processingPaused;
  final int queuedJobs;
  final int activeJobs;
  final int completedJobs;
  final int failedJobs;
  final int workerActive;
  final int workerPoolSize;
  final int workerMax;
  final int queueSize;
  final int queueCapacity;
  final double workerUtilization;
  final Map<String, int> priorityDistribution;
  final Map<String, int> jobTypeDistribution;
  final List<Map<String, dynamic>> activeJobsList;
  final List<Map<String, dynamic>> recentHistory;
  final List<String> issues;
  final List<double> activeSparkline;
  final List<double> queuedSparkline;
  final DateTime? lastUpdated;
  final bool autoRefresh;

  int get totalKnownJobs =>
      activeJobs + queuedJobs + completedJobs + failedJobs;

  double get queueUsage =>
      queueCapacity > 0 ? (queueSize / queueCapacity).clamp(0.0, 1.0) : 0.0;

  double get successRate {
    final done = completedJobs + failedJobs;
    if (done <= 0) return 1.0;
    return (completedJobs / done).clamp(0.0, 1.0);
  }

  String get statusLabel {
    if (processingPaused) return 'Paused';
    return healthy ? 'Healthy' : 'Attention';
  }
}
