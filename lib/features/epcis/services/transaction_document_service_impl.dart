import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_document_service.dart';

/// Implementation of TransactionDocumentService
class TransactionDocumentServiceImpl implements TransactionDocumentService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  
  /// Base endpoint for transaction document API
  late final String _baseUrl;
  
  /// Constructor
  TransactionDocumentServiceImpl({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _httpClient = httpClient,
       _tokenManager = tokenManager,
       _appConfig = appConfig {
    _baseUrl = '${_appConfig.apiBaseUrl}/transaction-documents';
  }
  
  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  @override
  Future<List<TransactionEvent>> getTransactionEventsByDocument(String type, String id) async {
    // Ensure type and id are not empty to avoid double slashes
    if (type.isEmpty || id.isEmpty) {
      throw Exception('Document type and ID cannot be empty');
    }
    
    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl/$type/$id/events');
    print('TransactionDocumentService: Requesting URL: $url');
    
    final response = await _httpClient.get(url, headers: headers);
    
    print('TransactionDocumentService: Response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final responseBody = response.body;
      print('TransactionDocumentService: Response body: ${responseBody.length > 100 ? responseBody.substring(0, 100) + '...' : responseBody}');
      
      final List<dynamic> eventsJson = json.decode(responseBody);
      print('TransactionDocumentService: Found ${eventsJson.length} events');
      
      final events = eventsJson.map((json) => TransactionEvent.fromJson(json)).toList();
      return events;
    } else {
      final error = 'Failed to get transaction events: ${response.statusCode}, Body: ${response.body}';
      print('TransactionDocumentService: $error');
      throw Exception(error);
    }
  }
  
  @override
  String toString() {
    return _baseUrl;
  }
  
  @override
  Future<bool> isDocumentReferenceValid(String type, String id) async {
    // Ensure type and id are not empty to avoid double slashes
    if (type.isEmpty || id.isEmpty) {
      throw Exception('Document type and ID cannot be empty');
    }
    
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$type/$id/validate'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['valid'] ?? false;
    } else {
      throw Exception('Failed to validate document reference: ${response.statusCode}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getDocumentStatus(String type, String id) async {
    // Ensure type and id are not empty to avoid double slashes
    if (type.isEmpty || id.isEmpty) {
      throw Exception('Document type and ID cannot be empty');
    }
    
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$type/$id/status'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get document status: ${response.statusCode}');
    }
  }
  
  @override
  Future<Map<String, List<String>>> getRelatedDocuments(String type, String id) async {
    // Ensure type and id are not empty to avoid double slashes
    if (type.isEmpty || id.isEmpty) {
      throw Exception('Document type and ID cannot be empty');
    }
    
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$type/$id/related'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, List<String>> result = {};
      
      data.forEach((key, value) {
        if (value is List) {
          result[key] = List<String>.from(value);
        }
      });
      
      return result;
    } else {
      throw Exception('Failed to get related documents: ${response.statusCode}');
    }
  }
  
  @override
  Future<bool> createDocumentLink(String sourceType, String sourceId, 
                               String targetType, String targetId,
                               String relationshipType) async {
    // Validate all parameters
    if (sourceType.isEmpty || sourceId.isEmpty || 
        targetType.isEmpty || targetId.isEmpty ||
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
    
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/link'),
      headers: headers,
      body: body,
    );
    
    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['created'] ?? false;
    } else {
      throw Exception('Failed to create document link: ${response.statusCode}');
    }
  }
  
  @override
  Future<Map<String, String>?> getOriginalDocumentForEPC(String epc, {String? type}) async {
    // Ensure EPC is not empty
    if (epc.isEmpty) {
      throw Exception('EPC cannot be empty');
    }
    
    final headers = await _getHeaders();
    final queryParams = type != null ? '?type=$type' : '';
    
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/original-for-epc/$epc$queryParams'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Map<String, String>.from(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to get original document: ${response.statusCode}');
    }
  }
}
