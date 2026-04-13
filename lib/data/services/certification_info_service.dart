import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/certification_info.dart';

/// Implementation of the CertificationInfoService interface
class CertificationInfoService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  /// Base endpoint for certification info API
  late final String _baseUrl;

  /// Constructor
  CertificationInfoService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _httpClient = httpClient,
       _tokenManager = tokenManager,
       _appConfig = appConfig {
    _baseUrl = '${_appConfig.apiBaseUrl}/certifications';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<CertificationInfo>> getAllCertifications() async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse(_baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> certificationList = json.decode(response.body);
      return certificationList
          .map((json) => CertificationInfo.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to get certifications: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getAllCertificationsPaginated(
    int page,
    int size,
  ) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> content = responseData['content'];

      responseData['content'] = content
          .map((json) => CertificationInfo.fromJson(json))
          .toList();

      return responseData;
    } else {
      throw Exception(
        'Failed to get paginated certifications: ${response.statusCode}',
      );
    }
  }

  Future<CertificationInfo> getCertificationById(String id) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId = id;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    }

    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$cleanId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return CertificationInfo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get certification: ${response.statusCode}');
    }
  }

  Future<CertificationInfo> createCertification(
    CertificationInfo certificationInfo,
  ) async {
    final headers = await _getHeaders();
    final response = await _httpClient.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: json.encode(certificationInfo.toJson()),
    );

    if (response.statusCode == 201) {
      return CertificationInfo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create certification: ${response.statusCode}');
    }
  }

  Future<CertificationInfo> updateCertification(
    String id,
    CertificationInfo certificationInfo,
  ) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId = id;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    }

    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/$cleanId'),
      headers: headers,
      body: json.encode(certificationInfo.toJson()),
    );

    if (response.statusCode == 200) {
      return CertificationInfo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update certification: ${response.statusCode}');
    }
  }

  Future<void> deleteCertification(String id) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId = id;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    }

    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/$cleanId'),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete certification: ${response.statusCode}');
    }
  }

  Future<List<CertificationInfo>> getCertificationsByEventId(
    String eventId,
  ) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId = eventId;
    if (eventId.contains(':')) {
      cleanId = eventId.split(':').last;
    }

    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/event/$cleanId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> certificationList = json.decode(response.body);
      return certificationList
          .map((json) => CertificationInfo.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to get certifications by event: ${response.statusCode}',
      );
    }
  }

  Future<List<CertificationInfo>> getCertificationsByType(String type) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/type/$type'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> certificationList = json.decode(response.body);
      return certificationList
          .map((json) => CertificationInfo.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to get certifications by type: ${response.statusCode}',
      );
    }
  }

  Future<List<CertificationInfo>> getCertificationsByAgency(
    String agency,
  ) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/agency/$agency'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> certificationList = json.decode(response.body);
      return certificationList
          .map((json) => CertificationInfo.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to get certifications by agency: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> verifyCertification(String id) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId = id;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    }

    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$cleanId/verify'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to verify certification: ${response.statusCode}');
    }
  }
}
