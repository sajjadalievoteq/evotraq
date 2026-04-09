// Helper function to parse dates with timezone information
DateTime _parseDateTime(String? dateStr) {
  if (dateStr == null) return DateTime.now();
  
  try {
    // Remove timezone name if present (e.g., [Asia/Dubai])
    String cleanedDate = dateStr.replaceAll(RegExp(r'\[.*?\]'), '');
    
    // Handle different timezone formats
    if (cleanedDate.contains('+') && !cleanedDate.endsWith('Z')) {
      // Extract just the main datetime part before timezone
      final parts = cleanedDate.split('+');
      if (parts.length >= 2) {
        String datePart = parts[0];
        String timezonePart = '+' + parts[1];
        
        // Try parsing with timezone first
        try {
          return DateTime.parse(datePart + timezonePart);
        } catch (e) {
          // If that fails, just use the date part
          return DateTime.parse(datePart);
        }
      }
    }
    
    // Handle Z timezone
    if (cleanedDate.endsWith('Z')) {
      return DateTime.parse(cleanedDate);
    }
    
    // Default parse
    return DateTime.parse(cleanedDate);
  } catch (e) {
    print('Error parsing date "$dateStr": $e');
    return DateTime.now();
  }
}

class StorageStatistics {
  final int totalEvents;
  final int totalPartitions;
  final double storageUsedGB;
  final double totalStorageCapacityGB;
  final double storageUtilizationPercent;
  final double compressionRatio;
  final Map<String, int> partitionDistribution;
  final Map<String, double> eventTypeDistribution;
  final double averagePartitionSize;
  final int archivedEventsCount;
  final DateTime lastArchiveDate;

  StorageStatistics({
    required this.totalEvents,
    required this.totalPartitions,
    required this.storageUsedGB,
    required this.totalStorageCapacityGB,
    required this.storageUtilizationPercent,
    required this.compressionRatio,
    required this.partitionDistribution,
    required this.eventTypeDistribution,
    required this.averagePartitionSize,
    required this.archivedEventsCount,
    required this.lastArchiveDate,
  });

  // Legacy getter for compatibility with overview status calculation
  double get storageUtilizationGB => storageUsedGB;

  factory StorageStatistics.fromJson(Map<String, dynamic> json) {
    return StorageStatistics(
      totalEvents: json['total_events'] ?? 0,
      totalPartitions: json['active_background_jobs'] ?? 0,
      storageUsedGB: (json['storage_used_gb'] ?? 0.0).toDouble(),
      totalStorageCapacityGB: (json['total_storage_capacity_gb'] ?? 100.0).toDouble(),
      storageUtilizationPercent: (json['storage_utilization_percent'] ?? 0.0).toDouble(),
      compressionRatio: (json['compression_ratio'] ?? 1.0).toDouble(),
      partitionDistribution: Map<String, int>.from(json['partition_distribution'] ?? {}),
      eventTypeDistribution: Map<String, double>.from(json['event_type_distribution'] ?? {}),
      averagePartitionSize: (json['average_partition_size_mb'] ?? 0.0).toDouble(),
      archivedEventsCount: json['archived_events_count'] ?? 0,
      lastArchiveDate: _parseDateTime(json['last_updated']),
    );
  }
}

class IntegrityStatistics {
  final double overallIntegrityScore;
  final int totalEventsWithHashes;
  final int totalEventsWithSignatures;
  final double hashCoveragePercentage;
  final double signatureCoveragePercentage;
  final int auditTrailCount;
  final int immutableEventsCount;
  final Map<String, int> integrityByEventType;
  final List<IntegrityViolation> recentViolations;
  final DateTime lastIntegrityCheck;

  IntegrityStatistics({
    required this.overallIntegrityScore,
    required this.totalEventsWithHashes,
    required this.totalEventsWithSignatures,
    required this.hashCoveragePercentage,
    required this.signatureCoveragePercentage,
    required this.auditTrailCount,
    required this.immutableEventsCount,
    required this.integrityByEventType,
    required this.recentViolations,
    required this.lastIntegrityCheck,
  });

  factory IntegrityStatistics.fromJson(Map<String, dynamic> json) {
    return IntegrityStatistics(
      overallIntegrityScore: (json['overall_integrity_score'] ?? 0.0).toDouble(),
      totalEventsWithHashes: json['total_events'] ?? 0,
      totalEventsWithSignatures: json['signed_events'] ?? 0,
      hashCoveragePercentage: (json['integrity_coverage'] ?? 0.0).toDouble(),
      signatureCoveragePercentage: (json['signature_coverage'] ?? 0.0).toDouble(),
      auditTrailCount: json['events_with_audit_trail'] ?? 0,
      immutableEventsCount: json['immutable_events'] ?? 0,
      integrityByEventType: Map<String, int>.from(json['integrity_by_event_type'] ?? {}),
      recentViolations: (json['recent_violations'] as List? ?? [])
          .map((v) => IntegrityViolation.fromJson(v))
          .toList(),
      lastIntegrityCheck: _parseDateTime(json['last_verification']),
    );
  }
}

class IntegrityViolation {
  final String eventId;
  final String eventType;
  final String violationType;
  final String description;
  final DateTime detectedAt;
  final String severity;

  IntegrityViolation({
    required this.eventId,
    required this.eventType,
    required this.violationType,
    required this.description,
    required this.detectedAt,
    required this.severity,
  });

  factory IntegrityViolation.fromJson(Map<String, dynamic> json) {
    return IntegrityViolation(
      eventId: json['event_id'] ?? '',
      eventType: json['event_type'] ?? '',
      violationType: json['violation_type'] ?? '',
      description: json['description'] ?? '',
      detectedAt: _parseDateTime(json['detected_at']),
      severity: json['severity'] ?? 'LOW',
    );
  }
}

class PerformanceMetrics {
  final double eventsPerSecond;
  final double averageProcessingTimeMs;
  final double databaseConnectionUtilization;
  final double memoryUsagePercentage;
  final double cpuUsagePercentage;
  final int activeConnections;
  final int queuedTransactions;
  final double successRate;
  final double errorRate;
  final Map<String, EventTypeMetrics> eventTypeMetrics;
  final List<PerformanceAlert> activeAlerts;
  final DateTime timestamp;

  PerformanceMetrics({
    required this.eventsPerSecond,
    required this.averageProcessingTimeMs,
    required this.databaseConnectionUtilization,
    required this.memoryUsagePercentage,
    required this.cpuUsagePercentage,
    required this.activeConnections,
    required this.queuedTransactions,
    required this.successRate,
    required this.errorRate,
    required this.eventTypeMetrics,
    required this.activeAlerts,
    required this.timestamp,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      eventsPerSecond: (json['transaction_throughput'] ?? 0.0).toDouble(),
      averageProcessingTimeMs: (json['avg_query_time_ms'] ?? 0.0).toDouble(),
      databaseConnectionUtilization: (json['cache_hit_ratio'] ?? 0.0).toDouble(),
      memoryUsagePercentage: (json['index_utilization'] ?? 0.0).toDouble() * 100,
      cpuUsagePercentage: (json['cpu_usage_percentage'] ?? 0.0).toDouble(),
      activeConnections: json['active_connections'] ?? 0,
      queuedTransactions: json['deadlock_count'] ?? 0,
      successRate: (json['success_rate'] ?? 95.0).toDouble(),
      errorRate: (json['error_rate'] ?? 5.0).toDouble(),
      eventTypeMetrics: (json['event_type_metrics'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, EventTypeMetrics.fromJson(value))),
      activeAlerts: (json['active_alerts'] as List? ?? [])
          .map((alert) => PerformanceAlert.fromJson(alert))
          .toList(),
      timestamp: _parseDateTime(json['timestamp']),
    );
  }
}

class EventTypeMetrics {
  final String eventType;
  final double eventsPerSecond;
  final double averageProcessingTime;
  final double successRate;
  final int totalProcessed;
  final int totalErrors;

  EventTypeMetrics({
    required this.eventType,
    required this.eventsPerSecond,
    required this.averageProcessingTime,
    required this.successRate,
    required this.totalProcessed,
    required this.totalErrors,
  });

  factory EventTypeMetrics.fromJson(Map<String, dynamic> json) {
    return EventTypeMetrics(
      eventType: json['event_type'] ?? '',
      eventsPerSecond: (json['events_per_second'] ?? 0.0).toDouble(),
      averageProcessingTime: (json['average_processing_time'] ?? 0.0).toDouble(),
      successRate: (json['success_rate'] ?? 0.0).toDouble(),
      totalProcessed: json['total_processed'] ?? 0,
      totalErrors: json['total_errors'] ?? 0,
    );
  }
}

class PerformanceAlert {
  final String id;
  final String type;
  final String severity;
  final String message;
  final DateTime triggeredAt;
  final Map<String, dynamic> details;
  final bool acknowledged;

  PerformanceAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.triggeredAt,
    required this.details,
    required this.acknowledged,
  });

  factory PerformanceAlert.fromJson(Map<String, dynamic> json) {
    return PerformanceAlert(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'INFO',
      message: json['message'] ?? '',
      triggeredAt: _parseDateTime(json['triggered_at']),
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      acknowledged: json['acknowledged'] ?? false,
    );
  }
}

class BulkJobStatus {
  final String jobId;
  final String jobType;
  final String status;
  final int totalEvents;
  final int processedEvents;
  final int failedEvents;
  final double progressPercentage;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> errors;
  final Map<String, dynamic> metadata;

  BulkJobStatus({
    required this.jobId,
    required this.jobType,
    required this.status,
    required this.totalEvents,
    required this.processedEvents,
    required this.failedEvents,
    required this.progressPercentage,
    required this.startTime,
    this.endTime,
    required this.errors,
    required this.metadata,
  });

  factory BulkJobStatus.fromJson(Map<String, dynamic> json) {
    return BulkJobStatus(
      jobId: json['operation_id'] ?? '',
      jobType: json['job_type'] ?? '',
      status: json['status'] ?? '',
      totalEvents: json['total_events'] ?? 0,
      processedEvents: json['processed_events'] ?? 0,
      failedEvents: json['failed_events'] ?? 0,
      progressPercentage: ((json['processed_events'] ?? 0) / (json['total_events'] ?? 1) * 100).toDouble(),
      startTime: _parseDateTime(json['start_time']),
      endTime: json['end_time'] != null ? _parseDateTime(json['end_time']) : null,
      errors: (json['errors'] as List? ?? []).map((e) => e.toString()).toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
