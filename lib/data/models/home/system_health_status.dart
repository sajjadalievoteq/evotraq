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

  Map<String, dynamic> toJson() {
    return {
      'backendHealthy': backendHealthy,
      'databaseHealthy': databaseHealthy,
      'cacheHealthy': cacheHealthy,
      'backendVersion': backendVersion,
    };
  }

  factory SystemHealthStatus.fromJson(Map<String, dynamic> json) {
    return SystemHealthStatus(
      backendHealthy: json['backendHealthy'] == true,
      databaseHealthy: json['databaseHealthy'] == true,
      cacheHealthy: json['cacheHealthy'] == true,
      backendVersion: json['backendVersion']?.toString(),
    );
  }
}
