import '../../core/network/http_service.dart';

import 'package:traqtrace_app/features/epcis/models/epcis_query_parameters.dart';
import 'package:traqtrace_app/features/epcis/models/advanced_query_result.dart';

class AdvancedQueryService {
  final HttpService _httpService;

  AdvancedQueryService(this._httpService);

  Future<AdvancedQueryResult> executeAdvancedQuery(EPCISQueryParameters parameters) async {
    try {
      final queryData = parameters.toJson();
      
      final response = await _httpService.post(
        '/events/query/advanced',
        data: queryData,
      );

      if (response.statusCode == 200) {
        return AdvancedQueryResult.fromJson(response.data);
      } else {
        throw Exception('Failed to execute advanced query: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error executing advanced query: $e');
    }
  }

  Future<Map<String, dynamic>> executeFacetedQuery(
    EPCISQueryParameters parameters,
    List<String> facetFields,
  ) async {
    try {
      final queryParams = {'facetFields': facetFields.join(',')};
      final response = await _httpService.post(
        '/events/query/faceted?${Uri(queryParameters: queryParams).query}',
        data: parameters.toJson(),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to execute faceted query: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error executing faceted query: $e');
    }
  }

  Future<Map<String, List<String>>> getAvailableFacets() async {
    try {
      final response = await _httpService.get('/events/query/facets/available');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        Map<String, List<String>> result = {};
        
        data.forEach((key, value) {
          if (value is List) {
            result[key] = List<String>.from(value);
          }
        });
        
        return result;
      } else {
        throw Exception('Failed to get available facets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting available facets: $e');
    }
  }

  Future<Map<String, dynamic>> executeFullTextSearch(
    String searchText,
    List<String>? eventTypes,
  ) async {
    try {
      final queryParams = <String, String>{
        'searchText': searchText,
      };
      
      if (eventTypes != null && eventTypes.isNotEmpty) {
        queryParams['eventTypes'] = eventTypes.join(',');
      }

      final response = await _httpService.get(
        '/events/query/fulltext',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to execute full-text search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error executing full-text search: $e');
    }
  }

  Future<List<dynamic>> executeGeospatialQuery(
    double centerLatitude,
    double centerLongitude,
    double radiusKm,
    EPCISQueryParameters? additionalParams,
  ) async {
    try {
      final queryParams = <String, String>{
        'centerLatitude': centerLatitude.toString(),
        'centerLongitude': centerLongitude.toString(),
        'radiusKm': radiusKm.toString(),
      };

      // For GET with body, we'll use POST instead as Dio doesn't support GET with body well
      final response = await _httpService.post(
        '/events/query/geospatial?${Uri(queryParameters: queryParams).query}',
        data: additionalParams?.toJson() ?? {},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to execute geospatial query: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error executing geospatial query: $e');
    }
  }

  Future<Map<String, dynamic>> createStoredQuery(
    String queryName,
    EPCISQueryParameters parameters,
    String? description,
  ) async {
    try {
      final queryParams = <String, String>{
        'queryName': queryName,
      };
      
      if (description != null && description.isNotEmpty) {
        queryParams['description'] = description;
      }

      final response = await _httpService.post(
        '/events/query/stored?${Uri(queryParameters: queryParams).query}',
        data: parameters.toJson(),
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create stored query: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating stored query: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStoredQueries() async {
    try {
      final response = await _httpService.get('/events/query/stored');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get stored queries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting stored queries: $e');
    }
  }

  Future<AdvancedQueryResult> executeStoredQuery(
    String queryName,
    Map<String, dynamic>? runtimeParams,
  ) async {
    try {
      final response = await _httpService.post(
        '/events/query/stored/$queryName/execute',
        data: runtimeParams ?? {},
      );

      if (response.statusCode == 200) {
        return AdvancedQueryResult.fromJson(response.data);
      } else {
        throw Exception('Failed to execute stored query: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error executing stored query: $e');
    }
  }

  Future<void> deleteStoredQuery(String queryName) async {
    try {
      final response = await _httpService.delete('/events/query/stored/$queryName');

      if (response.statusCode != 204) {
        throw Exception('Failed to delete stored query: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting stored query: $e');
    }
  }

  Future<Map<String, dynamic>> createQuerySubscription(
    String subscriptionName,
    EPCISQueryParameters parameters,
    String? webhookUrl,
  ) async {
    try {
      final queryParams = <String, String>{
        'subscriptionName': subscriptionName,
      };
      
      if (webhookUrl != null && webhookUrl.isNotEmpty) {
        queryParams['webhookUrl'] = webhookUrl;
      }

      final response = await _httpService.post(
        '/events/query/subscriptions?${Uri(queryParameters: queryParams).query}',
        data: parameters.toJson(),
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating subscription: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getActiveSubscriptions() async {
    try {
      final response = await _httpService.get('/events/query/subscriptions');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting subscriptions: $e');
    }
  }

  Future<void> deleteSubscription(String subscriptionId) async {
    try {
      final response = await _httpService.delete('/events/query/subscriptions/$subscriptionId');

      if (response.statusCode != 204) {
        throw Exception('Failed to delete subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting subscription: $e');
    }
  }

  Future<void> exportResults(EPCISQueryParameters parameters, String format) async {
    try {
      final endpoint = format == 'xml' 
          ? '/events/export/xml'
          : '/events/export/json';

      final response = await _httpService.post(
        endpoint,
        data: parameters.toJson(),
      );

      if (response.statusCode == 200) {
        // In a real implementation, this would handle file download
        // For now, we'll just log success
        print('Export completed successfully');
      } else {
        throw Exception('Failed to export results: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting results: $e');
    }
  }

  Future<Map<String, dynamic>> getQueryExecutionPlan(EPCISQueryParameters parameters) async {
    try {
      final response = await _httpService.post(
        '/events/query/execution-plan',
        data: parameters.toJson(),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get execution plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting execution plan: $e');
    }
  }

  Future<Map<String, dynamic>> getQueryPerformanceStatistics(
    String? startTime,
    String? endTime,
  ) async {
    try {
      final queryParams = <String, String>{};
      
      if (startTime != null) queryParams['startTime'] = startTime;
      if (endTime != null) queryParams['endTime'] = endTime;

      final response = await _httpService.get(
        '/events/query/performance-statistics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get performance statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting performance statistics: $e');
    }
  }

  // Traversal Query Methods
  Future<Map<String, dynamic>> getSupplyChainPath({
    required String epc,
    String direction = 'both',
    int maxDepth = 10,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final queryParams = <String, String>{
        'direction': direction,
        'maxDepth': maxDepth.toString(),
      };
      
      if (startTime != null) {
        queryParams['startTime'] = startTime.toIso8601String();
      }
      if (endTime != null) {
        queryParams['endTime'] = endTime.toIso8601String();
      }

      final response = await _httpService.get(
        '/events/query/traversal/supply-chain/$epc',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get supply chain path: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting supply chain path: $e');
    }
  }

  Future<Map<String, dynamic>> getDetailedItemHistory({
    required String epc,
    bool includeTransformations = true,
    bool includeAggregations = true,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final queryParams = <String, String>{
        'includeTransformations': includeTransformations.toString(),
        'includeAggregations': includeAggregations.toString(),
      };
      
      if (startTime != null) {
        queryParams['startTime'] = startTime.toIso8601String();
      }
      if (endTime != null) {
        queryParams['endTime'] = endTime.toIso8601String();
      }

      final response = await _httpService.get(
        '/events/query/traversal/history/$epc',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get item history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting item history: $e');
    }
  }

  Future<Map<String, dynamic>> getAggregationHierarchy({
    required String parentEpc,
    DateTime? timestamp,
    bool includeHistory = false,
  }) async {
    try {
      final queryParams = <String, String>{
        'includeHistory': includeHistory.toString(),
      };
      
      if (timestamp != null) {
        queryParams['timestamp'] = timestamp.toIso8601String();
      }

      final response = await _httpService.get(
        '/events/query/traversal/hierarchy/$parentEpc',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get aggregation hierarchy: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting aggregation hierarchy: $e');
    }
  }
}
