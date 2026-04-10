import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_document_dto.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_query_parameters_dto.dart';
import 'package:traqtrace_app/features/epcis/services/epcis_serialization_service.dart';

/// Implementation of EPCIS Serialization Service
class EPCISSerializationServiceImpl extends EPCISSerializationService {
  
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  late final String _baseUrl;
  
  EPCISSerializationServiceImpl({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _httpClient = httpClient,
       _tokenManager = tokenManager,
       _appConfig = appConfig {
    _baseUrl = '${_appConfig.apiBaseUrl}/events/serialization';
  }
  
  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders({String contentType = 'application/json'}) async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': contentType,
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  @override
  Future<Map<String, dynamic>> convertXmlToJsonLd(String xmlContent) async {
    try {
      final headers = await _getHeaders(contentType: 'application/xml');
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/convert/xml-to-jsonld'),
        headers: headers,
        body: xmlContent,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to convert XML to JSON-LD: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error converting XML to JSON-LD: $e');
    }
  }
  
  @override
  Future<String> convertJsonLdToXml(Map<String, dynamic> jsonLdContent) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/convert/jsonld-to-xml'),
        headers: headers,
        body: json.encode(jsonLdContent),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to convert JSON-LD to XML: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error converting JSON-LD to XML: $e');
    }
  }
  
  @override
  Future<String> serializeToXml(EPCISDocumentDTO document) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/xml'),
        headers: headers,
        body: json.encode(document.toJson()),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to serialize to XML: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error serializing to XML: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> serializeToJsonLd(EPCISDocumentDTO document) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/jsonld'),
        headers: headers,
        body: json.encode(document.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to serialize to JSON-LD: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error serializing to JSON-LD: $e');
    }
  }
  
  @override
  Future<EPCISDocumentDTO> deserializeXml(String xmlContent) async {
    try {
      final headers = await _getHeaders(contentType: 'application/xml');
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/deserialize/xml'),
        headers: headers,
        body: xmlContent,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return EPCISDocumentDTO.fromJson(jsonData);
      } else {
        throw Exception('Failed to deserialize XML: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deserializing XML: $e');
    }
  }
  
  @override
  Future<EPCISDocumentDTO> deserializeJsonLd(Map<String, dynamic> jsonLdContent) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/deserialize/jsonld'),
        headers: headers,
        body: json.encode(jsonLdContent),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return EPCISDocumentDTO.fromJson(jsonData);
      } else {
        throw Exception('Failed to deserialize JSON-LD: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deserializing JSON-LD: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> validateXmlSchema(String xmlContent) async {
    try {
      final headers = await _getHeaders(contentType: 'application/xml');
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/validate/xml'),
        headers: headers,
        body: xmlContent,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to validate XML schema: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error validating XML schema: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> validateJsonSchema(Map<String, dynamic> jsonContent) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/validate/json'),
        headers: headers,
        body: json.encode(jsonContent),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to validate JSON schema: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error validating JSON schema: $e');
    }
  }
  
  @override
  Future<String> exportToCsv(EPCISQueryParametersDTO queryParams, {bool includeHeaders = true}) async {
    try {
      final uri = Uri.parse('$_baseUrl/export/csv').replace(
        queryParameters: {
          'includeHeaders': includeHeaders.toString(),
        },
      );

      final headers = await _getHeaders();
      headers['Accept'] = 'text/csv';
      final response = await _httpClient.post(
        uri,
        headers: headers,
        body: json.encode(queryParams.toJson()),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to export to CSV: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting to CSV: $e');
    }
  }
  
  @override
  Future<List<int>> exportToPdf(EPCISQueryParametersDTO queryParams, {String templateName = 'default'}) async {
    try {
      final uri = Uri.parse('$_baseUrl/export/pdf').replace(
        queryParameters: {
          'templateName': templateName,
        },
      );

      final headers = await _getHeaders();
      headers['Accept'] = 'application/pdf';
      final response = await _httpClient.post(
        uri,
        headers: headers,
        body: json.encode(queryParams.toJson()),
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to export to PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting to PDF: $e');
    }
  }
  
  @override
  Future<String> exportToHtml(EPCISQueryParametersDTO queryParams) async {
    try {
      final headers = await _getHeaders();
      headers['Accept'] = 'text/html';
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/export/html'),
        headers: headers,
        body: json.encode(queryParams.toJson()),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to export to HTML: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting to HTML: $e');
    }
  }
  
  @override
  Future<List<int>> exportToExcel(EPCISQueryParametersDTO queryParams) async {
    try {
      final headers = await _getHeaders();
      headers['Accept'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/export/excel'),
        headers: headers,
        body: json.encode(queryParams.toJson()),
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to export to Excel: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting to Excel: $e');
    }
  }
  
  @override
  Future<Map<String, String>> getSupportedFormats() async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/formats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return jsonData.cast<String, String>();
      } else {
        throw Exception('Failed to get supported formats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting supported formats: $e');
    }
  }
  
  @override
  Future<String> negotiateFormat(String acceptHeader, List<String> supportedFormats) async {
    try {
      final headers = await _getHeaders();
      headers['Accept'] = acceptHeader;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/negotiate-format'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final format = response.body;
        return format;
      } else {
        throw Exception('Failed to negotiate format: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error negotiating format: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> importEvents(EPCISDocumentDTO epcisDocument) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.post(
        Uri.parse('${_appConfig.apiBaseUrl}/events/persistence/bulk/import'),
        headers: headers,
        body: json.encode(epcisDocument.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to import events: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error importing events: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> importEventsFromXml(String xmlContent) async {
    try {
      // First deserialize XML to DTO
      final documentDto = await deserializeXml(xmlContent);
      
      // Then import the events
      return await importEvents(documentDto);
    } catch (e) {
      throw Exception('Error importing events from XML: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> importEventsFromJsonLd(Map<String, dynamic> jsonLdContent) async {
    try {
      // First deserialize JSON-LD to DTO
      final documentDto = await deserializeJsonLd(jsonLdContent);
      
      // Then import the events
      return await importEvents(documentDto);
    } catch (e) {
      throw Exception('Error importing events from JSON-LD: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    _httpClient.close();
  }
}
