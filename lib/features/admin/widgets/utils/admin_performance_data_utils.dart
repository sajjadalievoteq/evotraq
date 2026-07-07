abstract final class AdminPerformanceDataUtils {
  static String memoryUsage(Map<String, dynamic> systemResources) {
    final memory = systemResources['memory'] ?? {};
    final value = memory['usagePercentage'] ?? '0';
    final text = value.toString();
    return text.endsWith('%') ? text : '$text%';
  }

  static String cpuUsage(Map<String, dynamic> systemResources) {
    final cpu = systemResources['cpu'] ?? {};
    final cpuLoad = cpu['systemCpuLoad'] ?? 0;
    return '${(cpuLoad * 100).toStringAsFixed(1)}%';
  }

  static String activeConnections(Map<String, dynamic> connectionPool) {
    return connectionPool['activeConnections']?.toString() ?? '0';
  }

  static String activeThreads(Map<String, dynamic> threadPools) {
    if (threadPools.isEmpty) return '0';
    final direct = threadPools['activeThreads'] ?? threadPools['activeCount'];
    if (direct != null) return direct.toString();
    var total = 0;
    for (final value in threadPools.values) {
      if (value is Map) {
        total += (value['activeThreads'] as num?)?.toInt() ?? 0;
      }
    }
    return total.toString();
  }
}
