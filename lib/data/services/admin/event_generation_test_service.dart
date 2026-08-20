import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/services/admin/event_generation_test_models.dart';
import 'package:traqtrace_app/data/services/admin/event_generation_test_data_models.dart';


class EventGenerationTestService {
  final DioService _dioService;

  EventGenerationTestService({required DioService dioService})
    : _dioService = dioService;

  Future<Map<String, dynamic>> _getWithAuth(String path) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}$path',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _postWithAuth(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _dioService.post(
      '${_dioService.baseUrl}$path',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.data) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _deleteWithAuth(String path) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _dioService.delete(
      '${_dioService.baseUrl}$path',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to delete: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> generateSingleEvent(
    String eventType,
    Map<String, dynamic> params,
  ) async {
    return await _postWithAuth(
      '/admin/event-generation-tests/generate/$eventType',
      params,
    );
  }

  Future<BulkGenerationResult> generateBulkEvents(
    String eventType,
    int count,
    Map<String, dynamic> params,
  ) async {
    final requestBody = {'count': count, ...params};
    final json = await _postWithAuth(
      '/admin/event-generation-tests/generate-bulk/$eventType',
      requestBody,
    );
    return BulkGenerationResult.fromJson(json);
  }

  Future<SimulationSession> startSupplyChainSimulation(
    Map<String, dynamic> params,
  ) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/simulation/supply-chain/start',
      params,
    );
    return SimulationSession.fromJson(json);
  }

  Future<SimulationResult> stopSupplyChainSimulation(String sessionId) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/simulation/supply-chain/stop',
      {'sessionId': sessionId},
    );
    return SimulationResult.fromJson(json);
  }

  Future<SimulationStatus> getSimulationStatus(String sessionId) async {
    final json = await _getWithAuth(
      '/admin/event-generation-tests/simulation/$sessionId/status',
    );
    return SimulationStatus.fromJson(json);
  }

  Future<RealTimeGenerationSession> startRealTimeGeneration(
    Map<String, dynamic> params,
  ) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/real-time/start',
      params,
    );
    return RealTimeGenerationSession.fromJson(json);
  }

  Future<RealTimeGenerationResult> stopRealTimeGeneration(
    String sessionId,
  ) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/real-time/stop',
      {'sessionId': sessionId},
    );
    return RealTimeGenerationResult.fromJson(json);
  }

  Future<TimeCompressedSequenceResult> generateTimeCompressedSequence(
    Map<String, dynamic> params,
  ) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/time-compressed',
      params,
    );
    return TimeCompressedSequenceResult.fromJson(json);
  }

  Future<RandomizedVariationResult> generateRandomizedVariations(
    Map<String, dynamic> params,
  ) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/randomized',
      params,
    );
    return RandomizedVariationResult.fromJson(json);
  }

  Future<AnomalyInjectionResult> injectAnomalies(
    Map<String, dynamic> params,
  ) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/inject-anomalies',
      params,
    );
    return AnomalyInjectionResult.fromJson(json);
  }

  Future<TestEnvironment> createTestEnvironment(
    String name,
    Map<String, dynamic> params,
  ) async {
    final requestBody = {'name': name, ...params};
    final json = await _postWithAuth(
      '/admin/event-generation-tests/test-environment',
      requestBody,
    );
    return TestEnvironment.fromJson(json);
  }

  Future<List<TestEnvironment>> getTestEnvironments() async {
    final json = await _getWithAuth(
      '/admin/event-generation-tests/test-environments',
    );
    return (json['environments'] as List)
        .map((env) => TestEnvironment.fromJson(env))
        .toList();
  }

  Future<void> switchToTestEnvironment(String environmentId) async {
    await _postWithAuth(
      '/admin/event-generation-tests/test-environment/$environmentId/switch',
      {},
    );
  }

  Future<void> deleteTestEnvironment(String environmentId) async {
    await _deleteWithAuth(
      '/admin/event-generation-tests/test-environment/$environmentId',
    );
  }

  Future<TestDataset> createTestDataset(
    String name,
    String description,
    Map<String, dynamic> params,
  ) async {
    final requestBody = {'name': name, 'description': description, ...params};
    final json = await _postWithAuth(
      '/admin/event-generation-tests/test-dataset',
      requestBody,
    );
    return TestDataset.fromJson(json);
  }

  Future<List<TestDataset>> getTestDatasets() async {
    final json = await _getWithAuth(
      '/admin/event-generation-tests/test-datasets',
    );
    return (json['datasets'] as List)
        .map((dataset) => TestDataset.fromJson(dataset))
        .toList();
  }

  Future<DatasetLoadResult> loadTestDataset(String datasetId) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/test-dataset/$datasetId/load',
      {},
    );
    return DatasetLoadResult.fromJson(json);
  }

  Future<void> shareTestDataset(String datasetId, String userId) async {
    await _postWithAuth(
      '/admin/event-generation-tests/test-dataset/$datasetId/share',
      {'userId': userId},
    );
  }

  Future<void> deleteTestDataset(String datasetId) async {
    await _deleteWithAuth(
      '/admin/event-generation-tests/test-dataset/$datasetId',
    );
  }

  Future<CleanupResult> cleanTestData(Map<String, dynamic> params) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/cleanup',
      params,
    );
    return CleanupResult.fromJson(json);
  }

  Future<Map<String, dynamic>> cleanTransformationEvents() async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/cleanup/transformation-events',
      {},
    );
    return json;
  }

  Future<Map<String, dynamic>> cleanTransactionEvents() async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/cleanup/transaction-events',
      {},
    );
    return json;
  }

  Future<Map<String, dynamic>> cleanAggregationEvents() async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/cleanup/aggregation-events',
      {},
    );
    return json;
  }

  Future<Map<String, dynamic>> cleanObjectEvents() async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/cleanup/object-events',
      {},
    );
    return json;
  }

  Future<Map<String, dynamic>> cleanGLNTestData() async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/cleanup/gln-test-data',
      {},
    );
    return json;
  }

  Future<Map<String, dynamic>> cleanGTINTestData() async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/cleanup/gtin-test-data',
      {},
    );
    return json;
  }

  Future<Map<String, dynamic>> cleanSGTINTestData() async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/cleanup/sgtin-test-data',
      {},
    );
    return json;
  }

  Future<Map<String, dynamic>> cleanSSCCTestData() async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/cleanup/sscc-test-data',
      {},
    );
    return json;
  }

  Future<Map<String, dynamic>> cleanAllSSCCData() async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/cleanup/all-sscc-data',
      {},
    );
    return json;
  }

  Future<DataSnapshot> createDataSnapshot(
    String name,
    Map<String, dynamic> params,
  ) async {
    final requestBody = {'name': name, ...params};
    final json = await _postWithAuth(
      '/admin/event-generation-tests/snapshot',
      requestBody,
    );
    return DataSnapshot.fromJson(json);
  }

  Future<List<DataSnapshot>> getDataSnapshots() async {
    final json = await _getWithAuth('/admin/event-generation-tests/snapshots');
    return (json['snapshots'] as List)
        .map((snapshot) => DataSnapshot.fromJson(snapshot))
        .toList();
  }

  Future<RestoreResult> restoreDataSnapshot(String snapshotId) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/snapshot/$snapshotId/restore',
      {},
    );
    return RestoreResult.fromJson(json);
  }

  Future<void> deleteDataSnapshot(String snapshotId) async {
    await _deleteWithAuth('/admin/event-generation-tests/snapshot/$snapshotId');
  }

  Future<ArchiveResult> archiveTestData(Map<String, dynamic> params) async {
    final json = await _postWithAuth(
      '/admin/event-generation-tests/archive',
      params,
    );
    return ArchiveResult.fromJson(json);
  }

  Future<TestDataStatistics> getTestDataStatistics() async {
    final json = await _getWithAuth('/admin/event-generation-tests/statistics');
    return TestDataStatistics.fromJson(json);
  }
}
