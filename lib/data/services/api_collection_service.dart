import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/api_management/models/api_collection.dart';
import 'package:traqtrace_app/features/api_management/config/api_config.dart';

/// Service for managing API Collections and Definitions
/// Communicates with the Integration Layer admin API
class ApiCollectionService {
  final String baseUrl;
  final DioService _dioService;

  ApiCollectionService({required DioService dioService})
    : baseUrl = ApiConfig.fromCoreUrl(dioService.baseUrl),
      _dioService = dioService;

  /// Get headers with authorization token from TokenManager
  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== Collection Operations ====================

  Future<List<ApiCollection>> getCollections({bool activeOnly = false}) async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections',
      queryParameters: {'activeOnly': activeOnly.toString()},
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((e) => ApiCollection.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load collections: ${response.statusCode}');
    }
  }

  Future<List<ApiCollection>> getPublicCollections() async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections/public',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((e) => ApiCollection.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load public collections: ${response.statusCode}',
      );
    }
  }

  Future<ApiCollection> getCollectionById(String id) async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections/$id',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ApiCollection.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      throw Exception('Collection not found');
    } else {
      throw Exception('Failed to load collection: ${response.statusCode}');
    }
  }

  Future<ApiCollection> getCollectionWithApis(String id) async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections/$id/with-apis',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ApiCollection.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      throw Exception('Collection not found');
    } else {
      throw Exception(
        'Failed to load collection with APIs: ${response.statusCode}',
      );
    }
  }

  Future<ApiCollection> getCollectionByCode(String code) async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections/code/$code',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ApiCollection.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      throw Exception('Collection not found');
    } else {
      throw Exception('Failed to load collection: ${response.statusCode}');
    }
  }

  Future<List<ApiCollection>> getCollectionsByCategory(String category) async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections/category/$category',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((e) => ApiCollection.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load collections by category: ${response.statusCode}',
      );
    }
  }

  Future<ApiCollection> createCollection({
    required String code,
    required String name,
    String? description,
    String version = '1.0',
    String? category,
    String? icon,
    bool isPublic = false,
    int? rateLimitPerMinute,
  }) async {
    final body = {
      'code': code,
      'name': name,
      'description': description,
      'version': version,
      'category': category,
      'icon': icon,
      'isPublic': isPublic,
      'rateLimitPerMinute': rateLimitPerMinute,
    };

    final response = await _dioService.post(
      '$baseUrl/admin/v1/collections',
      headers: await _getHeaders(),
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return ApiCollection.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 400) {
      throw Exception('Invalid collection data or code already exists');
    } else {
      throw Exception('Failed to create collection: ${response.statusCode}');
    }
  }

  Future<ApiCollection> updateCollection(
    String id, {
    String? name,
    String? description,
    String? version,
    String? category,
    String? icon,
    bool? isPublic,
    int? rateLimitPerMinute,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (version != null) body['version'] = version;
    if (category != null) body['category'] = category;
    if (icon != null) body['icon'] = icon;
    if (isPublic != null) body['isPublic'] = isPublic;
    if (rateLimitPerMinute != null)
      body['rateLimitPerMinute'] = rateLimitPerMinute;

    final response = await _dioService.put(
      '$baseUrl/admin/v1/collections/$id',
      headers: await _getHeaders(),
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ApiCollection.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      throw Exception('Collection not found');
    } else {
      throw Exception('Failed to update collection: ${response.statusCode}');
    }
  }

  Future<void> activateCollection(String id) async {
    final response = await _dioService.post(
      '$baseUrl/admin/v1/collections/$id/activate',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to activate collection: ${response.statusCode}');
    }
  }

  Future<void> deactivateCollection(String id) async {
    final response = await _dioService.post(
      '$baseUrl/admin/v1/collections/$id/deactivate',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to deactivate collection: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteCollection(String id) async {
    final response = await _dioService.delete(
      '$baseUrl/admin/v1/collections/$id',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 409) {
      throw Exception('Cannot delete collection with APIs. Remove APIs first.');
    } else if (response.statusCode != 204) {
      throw Exception('Failed to delete collection: ${response.statusCode}');
    }
  }

  // ==================== API Definition Operations ====================

  Future<List<ApiDefinition>> getApisInCollection(String collectionId) async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections/$collectionId/apis',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((e) => ApiDefinition.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load APIs: ${response.statusCode}');
    }
  }

  Future<ApiDefinition> getApiById(String collectionId, String apiId) async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections/$collectionId/apis/$apiId',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ApiDefinition.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      throw Exception('API not found');
    } else {
      throw Exception('Failed to load API: ${response.statusCode}');
    }
  }

  Future<ApiDefinition> createApi(
    String collectionId, {
    required String code,
    required String name,
    String? description,
    required String httpMethod,
    required String pathPattern,
    String? requestContentType,
    String? responseContentType,
    int timeoutSeconds = 30,
    int? cacheTtlSeconds,
    int? rateLimitPerMinute,
    List<String>? tags,
  }) async {
    final body = {
      'code': code,
      'name': name,
      'description': description,
      'httpMethod': httpMethod,
      'pathPattern': pathPattern,
      'requestContentType': requestContentType,
      'responseContentType': responseContentType,
      'timeoutSeconds': timeoutSeconds,
      'cacheTtlSeconds': cacheTtlSeconds,
      'rateLimitPerMinute': rateLimitPerMinute,
      'tags': tags,
    };

    final response = await _dioService.post(
      '$baseUrl/admin/v1/collections/$collectionId/apis',
      headers: await _getHeaders(),
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return ApiDefinition.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 400) {
      throw Exception('Invalid API data or code already exists');
    } else {
      throw Exception('Failed to create API: ${response.statusCode}');
    }
  }

  Future<ApiDefinition> updateApi(
    String collectionId,
    String apiId, {
    String? name,
    String? description,
    String? httpMethod,
    String? pathPattern,
    int? timeoutSeconds,
    int? cacheTtlSeconds,
    int? rateLimitPerMinute,
    List<String>? tags,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (httpMethod != null) body['httpMethod'] = httpMethod;
    if (pathPattern != null) body['pathPattern'] = pathPattern;
    if (timeoutSeconds != null) body['timeoutSeconds'] = timeoutSeconds;
    if (cacheTtlSeconds != null) body['cacheTtlSeconds'] = cacheTtlSeconds;
    if (rateLimitPerMinute != null)
      body['rateLimitPerMinute'] = rateLimitPerMinute;
    if (tags != null) body['tags'] = tags;

    final response = await _dioService.put(
      '$baseUrl/admin/v1/collections/$collectionId/apis/$apiId',
      headers: await _getHeaders(),
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ApiDefinition.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      throw Exception('API not found');
    } else {
      throw Exception('Failed to update API: ${response.statusCode}');
    }
  }

  Future<void> activateApi(String collectionId, String apiId) async {
    final response = await _dioService.post(
      '$baseUrl/admin/v1/collections/$collectionId/apis/$apiId/activate',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to activate API: ${response.statusCode}');
    }
  }

  Future<void> deactivateApi(String collectionId, String apiId) async {
    final response = await _dioService.post(
      '$baseUrl/admin/v1/collections/$collectionId/apis/$apiId/deactivate',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to deactivate API: ${response.statusCode}');
    }
  }

  Future<void> deleteApi(String collectionId, String apiId) async {
    final response = await _dioService.delete(
      '$baseUrl/admin/v1/collections/$collectionId/apis/$apiId',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete API: ${response.statusCode}');
    }
  }

  Future<int> getApiCount(String collectionId) async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections/$collectionId/apis/count',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return int.parse(response.data.toString());
    } else {
      throw Exception('Failed to get API count: ${response.statusCode}');
    }
  }

  Future<List<ApiDefinition>> findApisByTag(String tag) async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections/apis/tag/$tag',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((e) => ApiDefinition.fromJson(e)).toList();
    } else {
      throw Exception('Failed to find APIs by tag: ${response.statusCode}');
    }
  }

  // ==================== Export Operations ====================

  /// Export a collection as a Postman collection JSON
  Future<String> exportPostmanCollection(String collectionId) async {
    final response = await _dioService.get(
      '$baseUrl/admin/v1/collections/$collectionId/export/postman',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return response.data.toString();
    } else if (response.statusCode == 404) {
      throw Exception('Collection not found');
    } else {
      throw Exception(
        'Failed to export Postman collection: ${response.statusCode}',
      );
    }
  }
}
