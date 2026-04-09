import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/api_management/models/partner.dart';
import 'package:traqtrace_app/features/api_management/models/partner_credential.dart';
import 'package:traqtrace_app/features/api_management/models/api_audit.dart';
import 'package:traqtrace_app/features/api_management/config/api_config.dart';

/// Service for managing B2B API partners and credentials
class ApiManagementService {
  final String _integrationLayerUrl;
  final http.Client _client;
  final TokenManager _tokenManager;

  ApiManagementService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _integrationLayerUrl = ApiConfig.fromCoreUrl(appConfig.apiBaseUrl),
        _client = httpClient,
        _tokenManager = tokenManager;

  /// Get headers with authorization token from TokenManager
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== Partner Management ====================

  /// List all partners
  Future<List<Partner>> listPartners({bool? active, int page = 0, int size = 20}) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (active != null) 'active': active.toString(),
    };
    
    final uri = Uri.parse('$_integrationLayerUrl/admin/v1/partners')
        .replace(queryParameters: queryParams);
    
    final headers = await _getHeaders();
    final response = await _client.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final partners = data['partners'] as List;
      return partners.map((p) => Partner.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load partners: ${response.statusCode}');
    }
  }

  /// Get a partner by ID
  Future<Partner> getPartner(String partnerId) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      Uri.parse('$_integrationLayerUrl/admin/v1/partners/$partnerId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return Partner.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load partner: ${response.statusCode}');
    }
  }

  /// Create a new partner
  Future<Partner> createPartner({
    required String partnerCode,
    required String companyName,
    required PartnerType partnerType,
    String? gln,
    DataFormat preferredDataFormat = DataFormat.epcisJson,
    String? webhookUrl,
    String? contactEmail,
    String? contactPhone,
  }) async {
    final body = {
      'partnerCode': partnerCode,
      'companyName': companyName,
      'partnerType': partnerType.value,
      'preferredDataFormat': preferredDataFormat.value,
      if (gln != null) 'gln': gln,
      if (webhookUrl != null) 'webhookUrl': webhookUrl,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (contactPhone != null) 'contactPhone': contactPhone,
    };
    
    final headers = await _getHeaders();
    final response = await _client.post(
      Uri.parse('$_integrationLayerUrl/admin/v1/partners'),
      headers: headers,
      body: json.encode(body),
    );
    
    if (response.statusCode == 201) {
      return Partner.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to create partner');
    }
  }

  /// Update a partner
  Future<Partner> updatePartner(String partnerId, {
    String? companyName,
    String? gln,
    PartnerType? partnerType,
    DataFormat? preferredDataFormat,
    String? webhookUrl,
    String? contactEmail,
    String? contactPhone,
    bool? active,
  }) async {
    final body = <String, dynamic>{
      if (companyName != null) 'companyName': companyName,
      if (gln != null) 'gln': gln,
      if (partnerType != null) 'partnerType': partnerType.value,
      if (preferredDataFormat != null) 'preferredDataFormat': preferredDataFormat.value,
      if (webhookUrl != null) 'webhookUrl': webhookUrl,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (active != null) 'active': active,
    };
    
    final headers = await _getHeaders();
    final response = await _client.put(
      Uri.parse('$_integrationLayerUrl/admin/v1/partners/$partnerId'),
      headers: headers,
      body: json.encode(body),
    );
    
    if (response.statusCode == 200) {
      return Partner.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update partner: ${response.statusCode}');
    }
  }

  /// Update a partner with full data map
  Future<Partner> updatePartnerFull(String partnerId, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await _client.put(
      Uri.parse('$_integrationLayerUrl/admin/v1/partners/$partnerId'),
      headers: headers,
      body: json.encode(data),
    );
    
    if (response.statusCode == 200) {
      return Partner.fromJson(json.decode(response.body));
    } else {
      final error = response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(error['message'] ?? 'Failed to update partner: ${response.statusCode}');
    }
  }

  /// Delete a partner
  Future<void> deletePartner(String partnerId) async {
    final headers = await _getHeaders();
    final response = await _client.delete(
      Uri.parse('$_integrationLayerUrl/admin/v1/partners/$partnerId'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete partner: ${response.statusCode}');
    }
  }

  // ==================== Credential Management ====================

  /// List credentials for a partner
  Future<List<PartnerCredential>> listCredentials(String partnerId) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      Uri.parse('$_integrationLayerUrl/admin/v1/partners/$partnerId/credentials'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final credentials = json.decode(response.body) as List;
      return credentials.map((c) => PartnerCredential.fromJson({
        ...c,
        'partnerId': partnerId,
      })).toList();
    } else {
      throw Exception('Failed to load credentials: ${response.statusCode}');
    }
  }

  /// Create an API key credential for a partner
  Future<ApiKeyCredentialResponse> createApiKeyCredential(String partnerId, {
    List<String>? allowedIps,
    int? rateLimitPerMinute,
    List<String>? scopes,
    DateTime? expiresAt,
  }) async {
    final body = <String, dynamic>{
      if (allowedIps != null) 'allowedIps': allowedIps,
      if (rateLimitPerMinute != null) 'rateLimitPerMinute': rateLimitPerMinute,
      if (scopes != null) 'scopes': scopes,
      if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
    };
    
    final headers = await _getHeaders();
    final response = await _client.post(
      Uri.parse('$_integrationLayerUrl/admin/v1/partners/$partnerId/credentials/api-key'),
      headers: headers,
      body: json.encode(body),
    );
    
    if (response.statusCode == 201) {
      return ApiKeyCredentialResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create API key: ${response.statusCode}');
    }
  }

  /// Create OAuth2 credentials for a partner
  Future<OAuth2CredentialResponse> createOAuth2Credential(String partnerId, {
    List<String>? allowedIps,
    int? rateLimitPerMinute,
    List<String>? scopes,
    DateTime? expiresAt,
  }) async {
    final body = <String, dynamic>{
      if (allowedIps != null) 'allowedIps': allowedIps,
      if (rateLimitPerMinute != null) 'rateLimitPerMinute': rateLimitPerMinute,
      if (scopes != null) 'scopes': scopes,
      if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
    };
    
    final headers = await _getHeaders();
    final response = await _client.post(
      Uri.parse('$_integrationLayerUrl/admin/v1/partners/$partnerId/credentials/oauth2'),
      headers: headers,
      body: json.encode(body),
    );
    
    if (response.statusCode == 201) {
      return OAuth2CredentialResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create OAuth2 credentials: ${response.statusCode}');
    }
  }

  /// Revoke a credential
  Future<void> revokeCredential(String partnerId, String credentialId) async {
    final headers = await _getHeaders();
    final response = await _client.delete(
      Uri.parse('$_integrationLayerUrl/admin/v1/partners/$partnerId/credentials/$credentialId'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to revoke credential: ${response.statusCode}');
    }
  }

  /// Update credential settings (scopes, rate limit)
  Future<Map<String, dynamic>> updateCredential(
    String partnerId, 
    String credentialId, {
    List<String>? scopes,
    int? rateLimitPerMinute,
  }) async {
    final headers = await _getHeaders();
    final body = <String, dynamic>{};
    if (scopes != null) body['scopes'] = scopes;
    if (rateLimitPerMinute != null) body['rateLimitPerMinute'] = rateLimitPerMinute;
    
    final response = await _client.patch(
      Uri.parse('$_integrationLayerUrl/admin/v1/partners/$partnerId/credentials/$credentialId'),
      headers: headers,
      body: json.encode(body),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update credential: ${response.statusCode}');
    }
  }

  // ==================== Audit & Analytics ====================

  /// Get audit logs for a partner
  Future<List<ApiAuditLog>> getPartnerAuditLogs(String partnerId, {
    DateTime? from,
    DateTime? to,
    int limit = 100,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    };
    
    final uri = Uri.parse('$_integrationLayerUrl/api/v1/audit/admin/$partnerId')
        .replace(queryParameters: queryParams);
    
    final headers = await _getHeaders();
    final response = await _client.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final logs = json.decode(response.body) as List;
      return logs.map((l) => ApiAuditLog.fromJson(l)).toList();
    } else {
      throw Exception('Failed to load audit logs: ${response.statusCode}');
    }
  }

  /// Get usage statistics for a partner
  Future<ApiUsageStats> getPartnerStats(String partnerId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final queryParams = <String, String>{
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    };
    
    final uri = Uri.parse('$_integrationLayerUrl/api/v1/audit/admin/$partnerId/stats')
        .replace(queryParameters: queryParams);
    
    final headers = await _getHeaders();
    final response = await _client.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      return ApiUsageStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }

  // ==================== Health Check ====================

  /// Check Integration Layer health
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _client.get(
        Uri.parse('$_integrationLayerUrl/health/detailed'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'DOWN', 'error': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'DOWN', 'error': e.toString()};
    }
  }
}
