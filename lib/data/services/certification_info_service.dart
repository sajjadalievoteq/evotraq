import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/certification_info.dart';

/// Implementation of the CertificationInfoService interface
class CertificationInfoService {
  final DioService _dioService;

  /// Base endpoint for certification info API
  late final String _baseUrl;

  /// Constructor
  CertificationInfoService({
    required DioService dioService,
  }) : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/certifications';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CertificationInfo>> getAllCertifications() async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      _baseUrl,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> certificationList = json.decode(response.data);
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
    final response = await _dioService.get(
      _baseUrl,
      queryParameters: {'page': page.toString(), 'size': size.toString()},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);
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

    final response = await _dioService.get(
      '$_baseUrl/$cleanId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return CertificationInfo.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to get certification: ${response.statusCode}');
    }
  }

  Future<CertificationInfo> createCertification(
    CertificationInfo certificationInfo,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: json.encode(certificationInfo.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return CertificationInfo.fromJson(json.decode(response.data));
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

    final response = await _dioService.put(
      '$_baseUrl/$cleanId',
      headers: headers,
      data: json.encode(certificationInfo.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return CertificationInfo.fromJson(json.decode(response.data));
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

    final response = await _dioService.delete(
      '$_baseUrl/$cleanId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
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

    final response = await _dioService.get(
      '$_baseUrl/event/$cleanId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> certificationList = json.decode(response.data);
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
    final response = await _dioService.get(
      '$_baseUrl/type/$type',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> certificationList = json.decode(response.data);
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
    final response = await _dioService.get(
      '$_baseUrl/agency/$agency',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> certificationList = json.decode(response.data);
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

    final response = await _dioService.get(
      '$_baseUrl/$cleanId/verify',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception('Failed to verify certification: ${response.statusCode}');
    }
  }
}
