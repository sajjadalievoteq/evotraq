import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_document_dto.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_query_parameters_dto.dart';

/// Implementation of EPCIS Serialization Service
class EPCISSerializationService {
  
  final DioService _dioService;
  late final String _baseUrl;
  
  EPCISSerializationService({
    required DioService dioService,
  }) : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/events/serialization';
  }
  
  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders({String contentType = 'application/json'}) async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': contentType,
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Future<Map<String, dynamic>> convertXmlToJsonLd(String xmlContent) async {
    try {
      final headers = await _getHeaders(contentType: 'application/xml');
      final response = await _dioService.post(
        '$_baseUrl/convert/xml-to-jsonld',
        headers: headers,
        data: xmlContent,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return json.decode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to convert XML to JSON-LD: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error converting XML to JSON-LD: $e');
    }
  }
  
  Future<String> convertJsonLdToXml(Map<String, dynamic> jsonLdContent) async {
    try {
      final headers = await _getHeaders();
      final response = await _dioService.post(
        '$_baseUrl/convert/jsonld-to-xml',
        headers: headers,
        data: json.encode(jsonLdContent),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to convert JSON-LD to XML: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error converting JSON-LD to XML: $e');
    }
  }
  
  Future<String> serializeToXml(EPCISDocumentDTO document) async {
    try {
      final headers = await _getHeaders();
      final response = await _dioService.post(
        '$_baseUrl/xml',
        headers: headers,
        data: json.encode(document.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to serialize to XML: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error serializing to XML: $e');
    }
  }
  
  Future<Map<String, dynamic>> serializeToJsonLd(EPCISDocumentDTO document) async {
    try {
      final headers = await _getHeaders();
      final response = await _dioService.post(
        '$_baseUrl/jsonld',
        headers: headers,
        data: json.encode(document.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return json.decode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to serialize to JSON-LD: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error serializing to JSON-LD: $e');
    }
  }
  
  Future<EPCISDocumentDTO> deserializeXml(String xmlContent) async {
    try {
      final headers = await _getHeaders(contentType: 'application/xml');
      final response = await _dioService.post(
        '$_baseUrl/deserialize/xml',
        headers: headers,
        data: xmlContent,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.data) as Map<String, dynamic>;
        return EPCISDocumentDTO.fromJson(jsonData);
      } else {
        throw Exception('Failed to deserialize XML: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deserializing XML: $e');
    }
  }
  
  Future<EPCISDocumentDTO> deserializeJsonLd(Map<String, dynamic> jsonLdContent) async {
    try {
      final headers = await _getHeaders();
      final response = await _dioService.post(
        '$_baseUrl/deserialize/jsonld',
        headers: headers,
        data: json.encode(jsonLdContent),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.data) as Map<String, dynamic>;
        return EPCISDocumentDTO.fromJson(jsonData);
      } else {
        throw Exception('Failed to deserialize JSON-LD: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deserializing JSON-LD: $e');
    }
  }
  
  Future<Map<String, dynamic>> validateXmlSchema(String xmlContent) async {
    try {
      final headers = await _getHeaders(contentType: 'application/xml');
      final response = await _dioService.post(
        '$_baseUrl/validate/xml',
        headers: headers,
        data: xmlContent,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return json.decode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to validate XML schema: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error validating XML schema: $e');
    }
  }
  
  Future<Map<String, dynamic>> validateJsonSchema(Map<String, dynamic> jsonContent) async {
    try {
      final headers = await _getHeaders();
      final response = await _dioService.post(
        '$_baseUrl/validate/json',
        headers: headers,
        data: json.encode(jsonContent),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return json.decode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to validate JSON schema: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error validating JSON schema: $e');
    }
  }
  
  Future<String> exportToCsv(EPCISQueryParametersDTO queryParams, {bool includeHeaders = true}) async {
    try {
      final headers = await _getHeaders();
      headers['Accept'] = 'text/csv';
      final response = await _dioService.post(
        '$_baseUrl/export/csv',
        queryParameters: {'includeHeaders': includeHeaders.toString()},
        headers: headers,
        data: json.encode(queryParams.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to export to CSV: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting to CSV: $e');
    }
  }
  
  Future<List<int>> exportToPdf(EPCISQueryParametersDTO queryParams, {String templateName = 'default'}) async {
    try {
      final headers = await _getHeaders();
      headers['Accept'] = 'application/pdf';
      final response = await _dioService.post(
        '$_baseUrl/export/pdf',
        queryParameters: {'templateName': templateName},
        headers: headers,
        data: json.encode(queryParams.toJson()),
        responseType: ResponseType.bytes,
        acceptAllStatusCodes: true,
      );
      
      if (response.statusCode == 200) {
        return List<int>.from(response.data as List);
      } else {
        throw Exception('Failed to export to PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting to PDF: $e');
    }
  }
  
  Future<String> exportToHtml(EPCISQueryParametersDTO queryParams) async {
    try {
      final headers = await _getHeaders();
      headers['Accept'] = 'text/html';
      final response = await _dioService.post(
        '$_baseUrl/export/html',
        headers: headers,
        data: json.encode(queryParams.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to export to HTML: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting to HTML: $e');
    }
  }
  
  Future<List<int>> exportToExcel(EPCISQueryParametersDTO queryParams) async {
    try {
      final headers = await _getHeaders();
      headers['Accept'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      final response = await _dioService.post(
        '$_baseUrl/export/excel',
        headers: headers,
        data: json.encode(queryParams.toJson()),
        responseType: ResponseType.bytes,
        acceptAllStatusCodes: true,
      );
      
      if (response.statusCode == 200) {
        return List<int>.from(response.data as List);
      } else {
        throw Exception('Failed to export to Excel: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting to Excel: $e');
    }
  }
  
  Future<Map<String, String>> getSupportedFormats() async {
    try {
      final headers = await _getHeaders();
      final response = await _dioService.get(
        '$_baseUrl/formats',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.data) as Map<String, dynamic>;
        return jsonData.cast<String, String>();
      } else {
        throw Exception('Failed to get supported formats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting supported formats: $e');
    }
  }
  
  Future<String> negotiateFormat(String acceptHeader, List<String> supportedFormats) async {
    try {
      final headers = await _getHeaders();
      headers['Accept'] = acceptHeader;
      final response = await _dioService.get(
        '$_baseUrl/negotiate-format',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final format = response.data;
        return format;
      } else {
        throw Exception('Failed to negotiate format: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error negotiating format: $e');
    }
  }
  
  Future<Map<String, dynamic>> importEvents(EPCISDocumentDTO epcisDocument) async {
    try {
      final headers = await _getHeaders();
      final response = await _dioService.post(
        '${_dioService.baseUrl}/events/persistence/bulk/import',
        headers: headers,
        data: json.encode(epcisDocument.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return json.decode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to import events: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error importing events: $e');
    }
  }
  
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
}
