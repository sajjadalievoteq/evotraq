import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/api_management/models/api_collection.dart';
import 'package:traqtrace_app/features/api_management/config/api_config.dart';

/// Service for managing Partner API Access
/// Supports both collection-level and individual API access control
class PartnerAccessApiService {
  final String baseUrl;
  final http.Client _client;
  final TokenManager _tokenManager;

  PartnerAccessApiService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : baseUrl = ApiConfig.fromCoreUrl(appConfig.apiBaseUrl),
        _client = httpClient,
        _tokenManager = tokenManager;

  /// Get headers with authorization token from TokenManager
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== Access Summary ====================

  Future<PartnerAccessSummary> getAccessSummary(String partnerId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/admin/v1/partners/$partnerId/access/summary'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return PartnerAccessSummary.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Partner not found');
    } else {
      throw Exception('Failed to load access summary: ${response.statusCode}');
    }
  }

  // ==================== Collection Access Operations ====================

  Future<List<PartnerCollectionAccess>> getCollectionAccess(String partnerId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/admin/v1/partners/$partnerId/access/collections'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => PartnerCollectionAccess.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load collection access: ${response.statusCode}');
    }
  }

  Future<PartnerCollectionAccess> grantCollectionAccess(
    String partnerId,
    String collectionId, {
    AccessLevel accessLevel = AccessLevel.full,
    int? rateLimitOverride,
    DateTime? validFrom,
    DateTime? validUntil,
  }) async {
    final body = {
      'accessLevel': accessLevel.value,
      'rateLimitOverride': rateLimitOverride,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
    };

    final response = await _client.post(
      Uri.parse('$baseUrl/admin/v1/partners/$partnerId/access/collections/$collectionId'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      return PartnerCollectionAccess.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('Invalid access data');
    } else {
      throw Exception('Failed to grant collection access: ${response.statusCode}');
    }
  }

  Future<void> revokeCollectionAccess(String partnerId, String collectionId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/admin/v1/partners/$partnerId/access/collections/$collectionId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to revoke collection access: ${response.statusCode}');
    }
  }

  // ==================== Individual API Access Operations ====================

  Future<List<PartnerApiAccess>> getApiAccess(String partnerId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/admin/v1/partners/$partnerId/access/apis'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => PartnerApiAccess.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load API access: ${response.statusCode}');
    }
  }

  Future<PartnerApiAccess> grantApiAccess(
    String partnerId,
    String apiId, {
    int? rateLimitOverride,
    DateTime? validFrom,
    DateTime? validUntil,
  }) async {
    final body = {
      'rateLimitOverride': rateLimitOverride,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
    };

    final response = await _client.post(
      Uri.parse('$baseUrl/admin/v1/partners/$partnerId/access/apis/$apiId'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      return PartnerApiAccess.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('Invalid access data');
    } else {
      throw Exception('Failed to grant API access: ${response.statusCode}');
    }
  }

  Future<List<PartnerApiAccess>> grantBulkApiAccess(
    String partnerId,
    List<String> apiIds, {
    int? rateLimitOverride,
    DateTime? validFrom,
    DateTime? validUntil,
  }) async {
    final body = {
      'apiIds': apiIds,
      'rateLimitOverride': rateLimitOverride,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
    };

    final response = await _client.post(
      Uri.parse('$baseUrl/admin/v1/partners/$partnerId/access/apis/bulk'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => PartnerApiAccess.fromJson(e)).toList();
    } else if (response.statusCode == 400) {
      throw Exception('Invalid access data');
    } else {
      throw Exception('Failed to grant bulk API access: ${response.statusCode}');
    }
  }

  Future<void> revokeApiAccess(String partnerId, String apiId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/admin/v1/partners/$partnerId/access/apis/$apiId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to revoke API access: ${response.statusCode}');
    }
  }

  // ==================== Access Validation ====================

  Future<bool> checkApiAccess(String partnerId, String apiId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/admin/v1/partners/$partnerId/access/check/api/$apiId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['hasAccess'] as bool;
    } else {
      throw Exception('Failed to check API access: ${response.statusCode}');
    }
  }

  Future<bool> checkPathAccess(String partnerId, String httpMethod, String path) async {
    final body = {
      'httpMethod': httpMethod,
      'path': path,
    };

    final response = await _client.post(
      Uri.parse('$baseUrl/admin/v1/partners/$partnerId/access/check/path'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['hasAccess'] as bool;
    } else {
      throw Exception('Failed to check path access: ${response.statusCode}');
    }
  }
}
