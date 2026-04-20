import 'dart:convert';
import 'package:flutter/foundation.dart' hide ObjectEvent;
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/models/transformation_event.dart';

class ValidationService {
  final DioService _dioService;
  
  ValidationService({
    required DioService dioService,
  }) : _dioService = dioService;
  
  Future<Map<String, dynamic>> validateObjectEvent(Map<String, dynamic> eventData) async {
    return _validateEventRequest('/validate/object-event', eventData);
  }
  
  Future<Map<String, dynamic>> validateObjectEventModel(ObjectEvent event) async {
    return validateObjectEvent(event.toJson());
  }
  
  Future<Map<String, dynamic>> validateAggregationEvent(Map<String, dynamic> eventData) async {
    return _validateEventRequest('/validate/aggregation-event', eventData);
  }
  
  Future<Map<String, dynamic>> validateAggregationEventModel(AggregationEvent event) async {
    return validateAggregationEvent(event.toJson());
  }
  
  Future<Map<String, dynamic>> validateTransactionEvent(Map<String, dynamic> eventData) async {
    return _validateEventRequest('/validate/transaction-event', eventData);
  }
  
  Future<Map<String, dynamic>> validateTransactionEventModel(TransactionEvent event) async {
    return validateTransactionEvent(event.toJson());
  }
  
  Future<Map<String, dynamic>> validateTransformationEvent(Map<String, dynamic> eventData) async {
    return _validateEventRequest('/validate/transformation-event', eventData);
  }
  
  Future<Map<String, dynamic>> validateTransformationEventModel(TransformationEvent event) async {
    return validateTransformationEvent(event.toJson());
  }
  
  Future<Map<String, dynamic>> validateEvent(Map<String, dynamic> eventData) async {
    return _validateEventRequest('/validate/event', eventData);
  }
  
  /// Helper method to make the validation request
  Future<Map<String, dynamic>> _validateEventRequest(String endpoint, Map<String, dynamic> eventData) async {
    try {
      final token = await _dioService.getAuthToken();
      final response = await _dioService.post(
        '${_dioService.baseUrl}$endpoint',
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        data: jsonEncode(eventData),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print(
            'Validation failed with status: ${response.statusCode}, body: ${response.data}',
          );
        }
        
        // Try to parse error response
        try {
          return jsonDecode(response.data) as Map<String, dynamic>;
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
