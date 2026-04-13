import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/api_management/models/service_account.dart';

/// Service for managing Service Accounts in the Core System
/// 
/// Service accounts are used for internal M2M authentication between
/// the Integration Layer and Core System.
class ServiceAccountService {
  final String baseUrl;
  final http.Client _client;
  final TokenManager _tokenManager;

  ServiceAccountService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : baseUrl = appConfig.apiBaseUrl,
        _client = httpClient,
        _tokenManager = tokenManager {
    debugPrint('ServiceAccountService created with baseUrl: $baseUrl');
    debugPrint('TokenManager is null: ${tokenManager == null}');
  }

  /// Get headers with authorization token from TokenManager
  Future<Map<String, String>> _getHeaders() async {
    debugPrint('_getHeaders called, _tokenManager is null: ${_tokenManager == null}');
    final token = await _tokenManager.getToken();
    debugPrint('Got token: ${token != null ? "yes" : "no"}');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// List all service accounts
  Future<List<ServiceAccount>> listServiceAccounts() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/service-accounts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ServiceAccount.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load service accounts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error listing service accounts: $e');
      rethrow;
    }
  }

  /// Get a single service account by ID
  Future<ServiceAccount> getServiceAccount(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/service-accounts/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ServiceAccount.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load service account: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting service account: $e');
      rethrow;
    }
  }

  /// Create a new service account
  /// Returns the credentials including the unhashed secret (shown only once)
  Future<ServiceAccountCredentials> createServiceAccount({
    required String name,
    String? description,
    List<String>? allowedIps,
    List<String>? allowedEndpoints,
    int? rateLimitPerMinute,
    DateTime? expiresAt,
  }) async {
    try {
      final body = {
        'name': name,
        if (description != null) 'description': description,
        if (allowedIps != null && allowedIps.isNotEmpty) 'allowedIps': allowedIps.join(','),
        if (allowedEndpoints != null && allowedEndpoints.isNotEmpty) 'allowedEndpoints': allowedEndpoints.join(','),
        if (rateLimitPerMinute != null) 'rateLimitPerMinute': rateLimitPerMinute,
        if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
      };

      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/service-accounts'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ServiceAccountCredentials.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create service account: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating service account: $e');
      rethrow;
    }
  }

  /// Update a service account
  Future<ServiceAccount> updateServiceAccount(
    String id, {
    String? name,
    String? description,
    bool? isActive,
    List<String>? allowedIps,
    List<String>? allowedEndpoints,
    int? rateLimitPerMinute,
    DateTime? expiresAt,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (isActive != null) body['isActive'] = isActive;
      if (allowedIps != null) body['allowedIps'] = allowedIps.join(',');
      if (allowedEndpoints != null) body['allowedEndpoints'] = allowedEndpoints.join(',');
      if (rateLimitPerMinute != null) body['rateLimitPerMinute'] = rateLimitPerMinute;
      if (expiresAt != null) body['expiresAt'] = expiresAt.toIso8601String();

      final headers = await _getHeaders();
      final response = await _client.put(
        Uri.parse('$baseUrl/service-accounts/$id'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return ServiceAccount.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update service account: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating service account: $e');
      rethrow;
    }
  }

  /// Rotate the client secret for a service account
  /// Returns new credentials with the new secret
  Future<ServiceAccountCredentials> rotateSecret(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/service-accounts/$id/rotate-secret'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ServiceAccountCredentials.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to rotate secret: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error rotating secret: $e');
      rethrow;
    }
  }

  /// Deactivate a service account
  Future<void> deactivateServiceAccount(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/service-accounts/$id/deactivate'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to deactivate service account: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deactivating service account: $e');
      rethrow;
    }
  }

  /// Reactivate a service account
  Future<void> reactivateServiceAccount(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/service-accounts/$id/activate'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to reactivate service account: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error reactivating service account: $e');
      rethrow;
    }
  }

  /// Delete a service account permanently
  Future<void> deleteServiceAccount(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(
        Uri.parse('$baseUrl/service-accounts/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete service account: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting service account: $e');
      rethrow;
    }
  }
}
