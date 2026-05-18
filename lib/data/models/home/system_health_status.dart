/// Aggregated actuator health for dashboard compliance / posture UI.
class SystemHealthStatus {
  final bool backendHealthy;
  final bool databaseHealthy;
  final bool cacheHealthy;
  final String? backendVersion;

  SystemHealthStatus({
    required this.backendHealthy,
    required this.databaseHealthy,
    required this.cacheHealthy,
    this.backendVersion,
  });
}
