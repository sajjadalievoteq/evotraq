import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/home/system_health_status.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service_constants.dart';

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

    final results = await Future.wait([
      _fetchCount('${_dioService.baseUrl}/master-data/gtins', headers),
      _fetchCount('${_dioService.baseUrl}/master-data/glns', headers),
      _fetchCount(
        '${_dioService.baseUrl}/identifiers/sgtins',
        headers,
      ),
      _fetchCount(
        '${_dioService.baseUrl}${SsccServiceConstants.pathBase}',
        headers,
      ),
      _fetchEventCounts(headers),
    ]);

    final eventCounts = results[4] as Map<String, int>;
    final totalEvents = eventCounts.values.fold(0, (sum, count) => sum + count);

    final throughput = await _fetchCommissioningThroughput(headers, 24);

    return DashboardStats(
      gtinCount: results[0] as int,
      glnCount: results[1] as int,
      sgtinCount: results[2] as int,
      ssccCount: results[3] as int,
      totalEvents: totalEvents,
      eventsByType: eventCounts,
      throughputBuckets: throughput.buckets,
      throughputTotal: throughput.total,
    );
  }

  
  
  
  Future<({DashboardStats stats, List<RecentEvent> recentEvents})>
      getStatsAndRecentEvents({int recentLimit = 10}) async {
    final token = await _dioService.getAuthToken();
    final headers = _buildHeaders(token);

    final results = await Future.wait([
      _fetchCount('${_dioService.baseUrl}/master-data/gtins', headers),
      _fetchCount('${_dioService.baseUrl}/master-data/glns', headers),
      _fetchCount('${_dioService.baseUrl}/identifiers/sgtins', headers),
      _fetchCount(
        '${_dioService.baseUrl}${SsccServiceConstants.pathBase}',
        headers,
      ),
      _fetchRecentEventsPage(headers, recentLimit),
      _fetchCommissioningThroughput(headers, 24),
    ]);

    final eventPage = results[4] as _RecentEventsPage;
    final throughput = results[5] as _ThroughputResult;
    final totalEvents =
        eventPage.counts.values.fold(0, (sum, count) => sum + count);

    final stats = DashboardStats(
      gtinCount: results[0] as int,
      glnCount: results[1] as int,
      sgtinCount: results[2] as int,
      ssccCount: results[3] as int,
      totalEvents: totalEvents,
      eventsByType: eventPage.counts,
      throughputBuckets: throughput.buckets,
      throughputTotal: throughput.total,
    );

    return (stats: stats, recentEvents: eventPage.events);
  }

  
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
      throw Exception('Failed to load dashboard summary (${response.statusCode})');
    }

    final data = json.decode(response.data) as Map<String, dynamic>;
    final stats = DashboardStats.fromSummaryJson(data);
    final rawEvents = data['recentEvents'] as List<dynamic>? ?? const [];
    final recentEvents = rawEvents
        .whereType<Map>()
        .map((e) => RecentEvent.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return (stats: stats, recentEvents: recentEvents);
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
          '${_dioService.baseUrl}/transformation-events',
    };

    final counts = <String, int>{};

    await Future.wait(
      eventTypes.entries.map((entry) async {
        counts[entry.key] = await _fetchCount(entry.value, headers);
      }),
    );

    return counts;
  }

  Future<_ThroughputResult> _fetchCommissioningThroughput(
    Map<String, String> headers,
    int hours,
  ) async {
    try {
      final url = '${_dioService.baseUrl}/commissioning/throughput?hours=$hours';
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
          final idx   = (b['hourIndex'] as num).toInt();
          final count = (b['count']     as num).toInt();
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

  Future<List<RecentEvent>> getRecentEvents({int limit = 5}) async {
    final token = await _dioService.getAuthToken();
    final headers = _buildHeaders(token);
    final page = await _fetchRecentEventsPage(headers, limit);
    return page.events;
  }

  Future<_RecentEventsPage> _fetchRecentEventsPage(
    Map<String, String> headers,
    int limit,
  ) async {
    try {
      final eventEndpoints = [
        (
          'Object',
          'ObjectEvent',
          '${_dioService.baseUrl}/events/object?page=0&size=$limit&sortBy=eventTime&direction=DESC',
        ),
        (
          'Aggregation',
          'AggregationEvent',
          '${_dioService.baseUrl}/events/aggregation?page=0&size=$limit&sortBy=eventTime&direction=DESC',
        ),
        (
          'Transaction',
          'TransactionEvent',
          '${_dioService.baseUrl}/events/transaction?page=0&size=$limit&sortBy=eventTime&direction=DESC',
        ),
        (
          'Transformation',
          'TransformationEvent',
          '${_dioService.baseUrl}/transformation-events?page=0&size=$limit&sortBy=eventTime&direction=DESC',
        ),
      ];

      final responses = await Future.wait(
        eventEndpoints.map((endpoint) async {
          final url = endpoint.$3;
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
              data: '{"content":[],"totalElements":0}',
            );
          }
        }),
      );

      final allEvents = <RecentEvent>[];
      final counts = <String, int>{};

      for (var i = 0; i < responses.length; i++) {
        final typeLabel = eventEndpoints[i].$1;
        final eventType = eventEndpoints[i].$2;
        counts[typeLabel] = 0;

        if (responses[i].statusCode != 200) continue;

        final data = json.decode(responses[i].data);
        List<dynamic> events;
        if (data is Map && data.containsKey('content')) {
          events = data['content'] as List<dynamic>;
          counts[typeLabel] =
              data['totalElements'] ?? data['total'] ?? events.length;
        } else if (data is List) {
          events = data;
          counts[typeLabel] = data.length;
        } else {
          events = [];
        }

        for (final e in events) {
          final map = e as Map<String, dynamic>;
          map['eventType'] = eventType;
          allEvents.add(RecentEvent.fromJson(map));
        }
      }

      allEvents.sort((a, b) => b.eventTime.compareTo(a.eventTime));
      return _RecentEventsPage(
        events: allEvents.take(limit).toList(),
        counts: counts,
      );
    } catch (e) {
      print('Error fetching recent events: $e');
      return const _RecentEventsPage(events: [], counts: {});
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
    final result = await _fetchCommissioningThroughput(_buildHeaders(token), hours);
    return (buckets: result.buckets, total: result.total);
  }
}

class _ThroughputResult {
  final Map<int, int> buckets;
  final int total;

  const _ThroughputResult({required this.buckets, required this.total});
}

class _RecentEventsPage {
  final List<RecentEvent> events;
  final Map<String, int> counts;

  const _RecentEventsPage({required this.events, required this.counts});
}
