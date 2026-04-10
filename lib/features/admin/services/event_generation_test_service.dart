import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

/// Service for event generation test functionality
/// Provides API access to test event generation, simulation, and data management
class EventGenerationTestService {
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  EventGenerationTestService({
    required AppConfig appConfig,
  }) : _tokenManager = TokenManager(),
        _appConfig = appConfig;

  /// Make authenticated GET request
  Future<Map<String, dynamic>> _getWithAuth(String path) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('${_appConfig.apiBaseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  /// Make authenticated POST request
  Future<Map<String, dynamic>> _postWithAuth(String path, Map<String, dynamic> body) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('${_appConfig.apiBaseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  /// Make authenticated DELETE request
  Future<Map<String, dynamic>> _deleteWithAuth(String path) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      Uri.parse('${_appConfig.apiBaseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to delete: ${response.statusCode}');
    }
  }

  // Event Generation Methods
  
  /// Generate single test event
  Future<Map<String, dynamic>> generateSingleEvent(String eventType, Map<String, dynamic> params) async {
    return await _postWithAuth('/admin/event-generation-tests/generate/$eventType', params);
  }
  
  /// Generate bulk test events
  Future<BulkGenerationResult> generateBulkEvents(String eventType, int count, Map<String, dynamic> params) async {
    final requestBody = {
      'count': count,
      ...params,
    };
    final json = await _postWithAuth('/admin/event-generation-tests/generate-bulk/$eventType', requestBody);
    return BulkGenerationResult.fromJson(json);
  }

  // Event Simulation Methods
  
  /// Start supply chain simulation
  Future<SimulationSession> startSupplyChainSimulation(Map<String, dynamic> params) async {
    final json = await _postWithAuth('/admin/event-generation-tests/simulation/supply-chain/start', params);
    return SimulationSession.fromJson(json);
  }
  
  /// Stop supply chain simulation
  Future<SimulationResult> stopSupplyChainSimulation(String sessionId) async {
    final json = await _postWithAuth('/admin/event-generation-tests/simulation/supply-chain/stop', {'sessionId': sessionId});
    return SimulationResult.fromJson(json);
  }
  
  /// Get simulation status
  Future<SimulationStatus> getSimulationStatus(String sessionId) async {
    final json = await _getWithAuth('/admin/event-generation-tests/simulation/$sessionId/status');
    return SimulationStatus.fromJson(json);
  }
  
  /// Start real-time event generation
  Future<RealTimeGenerationSession> startRealTimeGeneration(Map<String, dynamic> params) async {
    final json = await _postWithAuth('/admin/event-generation-tests/real-time/start', params);
    return RealTimeGenerationSession.fromJson(json);
  }
  
  /// Stop real-time event generation
  Future<RealTimeGenerationResult> stopRealTimeGeneration(String sessionId) async {
    final json = await _postWithAuth('/admin/event-generation-tests/real-time/stop', {'sessionId': sessionId});
    return RealTimeGenerationResult.fromJson(json);
  }
  
  /// Generate time-compressed sequence
  Future<TimeCompressedSequenceResult> generateTimeCompressedSequence(Map<String, dynamic> params) async {
    final json = await _postWithAuth('/admin/event-generation-tests/time-compressed', params);
    return TimeCompressedSequenceResult.fromJson(json);
  }
  
  /// Generate randomized variations
  Future<RandomizedVariationResult> generateRandomizedVariations(Map<String, dynamic> params) async {
    final json = await _postWithAuth('/admin/event-generation-tests/randomized', params);
    return RandomizedVariationResult.fromJson(json);
  }
  
  /// Inject anomalies
  Future<AnomalyInjectionResult> injectAnomalies(Map<String, dynamic> params) async {
    final json = await _postWithAuth('/admin/event-generation-tests/inject-anomalies', params);
    return AnomalyInjectionResult.fromJson(json);
  }

  // Test Data Management Methods
  
  /// Create test environment
  Future<TestEnvironment> createTestEnvironment(String name, Map<String, dynamic> params) async {
    final requestBody = {
      'name': name,
      ...params,
    };
    final json = await _postWithAuth('/admin/event-generation-tests/test-environment', requestBody);
    return TestEnvironment.fromJson(json);
  }
  
  /// Get test environments
  Future<List<TestEnvironment>> getTestEnvironments() async {
    final json = await _getWithAuth('/admin/event-generation-tests/test-environments');
    return (json['environments'] as List)
        .map((env) => TestEnvironment.fromJson(env))
        .toList();
  }
  
  /// Switch to test environment
  Future<void> switchToTestEnvironment(String environmentId) async {
    await _postWithAuth('/admin/event-generation-tests/test-environment/$environmentId/switch', {});
  }
  
  /// Delete test environment
  Future<void> deleteTestEnvironment(String environmentId) async {
    await _deleteWithAuth('/admin/event-generation-tests/test-environment/$environmentId');
  }
  
  /// Create test dataset
  Future<TestDataset> createTestDataset(String name, String description, Map<String, dynamic> params) async {
    final requestBody = {
      'name': name,
      'description': description,
      ...params,
    };
    final json = await _postWithAuth('/admin/event-generation-tests/test-dataset', requestBody);
    return TestDataset.fromJson(json);
  }
  
  /// Get test datasets
  Future<List<TestDataset>> getTestDatasets() async {
    final json = await _getWithAuth('/admin/event-generation-tests/test-datasets');
    return (json['datasets'] as List)
        .map((dataset) => TestDataset.fromJson(dataset))
        .toList();
  }
  
  /// Load test dataset
  Future<DatasetLoadResult> loadTestDataset(String datasetId) async {
    final json = await _postWithAuth('/admin/event-generation-tests/test-dataset/$datasetId/load', {});
    return DatasetLoadResult.fromJson(json);
  }
  
  /// Share test dataset
  Future<void> shareTestDataset(String datasetId, String userId) async {
    await _postWithAuth('/admin/event-generation-tests/test-dataset/$datasetId/share', {'userId': userId});
  }
  
  /// Delete test dataset
  Future<void> deleteTestDataset(String datasetId) async {
    await _deleteWithAuth('/admin/event-generation-tests/test-dataset/$datasetId');
  }
  
  /// Clean test data
  Future<CleanupResult> cleanTestData(Map<String, dynamic> params) async {
    final json = await _postWithAuth('/admin/event-generation-tests/cleanup', params);
    return CleanupResult.fromJson(json);
  }

  /// Clean transformation event test data
  Future<Map<String, dynamic>> cleanTransformationEvents() async {
    final json = await _postWithAuth('/admin/event-generation-tests/cleanup/transformation-events', {});
    return json;
  }

  /// Clean transaction event test data
  Future<Map<String, dynamic>> cleanTransactionEvents() async {
    final json = await _postWithAuth('/admin/event-generation-tests/cleanup/transaction-events', {});
    return json;
  }

  /// Clean aggregation event test data
  Future<Map<String, dynamic>> cleanAggregationEvents() async {
    final json = await _postWithAuth('/admin/event-generation-tests/cleanup/aggregation-events', {});
    return json;
  }

  /// Clean object event test data
  Future<Map<String, dynamic>> cleanObjectEvents() async {
    final json = await _postWithAuth('/admin/event-generation-tests/cleanup/object-events', {});
    return json;
  }

  /// Clean GLN test data (location names starting with "Test Location")
  Future<Map<String, dynamic>> cleanGLNTestData() async {
    final json = await _postWithAuth('/admin/event-generation-tests/cleanup/gln-test-data', {});
    return json;
  }

  /// Clean GTIN test data (product names starting with "Test Product")
  Future<Map<String, dynamic>> cleanGTINTestData() async {
    final json = await _postWithAuth('/admin/event-generation-tests/cleanup/gtin-test-data', {});
    return json;
  }

  /// Clean SGTIN test data (batch lot numbers starting with "TEST-BATCH-")
  Future<Map<String, dynamic>> cleanSGTINTestData() async {
    final json = await _postWithAuth('/admin/event-generation-tests/cleanup/sgtin-test-data', {});
    return json;
  }

  /// Clean SSCC test data (GS1 company prefix matches pharmaceutical test companies)
  Future<Map<String, dynamic>> cleanSSCCTestData() async {
    final json = await _postWithAuth('/admin/event-generation-tests/cleanup/sscc-test-data', {});
    return json;
  }

  /// DANGER - Clean ALL SSCC data from system (not just test data!)
  Future<Map<String, dynamic>> cleanAllSSCCData() async {
    final json = await _postWithAuth('/admin/event-generation-tests/cleanup/all-sscc-data', {});
    return json;
  }
  
  /// Create data snapshot
  Future<DataSnapshot> createDataSnapshot(String name, Map<String, dynamic> params) async {
    final requestBody = {
      'name': name,
      ...params,
    };
    final json = await _postWithAuth('/admin/event-generation-tests/snapshot', requestBody);
    return DataSnapshot.fromJson(json);
  }
  
  /// Get data snapshots
  Future<List<DataSnapshot>> getDataSnapshots() async {
    final json = await _getWithAuth('/admin/event-generation-tests/snapshots');
    return (json['snapshots'] as List)
        .map((snapshot) => DataSnapshot.fromJson(snapshot))
        .toList();
  }
  
  /// Restore data snapshot
  Future<RestoreResult> restoreDataSnapshot(String snapshotId) async {
    final json = await _postWithAuth('/admin/event-generation-tests/snapshot/$snapshotId/restore', {});
    return RestoreResult.fromJson(json);
  }
  
  /// Delete data snapshot
  Future<void> deleteDataSnapshot(String snapshotId) async {
    await _deleteWithAuth('/admin/event-generation-tests/snapshot/$snapshotId');
  }
  
  /// Archive test data
  Future<ArchiveResult> archiveTestData(Map<String, dynamic> params) async {
    final json = await _postWithAuth('/admin/event-generation-tests/archive', params);
    return ArchiveResult.fromJson(json);
  }
  
  /// Get data statistics
  Future<TestDataStatistics> getTestDataStatistics() async {
    final json = await _getWithAuth('/admin/event-generation-tests/statistics');
    return TestDataStatistics.fromJson(json);
  }
}

// Data Models

class BulkGenerationResult {
  final String sessionId;
  final int generatedCount;
  final String status;
  final List<String> eventIds;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic>? error;

  BulkGenerationResult({
    required this.sessionId,
    required this.generatedCount,
    required this.status,
    required this.eventIds,
    required this.startTime,
    this.endTime,
    this.error,
  });

  factory BulkGenerationResult.fromJson(Map<String, dynamic> json) {
    return BulkGenerationResult(
      sessionId: json['sessionId'],
      generatedCount: json['generatedCount'],
      status: json['status'],
      eventIds: List<String>.from(json['eventIds'] ?? []),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      error: json['error'],
    );
  }
}

class SimulationSession {
  final String sessionId;
  final String type;
  final String status;
  final Map<String, dynamic> parameters;
  final DateTime startTime;
  final DateTime? endTime;

  SimulationSession({
    required this.sessionId,
    required this.type,
    required this.status,
    required this.parameters,
    required this.startTime,
    this.endTime,
  });

  factory SimulationSession.fromJson(Map<String, dynamic> json) {
    return SimulationSession(
      sessionId: json['sessionId'],
      type: json['type'],
      status: json['status'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}

class SimulationResult {
  final String sessionId;
  final int totalEvents;
  final Map<String, int> eventCounts;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMs;

  SimulationResult({
    required this.sessionId,
    required this.totalEvents,
    required this.eventCounts,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.durationMs,
  });

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      sessionId: json['sessionId'],
      totalEvents: json['totalEvents'],
      eventCounts: Map<String, int>.from(json['eventCounts']),
      status: json['status'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationMs: json['durationMs'],
    );
  }
}

class SimulationStatus {
  final String sessionId;
  final String status;
  final int currentEvents;
  final double progressPercentage;
  final DateTime? estimatedCompletion;
  final Map<String, dynamic>? currentMetrics;

  SimulationStatus({
    required this.sessionId,
    required this.status,
    required this.currentEvents,
    required this.progressPercentage,
    this.estimatedCompletion,
    this.currentMetrics,
  });

  factory SimulationStatus.fromJson(Map<String, dynamic> json) {
    return SimulationStatus(
      sessionId: json['sessionId'],
      status: json['status'],
      currentEvents: json['currentEvents'],
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      estimatedCompletion: json['estimatedCompletion'] != null 
          ? DateTime.parse(json['estimatedCompletion']) : null,
      currentMetrics: json['currentMetrics'],
    );
  }
}

class RealTimeGenerationSession {
  final String sessionId;
  final String status;
  final int eventsPerSecond;
  final Map<String, dynamic> parameters;
  final DateTime startTime;

  RealTimeGenerationSession({
    required this.sessionId,
    required this.status,
    required this.eventsPerSecond,
    required this.parameters,
    required this.startTime,
  });

  factory RealTimeGenerationSession.fromJson(Map<String, dynamic> json) {
    return RealTimeGenerationSession(
      sessionId: json['sessionId'],
      status: json['status'],
      eventsPerSecond: json['eventsPerSecond'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      startTime: DateTime.parse(json['startTime']),
    );
  }
}

class RealTimeGenerationResult {
  final String sessionId;
  final int totalEvents;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final double averageEventsPerSecond;

  RealTimeGenerationResult({
    required this.sessionId,
    required this.totalEvents,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.averageEventsPerSecond,
  });

  factory RealTimeGenerationResult.fromJson(Map<String, dynamic> json) {
    return RealTimeGenerationResult(
      sessionId: json['sessionId'],
      totalEvents: json['totalEvents'],
      status: json['status'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      averageEventsPerSecond: (json['averageEventsPerSecond'] as num).toDouble(),
    );
  }
}

class TimeCompressedSequenceResult {
  final String sequenceId;
  final int totalEvents;
  final double compressionRatio;
  final DateTime originalStartTime;
  final DateTime originalEndTime;
  final DateTime compressedStartTime;
  final DateTime compressedEndTime;
  final List<String> eventIds;

  TimeCompressedSequenceResult({
    required this.sequenceId,
    required this.totalEvents,
    required this.compressionRatio,
    required this.originalStartTime,
    required this.originalEndTime,
    required this.compressedStartTime,
    required this.compressedEndTime,
    required this.eventIds,
  });

  factory TimeCompressedSequenceResult.fromJson(Map<String, dynamic> json) {
    return TimeCompressedSequenceResult(
      sequenceId: json['sequenceId'],
      totalEvents: json['totalEvents'],
      compressionRatio: (json['compressionRatio'] as num).toDouble(),
      originalStartTime: DateTime.parse(json['originalStartTime']),
      originalEndTime: DateTime.parse(json['originalEndTime']),
      compressedStartTime: DateTime.parse(json['compressedStartTime']),
      compressedEndTime: DateTime.parse(json['compressedEndTime']),
      eventIds: List<String>.from(json['eventIds'] ?? []),
    );
  }
}

class RandomizedVariationResult {
  final String variationId;
  final int baselineEvents;
  final int variationEvents;
  final double variationPercentage;
  final Map<String, dynamic> variationStats;
  final List<String> eventIds;

  RandomizedVariationResult({
    required this.variationId,
    required this.baselineEvents,
    required this.variationEvents,
    required this.variationPercentage,
    required this.variationStats,
    required this.eventIds,
  });

  factory RandomizedVariationResult.fromJson(Map<String, dynamic> json) {
    return RandomizedVariationResult(
      variationId: json['variationId'],
      baselineEvents: json['baselineEvents'],
      variationEvents: json['variationEvents'],
      variationPercentage: (json['variationPercentage'] as num).toDouble(),
      variationStats: Map<String, dynamic>.from(json['variationStats']),
      eventIds: List<String>.from(json['eventIds'] ?? []),
    );
  }
}

class AnomalyInjectionResult {
  final String injectionId;
  final int totalEvents;
  final int anomalyCount;
  final List<String> anomalyTypes;
  final Map<String, int> anomalyTypeCounts;
  final List<String> anomalyEventIds;
  final List<String> normalEventIds;

  AnomalyInjectionResult({
    required this.injectionId,
    required this.totalEvents,
    required this.anomalyCount,
    required this.anomalyTypes,
    required this.anomalyTypeCounts,
    required this.anomalyEventIds,
    required this.normalEventIds,
  });

  factory AnomalyInjectionResult.fromJson(Map<String, dynamic> json) {
    return AnomalyInjectionResult(
      injectionId: json['injectionId'],
      totalEvents: json['totalEvents'],
      anomalyCount: json['anomalyCount'],
      anomalyTypes: List<String>.from(json['anomalyTypes'] ?? []),
      anomalyTypeCounts: Map<String, int>.from(json['anomalyTypeCounts']),
      anomalyEventIds: List<String>.from(json['anomalyEventIds'] ?? []),
      normalEventIds: List<String>.from(json['normalEventIds'] ?? []),
    );
  }
}

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
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified']) : null,
      configuration: Map<String, dynamic>.from(json['configuration']),
      statistics: json['statistics'] != null ? TestDataStatistics.fromJson(json['statistics']) : null,
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
      masterDataDistribution: Map<String, int>.from(json['masterDataDistribution'] ?? {}),
      oldestEvent: json['oldestEvent'] != null ? DateTime.parse(json['oldestEvent']) : null,
      newestEvent: json['newestEvent'] != null ? DateTime.parse(json['newestEvent']) : null,
      dataSizeBytes: json['dataSizeBytes'] ?? 0,
      additionalMetrics: Map<String, dynamic>.from(json['additionalMetrics'] ?? {}),
    );
  }
}
