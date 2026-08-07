import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/home/system_health_status.dart';

class DashboardService {
  final DioService _dioService;

  DashboardService({required DioService dioService})
      : _dioService = dioService;

  Map<String, String> _buildHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Canonical dashboard + recent-events read path (single BFF round-trip).
  Future<({DashboardStats stats, List<RecentEvent> recentEvents})> getSummary({
    int recentLimit = 5,
    int throughputHours = 24,
  }) async {
    final token = await _dioService.getAuthToken();
    final headers = _buildHeaders(token);
    final url =
        '${_dioService.baseUrl}/dashboard/summary?recentLimit=$recentLimit&throughputHours=$throughputHours';

    final response = await _dioService.get(
      url,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load dashboard summary (${response.statusCode})',
      );
    }

    final data = json.decode(response.data) as Map<String, dynamic>;
    return parseSummaryPayload(data);
  }

  /// Parses a raw `DashboardSummaryResponseDTO` JSON map — shared by the REST read above and by
  /// [HomeCubit]'s WebSocket heartbeat handler, since the backend broadcasts that exact same DTO.
  static ({DashboardStats stats, List<RecentEvent> recentEvents}) parseSummaryPayload(
    Map<String, dynamic> data,
  ) {
    final stats = DashboardStats.fromSummaryJson(data);
    final rawEvents = data['recentEvents'] as List<dynamic>? ?? const [];
    final recentEvents = rawEvents
        .whereType<Map>()
        .map((e) => RecentEvent.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return (stats: stats, recentEvents: recentEvents);
  }

  Future<_ThroughputResult> _fetchCommissioningThroughput(
    Map<String, String> headers,
    int hours,
  ) async {
    try {
      final url =
          '${_dioService.baseUrl}/commissioning/throughput?hours=$hours';
      final response = await _dioService.get(
        url,
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.data) as Map<String, dynamic>;
        final rawBuckets = data['buckets'] as List<dynamic>? ?? [];
        final buckets = <int, int>{};
        for (final b in rawBuckets) {
          final idx = (b['hourIndex'] as num).toInt();
          final count = (b['count'] as num).toInt();
          buckets[idx] = count;
        }
        final total = (data['totalCount'] as num?)?.toInt() ?? 0;
        return _ThroughputResult(buckets: buckets, total: total);
      }
    } catch (e) {
      print('Error fetching commissioning throughput: $e');
    }
    return const _ThroughputResult(buckets: {}, total: 0);
  }

  Future<SystemHealthStatus> getSystemHealth() async {
    final token = await _dioService.getAuthToken();
    final headers = _buildHeaders(token);
    final actuatorBaseUrl = '${_dioService.baseUrl}/internal/actuator';

    bool backendHealthy = false;
    bool databaseHealthy = false;
    bool cacheHealthy = false;
    String? backendVersion;

    final results = await Future.wait([
      _getActuatorPayload('$actuatorBaseUrl/health', headers),
      _getActuatorPayload('$actuatorBaseUrl/info', headers),
    ]);

    final healthData = results[0];
    final infoData = results[1];

    if (healthData != null) {
      backendHealthy = true;
      if (healthData['components'] != null) {
        final components = healthData['components'] as Map<String, dynamic>;
        databaseHealthy = components['db']?['status'] == 'UP';
        final redisStatus = components['redis']?['status'] as String?;
        final cacheComponentStatus =
            components['cache']?['status'] as String?;
        cacheHealthy =
            redisStatus == 'UP' || cacheComponentStatus == 'UP';
      } else {
        databaseHealthy = healthData['status'] == 'UP';
        cacheHealthy = true;
      }
    }

    if (infoData != null) {
      backendVersion = infoData['build']?['version']?.toString();
    }

    return SystemHealthStatus(
      backendHealthy: backendHealthy,
      databaseHealthy: databaseHealthy,
      cacheHealthy: cacheHealthy,
      backendVersion: backendVersion,
    );
  }

  Future<Map<String, dynamic>?> _getActuatorPayload(
    String url,
    Map<String, String> headers,
  ) async {
    try {
      final response = await _dioService
          .get(
            url,
            headers: headers,
            responseType: ResponseType.plain,
            acceptAllStatusCodes: true,
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (e) {
      print('Error fetching actuator $url: $e');
      return null;
    }
  }

  Future<({Map<int, int> buckets, int total})> fetchThroughput(
    int hours,
  ) async {
    final token = await _dioService.getAuthToken();
    final result =
        await _fetchCommissioningThroughput(_buildHeaders(token), hours);
    return (buckets: result.buckets, total: result.total);
  }
}

class _ThroughputResult {
  final Map<int, int> buckets;
  final int total;

  const _ThroughputResult({required this.buckets, required this.total});
}
