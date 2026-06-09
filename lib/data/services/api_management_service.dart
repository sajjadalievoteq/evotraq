import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/api_management/models/partner.dart';
import 'package:traqtrace_app/features/api_management/models/partner_credential.dart';
import 'package:traqtrace_app/features/api_management/models/api_audit.dart';
import 'package:traqtrace_app/features/api_management/config/api_config.dart';

class ApiManagementService {
  final String _integrationLayerUrl;
  final DioService _dioService;

  ApiManagementService({
    required DioService dioService,
  })  : _integrationLayerUrl = ApiConfig.fromCoreUrl(dioService.baseUrl),
        _dioService = dioService;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Partner>> listPartners({bool? active, int page = 0, int size = 20}) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      if (active != null) 'active': active.toString(),
    };

    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_integrationLayerUrl/admin/v1/partners',
      queryParameters: queryParams,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data);
      final partners = data['partners'] as List;
      return partners.map((p) => Partner.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load partners: ${response.statusCode}');
    }
  }

  Future<Partner> getPartner(String partnerId) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_integrationLayerUrl/admin/v1/partners/$partnerId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return Partner.fromJson(jsonDecode(response.data));
    } else {
      throw Exception('Failed to load partner: ${response.statusCode}');
    }
  }

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
      'gln': ?gln,
      'webhookUrl': ?webhookUrl,
      'contactEmail': ?contactEmail,
      'contactPhone': ?contactPhone,
    };

    final headers = await _getHeaders();
    final response = await _dioService.post(
      '$_integrationLayerUrl/admin/v1/partners',
      headers: headers,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return Partner.fromJson(jsonDecode(response.data));
    } else {
      final error = response.data.toString().isNotEmpty
          ? jsonDecode(response.data)
          : <String, dynamic>{};
      throw Exception(error['message'] ?? 'Failed to create partner');
    }
  }

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
      'companyName': ?companyName,
      'gln': ?gln,
      if (partnerType != null) 'partnerType': partnerType.value,
      if (preferredDataFormat != null) 'preferredDataFormat': preferredDataFormat.value,
      'webhookUrl': ?webhookUrl,
      'contactEmail': ?contactEmail,
      'contactPhone': ?contactPhone,
      'active': ?active,
    };

    final headers = await _getHeaders();
    final response = await _dioService.put(
      '$_integrationLayerUrl/admin/v1/partners/$partnerId',
      headers: headers,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return Partner.fromJson(jsonDecode(response.data));
    } else {
      throw Exception('Failed to update partner: ${response.statusCode}');
    }
  }

  Future<Partner> updatePartnerFull(String partnerId, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await _dioService.put(
      '$_integrationLayerUrl/admin/v1/partners/$partnerId',
      headers: headers,
      data: jsonEncode(data),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return Partner.fromJson(jsonDecode(response.data));
    } else {
      final error = response.data.toString().isNotEmpty
          ? jsonDecode(response.data)
          : <String, dynamic>{};
      throw Exception(error['message'] ?? 'Failed to update partner: ${response.statusCode}');
    }
  }

  Future<void> deletePartner(String partnerId) async {
    final headers = await _getHeaders();
    final response = await _dioService.delete(
      '$_integrationLayerUrl/admin/v1/partners/$partnerId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete partner: ${response.statusCode}');
    }
  }

  Future<List<PartnerCredential>> listCredentials(String partnerId) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_integrationLayerUrl/admin/v1/partners/$partnerId/credentials',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final credentials = jsonDecode(response.data) as List;
      return credentials.map((c) => PartnerCredential.fromJson({
        ...c,
        'partnerId': partnerId,
      })).toList();
    } else {
      throw Exception('Failed to load credentials: ${response.statusCode}');
    }
  }

  Future<ApiKeyCredentialResponse> createApiKeyCredential(String partnerId, {
    List<String>? allowedIps,
    int? rateLimitPerMinute,
    List<String>? scopes,
    DateTime? expiresAt,
  }) async {
    final body = <String, dynamic>{
      'allowedIps': ?allowedIps,
      'rateLimitPerMinute': ?rateLimitPerMinute,
      'scopes': ?scopes,
      if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
    };

    final headers = await _getHeaders();
    final response = await _dioService.post(
      '$_integrationLayerUrl/admin/v1/partners/$partnerId/credentials/api-key',
      headers: headers,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return ApiKeyCredentialResponse.fromJson(jsonDecode(response.data));
    } else {
      throw Exception('Failed to create API key: ${response.statusCode}');
    }
  }

  Future<OAuth2CredentialResponse> createOAuth2Credential(String partnerId, {
    List<String>? allowedIps,
    int? rateLimitPerMinute,
    List<String>? scopes,
    DateTime? expiresAt,
  }) async {
    final body = <String, dynamic>{
      'allowedIps': ?allowedIps,
      'rateLimitPerMinute': ?rateLimitPerMinute,
      'scopes': ?scopes,
      if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
    };

    final headers = await _getHeaders();
    final response = await _dioService.post(
      '$_integrationLayerUrl/admin/v1/partners/$partnerId/credentials/oauth2',
      headers: headers,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return OAuth2CredentialResponse.fromJson(jsonDecode(response.data));
    } else {
      throw Exception('Failed to create OAuth2 credentials: ${response.statusCode}');
    }
  }

  Future<void> revokeCredential(String partnerId, String credentialId) async {
    final headers = await _getHeaders();
    final response = await _dioService.delete(
      '$_integrationLayerUrl/admin/v1/partners/$partnerId/credentials/$credentialId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to revoke credential: ${response.statusCode}');
    }
  }

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

    final response = await _dioService.patch(
      '$_integrationLayerUrl/admin/v1/partners/$partnerId/credentials/$credentialId',
      headers: headers,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to update credential: ${response.statusCode}');
    }
  }

  Future<List<ApiAuditLog>> getPartnerAuditLogs(String partnerId, {
    DateTime? from,
    DateTime? to,
    int limit = 100,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    };

    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_integrationLayerUrl/api/v1/audit/admin/$partnerId',
      queryParameters: queryParams,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final logs = jsonDecode(response.data) as List;
      return logs.map((l) => ApiAuditLog.fromJson(l)).toList();
    } else {
      throw Exception('Failed to load audit logs: ${response.statusCode}');
    }
  }

  Future<ApiUsageStats> getPartnerStats(String partnerId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final queryParams = <String, dynamic>{
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    };

    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_integrationLayerUrl/api/v1/audit/admin/$partnerId/stats',
      queryParameters: queryParams,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ApiUsageStats.fromJson(jsonDecode(response.data));
    } else {
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _dioService.get(
        '$_integrationLayerUrl/health/detailed',
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        return {'status': 'DOWN', 'error': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'DOWN', 'error': e.toString()};
    }
  }
}
