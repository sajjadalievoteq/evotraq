class CacheHealth {
  final String status;
  final bool healthy;
  final int timestamp;
  final String? error;

  CacheHealth({
    required this.status,
    required this.healthy,
    required this.timestamp,
    this.error,
  });

  factory CacheHealth.fromJson(Map<String, dynamic> json) {
    return CacheHealth(
      status: json['status'] ?? 'UNKNOWN',
      healthy: json['healthy'] ?? false,
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'healthy': healthy,
      'timestamp': timestamp,
      if (error != null) 'error': error,
    };
  }

  bool get isUp => status.toUpperCase() == 'UP' && healthy;
  bool get isDown => status.toUpperCase() == 'DOWN' || !healthy;
  
  DateTime get timestampDateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
