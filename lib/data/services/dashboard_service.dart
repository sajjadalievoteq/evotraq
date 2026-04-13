import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

/// Dashboard statistics model
class DashboardStats {
  final int gtinCount;
  final int glnCount;
  final int sgtinCount;
  final int ssccCount;
  final int totalEvents;
  final Map<String, int> eventsByType;

  DashboardStats({
    required this.gtinCount,
    required this.glnCount,
    required this.sgtinCount,
    required this.ssccCount,
    required this.totalEvents,
    required this.eventsByType,
  });
}

/// Recent event model for dashboard
class RecentEvent {
  final String id;
  final String eventType;
  final String action;
  final String? bizStep;
  final DateTime eventTime;
  final List<String> epcList;

  RecentEvent({
    required this.id,
    required this.eventType,
    required this.action,
    this.bizStep,
    required this.eventTime,
    required this.epcList,
  });

  factory RecentEvent.fromJson(Map<String, dynamic> json) {
    return RecentEvent(
      id: json['id']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? 'Unknown',
      action: json['action']?.toString() ?? '',
      bizStep: json['bizStep']?.toString(),
      eventTime: json['eventTime'] != null 
          ? DateTime.tryParse(json['eventTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      epcList: (json['epcList'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// System health status model
class SystemHealthStatus {
  final bool backendHealthy;
  final bool databaseHealthy;
  final bool cacheHealthy;
  final String? backendVersion;

  SystemHealthStatus({
    required this.backendHealthy,
    required this.databaseHealthy,
    required this.cacheHealthy,
    this.backendVersion,
  });
}

class DashboardService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  DashboardService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _client = httpClient,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  Map<String, String> _buildHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<DashboardStats> getDashboardStats() async {
    final token = await _tokenManager.getToken();
    final headers = _buildHeaders(token);

    // Fetch counts from different endpoints in parallel
    final results = await Future.wait([
      _fetchCount('${_appConfig.apiBaseUrl}/master-data/gtins', headers),
      _fetchCount('${_appConfig.apiBaseUrl}/master-data/glns', headers),
      _fetchCount('${_appConfig.apiBaseUrl}/identifiers/sgtins', headers),  // Corrected endpoint
      _fetchCount('${_appConfig.apiBaseUrl}/identifiers/sscc', headers),    // Corrected endpoint
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
      final response = await _client.get(
        Uri.parse('$url?page=0&size=1'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

  Future<Map<String, int>> _fetchEventCounts(Map<String, String> headers) async {
    final eventTypes = {
      'Object': '${_appConfig.apiBaseUrl}/events/object',
      'Aggregation': '${_appConfig.apiBaseUrl}/events/aggregation',
      'Transaction': '${_appConfig.apiBaseUrl}/events/transaction',
      'Transformation': '${_appConfig.apiBaseUrl}/transformation-events',  // Corrected endpoint
    };

    final counts = <String, int>{};
    
    await Future.wait(eventTypes.entries.map((entry) async {
      counts[entry.key] = await _fetchCount(entry.value, headers);
    }));

    return counts;
  }

  Future<List<RecentEvent>> getRecentEvents({int limit = 5}) async {
    final token = await _tokenManager.getToken();
    final headers = _buildHeaders(token);

    try {
      // Fetch recent events from multiple event types in parallel
      final eventEndpoints = [
        '${_appConfig.apiBaseUrl}/events/object?page=0&size=$limit&sortBy=eventTime&direction=DESC',
        '${_appConfig.apiBaseUrl}/events/aggregation?page=0&size=$limit&sortBy=eventTime&direction=DESC',
        '${_appConfig.apiBaseUrl}/events/transaction?page=0&size=$limit&sortBy=eventTime&direction=DESC',
        '${_appConfig.apiBaseUrl}/transformation-events?page=0&size=$limit&sortBy=eventTime&direction=DESC',
      ];

      final responses = await Future.wait(
        eventEndpoints.map((url) => _client.get(Uri.parse(url), headers: headers).catchError((e) {
          print('Error fetching from $url: $e');
          return http.Response('{"content":[]}', 200);
        })),
      );

      List<RecentEvent> allEvents = [];

      final eventTypes = ['ObjectEvent', 'AggregationEvent', 'TransactionEvent', 'TransformationEvent'];
      
      for (int i = 0; i < responses.length; i++) {
        if (responses[i].statusCode == 200) {
          final data = json.decode(responses[i].body);
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
    final token = await _tokenManager.getToken();
    final headers = _buildHeaders(token);

    bool backendHealthy = false;
    bool databaseHealthy = false;
    bool cacheHealthy = false;
    String? backendVersion;

    try {
      // Check backend health
      final healthResponse = await _client.get(
        Uri.parse('${_appConfig.apiBaseUrl}/actuator/health'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      if (healthResponse.statusCode == 200) {
        backendHealthy = true;
        final healthData = json.decode(healthResponse.body);
        
        // Check component health if available
        if (healthData is Map && healthData['components'] != null) {
          final components = healthData['components'] as Map<String, dynamic>;
          databaseHealthy = components['db']?['status'] == 'UP';
          cacheHealthy = components['redis']?['status'] == 'UP' || 
                         components['cache']?['status'] == 'UP' ||
                         true; // Default to true if no cache component
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
      final infoResponse = await _client.get(
        Uri.parse('${_appConfig.apiBaseUrl}/actuator/info'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      if (infoResponse.statusCode == 200) {
        final infoData = json.decode(infoResponse.body);
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
