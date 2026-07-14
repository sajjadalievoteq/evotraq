import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/features/admin/models/monitoring_models.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

class MonitoringService {
  final DioService _dioService;
  late final String _baseUrl;
  Timer? _realTimeTimer;

  final _performanceController = StreamController<PerformanceMetrics>.broadcast();
  final _storageController = StreamController<StorageStatistics>.broadcast();
  final _integrityController = StreamController<IntegrityStatistics>.broadcast();
  final _alertsController = StreamController<List<PerformanceAlert>>.broadcast();

  Stream<PerformanceMetrics> get performanceStream => _performanceController.stream;
  Stream<StorageStatistics> get storageStream => _storageController.stream;
  Stream<IntegrityStatistics> get integrityStream => _integrityController.stream;
  Stream<List<PerformanceAlert>> get alertsStream => _alertsController.stream;

  MonitoringService({required DioService dioService}) : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/events/persistence';
  }

  void startRealTimeMonitoring({Duration interval = const Duration(seconds: 5)}) {
    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(interval, (_) async {
      try {
        await _fetchAllMetrics();
      } catch (e) {
        print('Real-time monitoring error: $e');
      }
    });
  }

  void stopRealTimeMonitoring() {
    _realTimeTimer?.cancel();
  }

  Future<void> _fetchAllMetrics() async {
    try {
      final summary = await getMonitoringSummary();

      final performance = summary['performance'] != null
          ? PerformanceMetrics.fromJson(summary['performance'])
          : null;
      final storage = summary['storage'] != null
          ? StorageStatistics.fromJson(summary['storage'])
          : null;
      final integrity = summary['integrity'] != null
          ? IntegrityStatistics.fromJson(summary['integrity'])
          : null;

      if (performance != null) {
        _performanceController.add(performance);
        _alertsController.add(performance.activeAlerts);
      }
      if (storage != null) _storageController.add(storage);
      if (integrity != null) _integrityController.add(integrity);
    } catch (e) {
      print('Error fetching metrics: $e');
    }
  }

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<PerformanceMetrics> getPerformanceMetrics() async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/performance/metrics',
        headers: await _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        return PerformanceMetrics.fromJson(data);
      } else {
        throw Exception('Failed to load performance metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching performance metrics: $e');
    }
  }

  Future<StorageStatistics> getStorageStatistics() async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/statistics/storage',
        headers: await _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        return StorageStatistics.fromJson(data);
      } else {
        throw Exception('Failed to load storage statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching storage statistics: $e');
    }
  }

  Future<IntegrityStatistics> getIntegrityStatistics() async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/statistics/integrity',
        headers: await _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        return IntegrityStatistics.fromJson(data);
      } else {
        throw Exception('Failed to load integrity statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching integrity statistics: $e');
    }
  }

  /// Merged performance + storage + integrity summary in a single call,
  /// used by [_fetchAllMetrics] to replace 3 separate requests with 1.
  Future<Map<String, dynamic>> getMonitoringSummary() async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/monitoring/summary',
        headers: await _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        throw Exception('Failed to load monitoring summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching monitoring summary: $e');
    }
  }

  Future<BulkJobStatus> getBulkJobProgress(String jobId) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/jobs/$jobId/progress',
        headers: await _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        return BulkJobStatus.fromJson(data);
      } else {
        throw Exception('Failed to load job progress: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching job progress: $e');
    }
  }

  Future<String> createBulkJob(String jobType, Map<String, dynamic> parameters) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/jobs/background',
        headers: await _headers,
        data: jsonEncode({
          'job_type': jobType,
          'parameters': parameters,
        }),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.data);
        return data['job_id'] ?? '';
      } else {
        throw Exception('Failed to create bulk job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating bulk job: $e');
    }
  }

  Future<Map<String, dynamic>> archiveEvents(DateTime cutoffDate) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/archive',
        headers: await _headers,
        data: jsonEncode({
          'cutoff_date': cutoffDate.toIso8601String(),
        }),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        throw Exception('Failed to archive events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error archiving events: $e');
    }
  }

  Future<Map<String, dynamic>> compressEvents(List<String> eventIds) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/compress',
        headers: await _headers,
        data: jsonEncode({
          'event_ids': eventIds,
        }),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        throw Exception('Failed to compress events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error compressing events: $e');
    }
  }

  Future<Map<String, dynamic>> verifyEventIntegrity(String eventId) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/integrity/verify/$eventId',
        headers: await _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        throw Exception('Failed to verify integrity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error verifying integrity: $e');
    }
  }

  Future<bool> configureTransactionIsolation(String isolationLevel) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/transaction/isolation',
        headers: await _headers,
        data: jsonEncode({
          'isolation_level': isolationLevel,
        }),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error configuring isolation: $e');
    }
  }

  Future<Map<String, dynamic>> resolveDeadlocks() async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/deadlocks/resolve',
        headers: await _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        throw Exception('Failed to resolve deadlocks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error resolving deadlocks: $e');
    }
  }

  Future<List<PerformanceMetrics>> getHistoricalPerformance({
    required DateTime startDate,
    required DateTime endDate,
    String interval = 'hour',
  }) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/performance/historical',
        headers: await _headers,
        queryParameters: {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
          'interval': interval,
        },
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = (jsonDecode(response.data) as List).cast<dynamic>();
        return data.map((item) => PerformanceMetrics.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load historical data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching historical data: $e');
    }
  }

  Future<bool> acknowledgeAlert(String alertId) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/alerts/$alertId/acknowledge',
        headers: await _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error acknowledging alert: $e');
    }
  }

  void dispose() {
    _realTimeTimer?.cancel();
    _performanceController.close();
    _storageController.close();
    _integrityController.close();
    _alertsController.close();
  }
}

class MonitoringServiceProvider {
  static MonitoringService? _instance;

  static MonitoringService getInstance(DioService dioService) {
    _instance ??= MonitoringService(dioService: dioService);
    return _instance!;
  }

  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }
}
