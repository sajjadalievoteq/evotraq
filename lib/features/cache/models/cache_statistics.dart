class CacheStatistics {
  final Map<String, dynamic> queryResults;
  final Map<String, dynamic> masterData;
  final Map<String, dynamic> hotData;
  final Map<String, dynamic> distributedCache;
  final Map<String, dynamic> overall;

  CacheStatistics({
    required this.queryResults,
    required this.masterData,
    required this.hotData,
    required this.distributedCache,
    required this.overall,
  });

  factory CacheStatistics.fromJson(Map<String, dynamic> json) {
    return CacheStatistics(
      queryResults: json['queryResults'] ?? {},
      masterData: json['masterData'] ?? {},
      hotData: json['hotData'] ?? {},
      distributedCache: json['distributedCache'] ?? {},
      overall: json['overall'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'queryResults': queryResults,
      'masterData': masterData,
      'hotData': hotData,
      'distributedCache': distributedCache,
      'overall': overall,
    };
  }

  // Helper getters for common statistics
  double get overallHitRatio => overall['overallHitRatio']?.toDouble() ?? 0.0;
  int get totalHits => overall['totalHits']?.toInt() ?? 0;
  int get totalMisses => overall['totalMisses']?.toInt() ?? 0;
  int get totalCacheEntries => overall['totalCacheEntries']?.toInt() ?? 0;
  int get masterDataEntries => overall['masterDataEntries']?.toInt() ?? 0;
  int get hotDataEntries => overall['hotDataEntries']?.toInt() ?? 0;
  int get queryResultsEntries => overall['queryResultsEntries']?.toInt() ?? 0;
  
  double get queryResultsHitRatio => queryResults['hitRatio']?.toDouble() ?? 0.0;
  int get queryResultsHits => queryResults['hits']?.toInt() ?? 0;
  int get queryResultsMisses => queryResults['misses']?.toInt() ?? 0;
  int get queryResultsCacheSize => queryResults['cacheSize']?.toInt() ?? 0;
  
  double get masterDataHitRatio => masterData['hitRatio']?.toDouble() ?? 0.0;
  int get masterDataHits => masterData['hits']?.toInt() ?? 0;
  int get masterDataMisses => masterData['misses']?.toInt() ?? 0;
  int get masterDataCacheSize => masterData['cacheSize']?.toInt() ?? 0;
  
  double get hotDataHitRatio => hotData['hitRatio']?.toDouble() ?? 0.0;
  int get hotDataHits => hotData['hits']?.toInt() ?? 0;
  int get hotDataMisses => hotData['misses']?.toInt() ?? 0;
  int get hotDataCacheSize => hotData['cacheSize']?.toInt() ?? 0;
  int get hotDataPatterns => hotData['hotPatterns']?.toInt() ?? 0;
  
  bool get monitoringEnabled => overall['monitoringEnabled'] ?? false;
  bool get distributedEnabled => overall['distributedEnabled'] ?? false;
}
