/// Data models for Database Partitioning according to Phase 3.1 requirements

class PartitionMetadata {
  final int? id;
  final String tableName;
  final String partitionName;
  final String partitionType; // 'TIME_BASED', 'EVENT_TYPE', 'HYBRID'
  final String? partitionKey;
  final String? partitionExpression;
  final String? startRange;
  final String? endRange;
  final DateTime? creationDate;
  final DateTime? lastMaintenance;
  final int recordCount;
  final int sizeBytes;
  final double? sizeMb;
  final bool compressionEnabled;
  final bool archived;
  final DateTime? archiveDate;
  final String status; // 'ACTIVE', 'ARCHIVED', 'DROPPED'

  PartitionMetadata({
    this.id,
    required this.tableName,
    required this.partitionName,
    required this.partitionType,
    this.partitionKey,
    this.partitionExpression,
    this.startRange,
    this.endRange,
    this.creationDate,
    this.lastMaintenance,
    required this.recordCount,
    required this.sizeBytes,
    this.sizeMb,
    required this.compressionEnabled,
    required this.archived,
    this.archiveDate,
    required this.status,
  });

  factory PartitionMetadata.fromJson(Map<String, dynamic> json) {
    return PartitionMetadata(
      id: json['id'],
      tableName: json['table_name'] ?? '',
      partitionName: json['partition_name'] ?? '',
      partitionType: json['partition_type'] ?? '',
      partitionKey: json['partition_key'],
      partitionExpression: json['partition_expression'],
      startRange: json['start_range'],
      endRange: json['end_range'],
      creationDate: json['creation_date'] != null 
          ? DateTime.parse(json['creation_date']) 
          : null,
      lastMaintenance: json['last_maintenance'] != null 
          ? DateTime.parse(json['last_maintenance']) 
          : null,
      recordCount: json['record_count'] ?? 0,
      sizeBytes: json['size_bytes'] ?? 0,
      sizeMb: json['size_mb']?.toDouble(),
      compressionEnabled: json['compression_enabled'] ?? false,
      archived: json['archived'] ?? false,
      archiveDate: json['archive_date'] != null 
          ? DateTime.parse(json['archive_date']) 
          : null,
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_name': tableName,
      'partition_name': partitionName,
      'partition_type': partitionType,
      'partition_key': partitionKey,
      'partition_expression': partitionExpression,
      'start_range': startRange,
      'end_range': endRange,
      'creation_date': creationDate?.toIso8601String(),
      'last_maintenance': lastMaintenance?.toIso8601String(),
      'record_count': recordCount,
      'size_bytes': sizeBytes,
      'size_mb': sizeMb,
      'compression_enabled': compressionEnabled,
      'archived': archived,
      'archive_date': archiveDate?.toIso8601String(),
      'status': status,
    };
  }
}

class PartitionStatistics {
  final int totalPartitions;
  final int activePartitions;
  final int archivedPartitions;
  final int totalRecords;
  final int totalSizeBytes;
  final double? totalSizeMb;
  final double? totalSizeGb;
  final double? averagePartitionSizeMb;
  final double? compressionRatio;
  final double? archiveSavingsMb;
  final Map<String, int> partitionDistribution;
  final Map<String, int> partitionTypes;
  final Map<String, int> monthlyGrowth;
  final List<PartitionMetadata> largestPartitions;
  final List<String> maintenanceRecommendations;
  final Map<String, dynamic> performanceMetrics;
  final String healthStatus; // 'HEALTHY', 'WARNING', 'CRITICAL'
  final DateTime lastUpdated;

  PartitionStatistics({
    required this.totalPartitions,
    required this.activePartitions,
    required this.archivedPartitions,
    required this.totalRecords,
    required this.totalSizeBytes,
    this.totalSizeMb,
    this.totalSizeGb,
    this.averagePartitionSizeMb,
    this.compressionRatio,
    this.archiveSavingsMb,
    required this.partitionDistribution,
    required this.partitionTypes,
    required this.monthlyGrowth,
    required this.largestPartitions,
    required this.maintenanceRecommendations,
    required this.performanceMetrics,
    required this.healthStatus,
    required this.lastUpdated,
  });

  factory PartitionStatistics.fromJson(Map<String, dynamic> json) {
    return PartitionStatistics(
      totalPartitions: json['total_partitions'] ?? 0,
      activePartitions: json['active_partitions'] ?? 0,
      archivedPartitions: json['archived_partitions'] ?? 0,
      totalRecords: json['total_records'] ?? 0,
      totalSizeBytes: json['total_size_bytes'] ?? 0,
      totalSizeMb: json['total_size_mb']?.toDouble(),
      totalSizeGb: json['total_size_gb']?.toDouble(),
      averagePartitionSizeMb: json['average_partition_size_mb']?.toDouble(),
      compressionRatio: json['compression_ratio']?.toDouble(),
      archiveSavingsMb: json['archive_savings_mb']?.toDouble(),
      partitionDistribution: Map<String, int>.from(
        json['partition_distribution'] ?? {}
      ),
      partitionTypes: Map<String, int>.from(
        json['partition_types'] ?? {}
      ),
      monthlyGrowth: Map<String, int>.from(
        json['monthly_growth'] ?? {}
      ),
      largestPartitions: (json['largest_partitions'] as List?)
          ?.map((item) => PartitionMetadata.fromJson(item))
          .toList() ?? [],
      maintenanceRecommendations: List<String>.from(
        json['maintenance_recommendations'] ?? []
      ),
      performanceMetrics: Map<String, dynamic>.from(
        json['performance_metrics'] ?? {}
      ),
      healthStatus: json['health_status'] ?? 'HEALTHY',
      lastUpdated: json['last_updated'] != null 
          ? DateTime.parse(json['last_updated']) 
          : DateTime.now(),
    );
  }
}

class ArchiveMetadata {
  final int? id;
  final String originalTable;
  final String archiveTable;
  final String? archiveLocation;
  final DateTime startDate;
  final DateTime endDate;
  final int recordCount;
  final int originalSizeBytes;
  final double? originalSizeMb;
  final int? compressedSizeBytes;
  final double? compressedSizeMb;
  final double? compressionRatio;
  final DateTime archiveDate;
  final int retrievalCount;
  final DateTime? lastAccessed;
  final String? checksum;
  final String status; // 'ARCHIVED', 'VERIFIED', 'CORRUPTED'
  final double? spaceSavingsPercent;

  ArchiveMetadata({
    this.id,
    required this.originalTable,
    required this.archiveTable,
    this.archiveLocation,
    required this.startDate,
    required this.endDate,
    required this.recordCount,
    required this.originalSizeBytes,
    this.originalSizeMb,
    this.compressedSizeBytes,
    this.compressedSizeMb,
    this.compressionRatio,
    required this.archiveDate,
    required this.retrievalCount,
    this.lastAccessed,
    this.checksum,
    required this.status,
    this.spaceSavingsPercent,
  });

  factory ArchiveMetadata.fromJson(Map<String, dynamic> json) {
    return ArchiveMetadata(
      id: json['id'],
      originalTable: json['original_table'] ?? '',
      archiveTable: json['archive_table'] ?? '',
      archiveLocation: json['archive_location'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      recordCount: json['record_count'] ?? 0,
      originalSizeBytes: json['original_size_bytes'] ?? 0,
      originalSizeMb: json['original_size_mb']?.toDouble(),
      compressedSizeBytes: json['compressed_size_bytes'],
      compressedSizeMb: json['compressed_size_mb']?.toDouble(),
      compressionRatio: json['compression_ratio']?.toDouble(),
      archiveDate: DateTime.parse(json['archive_date']),
      retrievalCount: json['retrieval_count'] ?? 0,
      lastAccessed: json['last_accessed'] != null 
          ? DateTime.parse(json['last_accessed']) 
          : null,
      checksum: json['checksum'],
      status: json['status'] ?? 'ARCHIVED',
      spaceSavingsPercent: json['space_savings_percent']?.toDouble(),
    );
  }
}

class PartitionMaintenance {
  final String operationId;
  final String maintenanceType; // 'REINDEX', 'VACUUM', 'ANALYZE', 'COMPRESS', 'ARCHIVE'
  final String? targetTable;
  final List<String> targetPartitions;
  final String operationStatus; // 'SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'CANCELLED'
  final DateTime? startTime;
  final DateTime? endTime;
  final int? durationSeconds;
  final int? recordsProcessed;
  final int? partitionsProcessed;
  final double progressPercentage;
  final String? errorMessage;
  final List<String> warnings;
  final double? spaceSavedMb;
  final double? compressionRatio;
  final List<MaintenanceResult> maintenanceResults;
  final String? performedBy;
  final bool scheduled;
  final DateTime? nextScheduledRun;

  PartitionMaintenance({
    required this.operationId,
    required this.maintenanceType,
    this.targetTable,
    required this.targetPartitions,
    required this.operationStatus,
    this.startTime,
    this.endTime,
    this.durationSeconds,
    this.recordsProcessed,
    this.partitionsProcessed,
    required this.progressPercentage,
    this.errorMessage,
    required this.warnings,
    this.spaceSavedMb,
    this.compressionRatio,
    required this.maintenanceResults,
    this.performedBy,
    required this.scheduled,
    this.nextScheduledRun,
  });

  factory PartitionMaintenance.fromJson(Map<String, dynamic> json) {
    return PartitionMaintenance(
      operationId: json['operation_id'] ?? '',
      maintenanceType: json['maintenance_type'] ?? '',
      targetTable: json['target_table'],
      targetPartitions: List<String>.from(json['target_partitions'] ?? []),
      operationStatus: json['operation_status'] ?? 'SCHEDULED',
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : null,
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time']) 
          : null,
      durationSeconds: json['duration_seconds'],
      recordsProcessed: json['records_processed'],
      partitionsProcessed: json['partitions_processed'],
      progressPercentage: json['progress_percentage']?.toDouble() ?? 0.0,
      errorMessage: json['error_message'],
      warnings: List<String>.from(json['warnings'] ?? []),
      spaceSavedMb: json['space_saved_mb']?.toDouble(),
      compressionRatio: json['compression_ratio']?.toDouble(),
      maintenanceResults: (json['maintenance_results'] as List?)
          ?.map((item) => MaintenanceResult.fromJson(item))
          .toList() ?? [],
      performedBy: json['performed_by'],
      scheduled: json['scheduled'] ?? false,
      nextScheduledRun: json['next_scheduled_run'] != null 
          ? DateTime.parse(json['next_scheduled_run']) 
          : null,
    );
  }
}

class MaintenanceResult {
  final String partitionName;
  final String operation;
  final String status;
  final int? durationMs;
  final double? beforeSizeMb;
  final double? afterSizeMb;
  final int? recordsAffected;
  final String? message;

  MaintenanceResult({
    required this.partitionName,
    required this.operation,
    required this.status,
    this.durationMs,
    this.beforeSizeMb,
    this.afterSizeMb,
    this.recordsAffected,
    this.message,
  });

  factory MaintenanceResult.fromJson(Map<String, dynamic> json) {
    return MaintenanceResult(
      partitionName: json['partition_name'] ?? '',
      operation: json['operation'] ?? '',
      status: json['status'] ?? '',
      durationMs: json['duration_ms'],
      beforeSizeMb: json['before_size_mb']?.toDouble(),
      afterSizeMb: json['after_size_mb']?.toDouble(),
      recordsAffected: json['records_affected'],
      message: json['message'],
    );
  }
}
