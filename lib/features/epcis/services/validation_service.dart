import 'dart:convert';
import 'package:flutter/foundation.dart' hide ObjectEvent;
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/models/transformation_event.dart';

/// Service for validating EPCIS events
abstract class ValidationService {
  /// Validates an EPCIS Object Event
  Future<Map<String, dynamic>> validateObjectEvent(Map<String, dynamic> eventData);
  
  /// Validates an EPCIS Aggregation Event
  Future<Map<String, dynamic>> validateAggregationEvent(Map<String, dynamic> eventData);
  
  /// Validates an EPCIS Transaction Event
  Future<Map<String, dynamic>> validateTransactionEvent(Map<String, dynamic> eventData);
  
  /// Validates an EPCIS Transformation Event
  Future<Map<String, dynamic>> validateTransformationEvent(Map<String, dynamic> eventData);
  
  /// Validates any EPCIS event based on its type
  Future<Map<String, dynamic>> validateEvent(Map<String, dynamic> eventData);
  
  /// Validates an ObjectEvent model
  Future<Map<String, dynamic>> validateObjectEventModel(ObjectEvent event);
  
  /// Validates an AggregationEvent model
  Future<Map<String, dynamic>> validateAggregationEventModel(AggregationEvent event);
  
  /// Validates a TransactionEvent model
  Future<Map<String, dynamic>> validateTransactionEventModel(TransactionEvent event);
  
  /// Validates a TransformationEvent model
  Future<Map<String, dynamic>> validateTransformationEventModel(TransformationEvent event);
}

/// Implementation of the ValidationService
class ValidationServiceImpl implements ValidationService {
  final TokenManager _tokenManager;
  final http.Client _httpClient;
  final AppConfig _appConfig;
  
  ValidationServiceImpl({
    required TokenManager tokenManager,
    http.Client? httpClient,
    required AppConfig appConfig,
  })  : _tokenManager = tokenManager,
        _httpClient = httpClient ?? http.Client(),
        _appConfig = appConfig;
  
  @override
  Future<Map<String, dynamic>> validateObjectEvent(Map<String, dynamic> eventData) async {
    return _validateEventRequest('/validate/object-event', eventData);
  }
  
  @override
  Future<Map<String, dynamic>> validateObjectEventModel(ObjectEvent event) async {
    return validateObjectEvent(event.toJson());
  }
  
  @override
  Future<Map<String, dynamic>> validateAggregationEvent(Map<String, dynamic> eventData) async {
    return _validateEventRequest('/validate/aggregation-event', eventData);
  }
  
  @override
  Future<Map<String, dynamic>> validateAggregationEventModel(AggregationEvent event) async {
    return validateAggregationEvent(event.toJson());
  }
  
  @override
  Future<Map<String, dynamic>> validateTransactionEvent(Map<String, dynamic> eventData) async {
    return _validateEventRequest('/validate/transaction-event', eventData);
  }
  
  @override
  Future<Map<String, dynamic>> validateTransactionEventModel(TransactionEvent event) async {
    return validateTransactionEvent(event.toJson());
  }
  
  @override
  Future<Map<String, dynamic>> validateTransformationEvent(Map<String, dynamic> eventData) async {
    return _validateEventRequest('/validate/transformation-event', eventData);
  }
  
  @override
  Future<Map<String, dynamic>> validateTransformationEventModel(TransformationEvent event) async {
    return validateTransformationEvent(event.toJson());
  }
  
  @override
  Future<Map<String, dynamic>> validateEvent(Map<String, dynamic> eventData) async {
    return _validateEventRequest('/validate/event', eventData);
  }
  
  /// Helper method to make the validation request
  Future<Map<String, dynamic>> _validateEventRequest(String endpoint, Map<String, dynamic> eventData) async {
    try {
      final token = await _tokenManager.getToken();
      final response = await _httpClient.post(
        Uri.parse('${_appConfig.apiBaseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(eventData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print('Validation failed with status: ${response.statusCode}, body: ${response.body}');
        }
        
        // Try to parse error response
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          return {
            'valid': false,
            'error': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error validating event: $e');
      }
      return {
        'valid': false,
        'error': 'Error connecting to server: $e',
      };
    }
  }
}
