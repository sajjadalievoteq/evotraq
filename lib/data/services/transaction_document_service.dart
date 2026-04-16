import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';

/// Implementation of TransactionDocumentService
class TransactionDocumentService {
  final DioService _dioService;

  /// Base endpoint for transaction document API
  late final String _baseUrl;

  /// Constructor
  TransactionDocumentService({required DioService dioService})
    : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/transaction-documents';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<TransactionEvent>> getTransactionEventsByDocument(
    String type,
    String id,
  ) async {
    // Ensure type and id are not empty to avoid double slashes
    if (type.isEmpty || id.isEmpty) {
      throw Exception('Document type and ID cannot be empty');
    }

    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl/$type/$id/events');
    print('TransactionDocumentService: Requesting URL: $url');

    final response = await _dioService.get(
      url.toString(),
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    print(
      'TransactionDocumentService: Response status code: ${response.statusCode}',
    );
    if (response.statusCode == 200) {
      final responseBody = response.data;
      print(
        'TransactionDocumentService: Response body: ${responseBody.length > 100 ? responseBody.substring(0, 100) + '...' : responseBody}',
      );

      final List<dynamic> eventsJson = json.decode(responseBody);
      print('TransactionDocumentService: Found ${eventsJson.length} events');

      final events = eventsJson
          .map((json) => TransactionEvent.fromJson(json))
          .toList();
      return events;
    } else {
      final error =
          'Failed to get transaction events: ${response.statusCode}, Body: ${response.data}';
      print('TransactionDocumentService: $error');
      throw Exception(error);
    }
  }

  @override
  String toString() {
    return _baseUrl;
  }

  Future<bool> isDocumentReferenceValid(String type, String id) async {
    // Ensure type and id are not empty to avoid double slashes
    if (type.isEmpty || id.isEmpty) {
      throw Exception('Document type and ID cannot be empty');
    }

    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/$type/$id/validate',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      return data['valid'] ?? false;
    } else {
      throw Exception(
        'Failed to validate document reference: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> getDocumentStatus(String type, String id) async {
    // Ensure type and id are not empty to avoid double slashes
    if (type.isEmpty || id.isEmpty) {
      throw Exception('Document type and ID cannot be empty');
    }

    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/$type/$id/status',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception('Failed to get document status: ${response.statusCode}');
    }
  }

  Future<Map<String, List<String>>> getRelatedDocuments(
    String type,
    String id,
  ) async {
    // Ensure type and id are not empty to avoid double slashes
    if (type.isEmpty || id.isEmpty) {
      throw Exception('Document type and ID cannot be empty');
    }

    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/$type/$id/related',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      final Map<String, List<String>> result = {};

      data.forEach((key, value) {
        if (value is List) {
          result[key] = List<String>.from(value);
        }
      });

      return result;
    } else {
      throw Exception(
        'Failed to get related documents: ${response.statusCode}',
      );
    }
  }

  Future<bool> createDocumentLink(
    String sourceType,
    String sourceId,
    String targetType,
    String targetId,
    String relationshipType,
  ) async {
    // Validate all parameters
    if (sourceType.isEmpty ||
        sourceId.isEmpty ||
        targetType.isEmpty ||
        targetId.isEmpty ||
        relationshipType.isEmpty) {
      throw Exception('All document link parameters must be non-empty');
    }

    final headers = await _getHeaders();
    final body = json.encode({
      'sourceType': sourceType,
      'sourceId': sourceId,
      'targetType': targetType,
      'targetId': targetId,
      'relationshipType': relationshipType,
    });

    final response = await _dioService.post(
      '$_baseUrl/link',
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.data);
      return data['created'] ?? false;
    } else {
      throw Exception('Failed to create document link: ${response.statusCode}');
    }
  }

  Future<Map<String, String>?> getOriginalDocumentForEPC(
    String epc, {
    String? type,
  }) async {
    // Ensure EPC is not empty
    if (epc.isEmpty) {
      throw Exception('EPC cannot be empty');
    }

    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/original-for-epc/$epc',
      queryParameters: type != null ? {'type': type} : null,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      return Map<String, String>.from(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Failed to get original document: ${response.statusCode}',
      );
    }
  }
}
