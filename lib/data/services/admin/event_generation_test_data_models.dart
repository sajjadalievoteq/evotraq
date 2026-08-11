class TestEnvironment {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastModified;
  final Map<String, dynamic> configuration;
  final TestDataStatistics? statistics;

  TestEnvironment({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    this.lastModified,
    required this.configuration,
    this.statistics,
  });

  factory TestEnvironment.fromJson(Map<String, dynamic> json) {
    return TestEnvironment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : null,
      configuration: Map<String, dynamic>.from(json['configuration']),
      statistics: json['statistics'] != null
          ? TestDataStatistics.fromJson(json['statistics'])
          : null,
    );
  }
}

class TestDataset {
  final String id;
  final String name;
  final String description;
  final int eventCount;
  final DateTime createdAt;
  final String createdBy;
  final bool isShared;
  final List<String> sharedWith;
  final Map<String, int> eventTypeCounts;
  final String status;

  TestDataset({
    required this.id,
    required this.name,
    required this.description,
    required this.eventCount,
    required this.createdAt,
    required this.createdBy,
    required this.isShared,
    required this.sharedWith,
    required this.eventTypeCounts,
    required this.status,
  });

  factory TestDataset.fromJson(Map<String, dynamic> json) {
    return TestDataset(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      eventCount: json['eventCount'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      isShared: json['isShared'],
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      eventTypeCounts: Map<String, int>.from(json['eventTypeCounts']),
      status: json['status'],
    );
  }
}

class DatasetLoadResult {
  final String datasetId;
  final int loadedEvents;
  final String status;
  final DateTime loadTime;
  final int durationMs;
  final Map<String, dynamic>? error;

  DatasetLoadResult({
    required this.datasetId,
    required this.loadedEvents,
    required this.status,
    required this.loadTime,
    required this.durationMs,
    this.error,
  });

  factory DatasetLoadResult.fromJson(Map<String, dynamic> json) {
    return DatasetLoadResult(
      datasetId: json['datasetId'],
      loadedEvents: json['loadedEvents'],
      status: json['status'],
      loadTime: DateTime.parse(json['loadTime']),
      durationMs: json['durationMs'],
      error: json['error'],
    );
  }
}

class CleanupResult {
  final int deletedEvents;
  final int deletedGLNs;
  final int deletedGTINs;
  final String status;
  final DateTime cleanupTime;
  final int durationMs;
  final Map<String, int> deletionCounts;

  CleanupResult({
    required this.deletedEvents,
    required this.deletedGLNs,
    required this.deletedGTINs,
    required this.status,
    required this.cleanupTime,
    required this.durationMs,
    required this.deletionCounts,
  });

  factory CleanupResult.fromJson(Map<String, dynamic> json) {
    return CleanupResult(
      deletedEvents: json['deletedEvents'],
      deletedGLNs: json['deletedGLNs'],
      deletedGTINs: json['deletedGTINs'],
      status: json['status'],
      cleanupTime: DateTime.parse(json['cleanupTime']),
      durationMs: json['durationMs'],
      deletionCounts: Map<String, int>.from(json['deletionCounts']),
    );
  }
}

class DataSnapshot {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final String createdBy;
  final TestDataStatistics statistics;
  final String status;
  final int sizeBytes;

  DataSnapshot({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    required this.statistics,
    required this.status,
    required this.sizeBytes,
  });

  factory DataSnapshot.fromJson(Map<String, dynamic> json) {
    return DataSnapshot(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      statistics: TestDataStatistics.fromJson(json['statistics']),
      status: json['status'],
      sizeBytes: json['sizeBytes'],
    );
  }
}

class RestoreResult {
  final String snapshotId;
  final int restoredEvents;
  final int restoredGLNs;
  final int restoredGTINs;
  final String status;
  final DateTime restoreTime;
  final int durationMs;
  final Map<String, int> restorationCounts;

  RestoreResult({
    required this.snapshotId,
    required this.restoredEvents,
    required this.restoredGLNs,
    required this.restoredGTINs,
    required this.status,
    required this.restoreTime,
    required this.durationMs,
    required this.restorationCounts,
  });

  factory RestoreResult.fromJson(Map<String, dynamic> json) {
    return RestoreResult(
      snapshotId: json['snapshotId'],
      restoredEvents: json['restoredEvents'],
      restoredGLNs: json['restoredGLNs'],
      restoredGTINs: json['restoredGTINs'],
      status: json['status'],
      restoreTime: DateTime.parse(json['restoreTime']),
      durationMs: json['durationMs'],
      restorationCounts: Map<String, int>.from(json['restorationCounts']),
    );
  }
}

class ArchiveResult {
  final String archiveId;
  final int archivedEvents;
  final int archivedGLNs;
  final int archivedGTINs;
  final String status;
  final DateTime archiveTime;
  final int durationMs;
  final int archiveSizeBytes;
  final String archivePath;

  ArchiveResult({
    required this.archiveId,
    required this.archivedEvents,
    required this.archivedGLNs,
    required this.archivedGTINs,
    required this.status,
    required this.archiveTime,
    required this.durationMs,
    required this.archiveSizeBytes,
    required this.archivePath,
  });

  factory ArchiveResult.fromJson(Map<String, dynamic> json) {
    return ArchiveResult(
      archiveId: json['archiveId'],
      archivedEvents: json['archivedEvents'],
      archivedGLNs: json['archivedGLNs'],
      archivedGTINs: json['archivedGTINs'],
      status: json['status'],
      archiveTime: DateTime.parse(json['archiveTime']),
      durationMs: json['durationMs'],
      archiveSizeBytes: json['archiveSizeBytes'],
      archivePath: json['archivePath'],
    );
  }
}

class TestDataStatistics {
  final int totalEvents;
  final int totalGLNs;
  final int totalGTINs;
  final int totalSGTINs;
  final int totalSSCCs;
  final Map<String, int> eventTypeCounts;
  final Map<String, int> masterDataDistribution;
  final DateTime? oldestEvent;
  final DateTime? newestEvent;
  final int dataSizeBytes;
  final Map<String, dynamic> additionalMetrics;

  TestDataStatistics({
    required this.totalEvents,
    required this.totalGLNs,
    required this.totalGTINs,
    required this.totalSGTINs,
    required this.totalSSCCs,
    required this.eventTypeCounts,
    required this.masterDataDistribution,
    this.oldestEvent,
    this.newestEvent,
    required this.dataSizeBytes,
    required this.additionalMetrics,
  });

  factory TestDataStatistics.fromJson(Map<String, dynamic> json) {
    return TestDataStatistics(
      totalEvents: json['totalEvents'] ?? 0,
      totalGLNs: json['totalGLNs'] ?? 0,
      totalGTINs: json['totalGTINs'] ?? 0,
      totalSGTINs: json['totalSGTINs'] ?? 0,
      totalSSCCs: json['totalSSCCs'] ?? 0,
      eventTypeCounts: Map<String, int>.from(json['eventTypeCounts'] ?? {}),
      masterDataDistribution: Map<String, int>.from(
        json['masterDataDistribution'] ?? {},
      ),
      oldestEvent: json['oldestEvent'] != null
          ? DateTime.parse(json['oldestEvent'])
          : null,
      newestEvent: json['newestEvent'] != null
          ? DateTime.parse(json['newestEvent'])
          : null,
      dataSizeBytes: json['dataSizeBytes'] ?? 0,
      additionalMetrics: Map<String, dynamic>.from(
        json['additionalMetrics'] ?? {},
      ),
    );
  }
}
