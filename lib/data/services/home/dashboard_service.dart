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

  Future<DashboardStats> getDashboardStats() async {
    final token = await _dioService.getAuthToken();
    final headers = _buildHeaders(token);

    // Fetch counts from different endpoints in parallel
    final results = await Future.wait([
      _fetchCount('${_dioService.baseUrl}/master-data/gtins', headers),
      _fetchCount('${_dioService.baseUrl}/master-data/glns', headers),
      _fetchCount(
        '${_dioService.baseUrl}/identifiers/sgtins',
        headers,
      ), // Corrected endpoint
      _fetchCount(
        '${_dioService.baseUrl}/identifiers/sscc',
        headers,
      ), // Corrected endpoint
      _fetchEventCounts(headers),
    ]);

    final eventCounts = results[4] as Map<String, int>;
    final totalEvents = eventCounts.values.fold(0, (sum, count) => sum + count);

    return DashboardStats(
      gtinCount: results[0] as int,
      glnCount: results[1] as int,
      sgtinCount: results[2] as int,
      ssccCount: results[3] as int,
      totalEvents: totalEvents,
      eventsByType: eventCounts,
    );
  }

  Future<int> _fetchCount(String url, Map<String, String> headers) async {
    try {
      final response = await _dioService.get(
        '$url?page=0&size=1',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.data);
        // Handle both PageResponse format and direct array format
        if (data is Map) {
          return data['totalElements'] ?? data['total'] ?? 0;
        }
        if (data is List) {
          return data.length;
        }
      }
      return 0;
    } catch (e) {
      print('Error fetching count from $url: $e');
      return 0;
    }
  }

  Future<Map<String, int>> _fetchEventCounts(
    Map<String, String> headers,
  ) async {
    final eventTypes = {
      'Object': '${_dioService.baseUrl}/events/object',
      'Aggregation': '${_dioService.baseUrl}/events/aggregation',
      'Transaction': '${_dioService.baseUrl}/events/transaction',
      'Transformation':
          '${_dioService.baseUrl}/transformation-events', // Corrected endpoint
    };

    final counts = <String, int>{};

    await Future.wait(
      eventTypes.entries.map((entry) async {
        counts[entry.key] = await _fetchCount(entry.value, headers);
      }),
    );

    return counts;
  }

  Future<List<RecentEvent>> getRecentEvents({int limit = 5}) async {
    final token = await _dioService.getAuthToken();
    final headers = _buildHeaders(token);

    try {
      // Fetch recent events from multiple event types in parallel
      final eventEndpoints = [
        '${_dioService.baseUrl}/events/object?page=0&size=$limit&sortBy=eventTime&direction=DESC',
        '${_dioService.baseUrl}/events/aggregation?page=0&size=$limit&sortBy=eventTime&direction=DESC',
        '${_dioService.baseUrl}/events/transaction?page=0&size=$limit&sortBy=eventTime&direction=DESC',
        '${_dioService.baseUrl}/transformation-events?page=0&size=$limit&sortBy=eventTime&direction=DESC',
      ];

      final responses = await Future.wait(
        eventEndpoints.map((url) async {
          try {
            return await _dioService.get(
              url,
              headers: headers,
              responseType: ResponseType.plain,
              acceptAllStatusCodes: true,
            );
          } catch (e) {
            print('Error fetching from $url: $e');
            return Response(
              requestOptions: RequestOptions(path: url),
              statusCode: 200,
              data: '{"content":[]}',
            );
          }
        }),
      );

      List<RecentEvent> allEvents = [];

      final eventTypes = [
        'ObjectEvent',
        'AggregationEvent',
        'TransactionEvent',
        'TransformationEvent',
      ];

      for (int i = 0; i < responses.length; i++) {
        if (responses[i].statusCode == 200) {
          final data = json.decode(responses[i].data);
          List<dynamic> events;

          if (data is Map && data.containsKey('content')) {
            events = data['content'] as List<dynamic>;
          } else if (data is List) {
            events = data;
          } else {
            events = [];
          }

          for (var e in events) {
            final map = e as Map<String, dynamic>;
            map['eventType'] = eventTypes[i]; // Add event type
            allEvents.add(RecentEvent.fromJson(map));
          }
        }
      }

      // Sort by event time descending and take the most recent
      allEvents.sort((a, b) => b.eventTime.compareTo(a.eventTime));
      return allEvents.take(limit).toList();
    } catch (e) {
      print('Error fetching recent events: $e');
      return [];
    }
  }

  Future<SystemHealthStatus> getSystemHealth() async {
    final token = await _dioService.getAuthToken();
    final headers = _buildHeaders(token);
    final actuatorBaseUrl = '${_dioService.baseUrl}/internal/actuator';

    bool backendHealthy = false;
    bool databaseHealthy = false;
    bool cacheHealthy = false;
    String? backendVersion;

    try {
      // Check backend health
      final healthResponse = await _dioService
          .get(
            '$actuatorBaseUrl/health',
            headers: headers,
            responseType: ResponseType.plain,
            acceptAllStatusCodes: true,
          )
          .timeout(const Duration(seconds: 5));

      if (healthResponse.statusCode == 200) {
        backendHealthy = true;
        final healthData = json.decode(healthResponse.data);

        // Check component health if available
        if (healthData is Map && healthData['components'] != null) {
          final components = healthData['components'] as Map<String, dynamic>;
          databaseHealthy = components['db']?['status'] == 'UP';
          final redisStatus = components['redis']?['status'] as String?;
          final cacheComponentStatus =
              components['cache']?['status'] as String?;
          cacheHealthy =
              redisStatus == 'UP' || cacheComponentStatus == 'UP';
        } else {
          // If no components, assume healthy if main status is UP
          databaseHealthy = healthData['status'] == 'UP';
          cacheHealthy = true;
        }
      }
    } catch (e) {
      print('Error checking backend health: $e');
    }

    try {
      // Get version info
      final infoResponse = await _dioService
          .get(
            '$actuatorBaseUrl/info',
            headers: headers,
            responseType: ResponseType.plain,
            acceptAllStatusCodes: true,
          )
          .timeout(const Duration(seconds: 5));

      if (infoResponse.statusCode == 200) {
        final infoData = json.decode(infoResponse.data);
        backendVersion = infoData['build']?['version']?.toString();
      }
    } catch (e) {
      print('Error fetching version info: $e');
    }

    return SystemHealthStatus(
      backendHealthy: backendHealthy,
      databaseHealthy: databaseHealthy,
      cacheHealthy: cacheHealthy,
      backendVersion: backendVersion,
    );
  }
}
