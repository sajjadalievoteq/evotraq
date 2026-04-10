import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' hide ObjectEvent;
import 'package:traqtrace_app/features/epcis/services/validation_service.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/models/transformation_event.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:http/http.dart' as http;

/// Cache validation result storage class
class _CachedValidationResult {
  final Map<String, dynamic> result;
  final int timestamp;
  
  _CachedValidationResult({
    required this.result,
    required this.timestamp,
  });
}

/// Provider for managing validation state and operations
class ValidationServiceProvider with ChangeNotifier {
  final ValidationService _validationService;
  
  bool _loading = false;
  Map<String, dynamic>? _lastValidationResult;
  String? _error;
  
  // Cache for validation results to avoid redundant API calls
  final Map<String, _CachedValidationResult> _validationCache = {};
  
  // Maximum cache size
  final int _maxCacheSize = 50;
  
  /// Cache validity duration in milliseconds (5 minutes)
  final int _cacheDuration = 300000;
  
  /// Whether validation is in progress
  bool get loading => _loading;
  
  /// The result of the last validation
  Map<String, dynamic>? get lastValidationResult => _lastValidationResult;
  
  /// Whether the last validation was successful
  bool get isValid => _lastValidationResult != null && (_lastValidationResult!['valid'] as bool? ?? false);
  
  /// Any validation errors from the last validation
  List<dynamic> get validationErrors {
    if (_lastValidationResult == null) return [];
    
    // Handle the new nested error structure
    if (_lastValidationResult!.containsKey('errors')) {
      final errorsMap = _lastValidationResult!['errors'] as Map<String, dynamic>;
      final allErrors = <String>[];
      
      // Process all error categories
      errorsMap.forEach((category, errors) {
        if (errors is List) {
          for (final error in errors) {
            if (error is String) {
              allErrors.add(error);
            }
          }
        }
      });
      
      return allErrors;
    }
    
    // Fallback to old format for backward compatibility
    return _lastValidationResult!.containsKey('validationErrors') 
      ? (_lastValidationResult!['validationErrors'] as List<dynamic>? ?? []) 
      : [];
  }
  
  /// Any error message
  String? get error => _error;
  
  /// Cache hit rate for monitoring
  double get cacheHitRate {
    if (_cacheHits + _cacheMisses == 0) return 0;
    return _cacheHits / (_cacheHits + _cacheMisses);
  }
  
  // Cache statistics for monitoring
  int _cacheHits = 0;
  int _cacheMisses = 0;
  
  ValidationServiceProvider({ValidationService? validationService, required AppConfig appConfig})
      : _validationService = validationService ?? ValidationServiceImpl(
            tokenManager: TokenManager(),
            httpClient: http.Client(),
            appConfig: appConfig,
          );
  
  /// Validate an object event
  Future<bool> validateObjectEvent(ObjectEvent event) async {
    return _validateEvent(() => _validationService.validateObjectEventModel(event));
  }
  
  /// Validate an aggregation event
  Future<bool> validateAggregationEvent(AggregationEvent event) async {
    return _validateEvent(() => _validationService.validateAggregationEventModel(event));
  }
  
  /// Validate a transaction event
  Future<bool> validateTransactionEvent(TransactionEvent event) async {
    return _validateEvent(() => _validationService.validateTransactionEventModel(event));
  }
  
  /// Validate a transformation event
  Future<bool> validateTransformationEvent(TransformationEvent event) async {
    return _validateEvent(() => _validationService.validateTransformationEventModel(event));
  }
  
  /// Validate a batch of object events
  Future<List<Map<String, dynamic>>> validateObjectEventBatch(List<ObjectEvent> events) async {
    return _validateBatch(events, (event) => _validationService.validateObjectEventModel(event));
  }
  
  /// Validate a batch of aggregation events
  Future<List<Map<String, dynamic>>> validateAggregationEventBatch(List<AggregationEvent> events) async {
    return _validateBatch(events, (event) => _validationService.validateAggregationEventModel(event));
  }
  
  /// Validate a batch of transaction events
  Future<List<Map<String, dynamic>>> validateTransactionEventBatch(List<TransactionEvent> events) async {
    return _validateBatch(events, (event) => _validationService.validateTransactionEventModel(event));
  }
  
  /// Validate a batch of transformation events
  Future<List<Map<String, dynamic>>> validateTransformationEventBatch(List<TransformationEvent> events) async {
    return _validateBatch(events, (event) => _validationService.validateTransformationEventModel(event));
  }
  
  /// Helper method to handle validation process
  Future<bool> _validateEvent(Future<Map<String, dynamic>> Function() validationFunction) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final cacheKey = _generateCacheKey(validationFunction);
      final cachedResult = _getCachedResult(cacheKey);
      
      if (cachedResult != null) {
        _lastValidationResult = cachedResult;
        _loading = false;
        notifyListeners();
        return isValid;
      }
      
      _lastValidationResult = await validationFunction();
      
      _cacheValidationResult(cacheKey, _lastValidationResult!);
      
      _loading = false;
      notifyListeners();
      return isValid;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      _lastValidationResult = {
        'valid': false,
        'error': e.toString(),
        'validationErrors': [],
      };
      notifyListeners();
      return false;
    }
  }
  
  /// Helper method to handle batch validation process with concurrency control
  Future<List<Map<String, dynamic>>> _validateBatch<T>(
    List<T> events, 
    Future<Map<String, dynamic>> Function(T event) validateFunction,
    {int concurrencyLimit = 5}
  ) async {
    _loading = true;
    notifyListeners();
    
    final results = <Map<String, dynamic>>[];
    
    try {
      // Process events in batches to control concurrency
      for (int i = 0; i < events.length; i += concurrencyLimit) {
        final end = (i + concurrencyLimit < events.length) ? i + concurrencyLimit : events.length;
        final batch = events.sublist(i, end);
        
        // Process current batch in parallel
        final batchResults = await Future.wait(
          batch.map((event) async {
            try {
              // Generate cache key for this specific event
              final eventJson = event is Map ? event : (event as dynamic).toJson();
              final cacheKey = _generateEventCacheKey(eventJson, T.toString());
              
              // Check cache
              final cachedResult = _getCachedResult(cacheKey);
              if (cachedResult != null) {
                return cachedResult;
              }
              
              // Perform validation and cache the result
              final result = await validateFunction(event);
              _cacheValidationResult(cacheKey, result);
              return result;
            } catch (e) {
              return {
                'valid': false,
                'error': 'Error validating event: ${e.toString()}',
                'validationErrors': [],
              };
            }
          }),
        );
        
        results.addAll(batchResults);
      }
      
      // Set the last validation result to the summary of all results
      _lastValidationResult = {
        'valid': results.every((r) => r['valid'] == true),
        'validationErrors': results
            .expand((r) => r.containsKey('validationErrors') ? (r['validationErrors'] as List? ?? []) : [])
            .toList(),
        'batchResults': results,
      };
      
      _loading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return List.filled(events.length, {
        'valid': false,
        'error': e.toString(),
        'validationErrors': [],
      });
    }
  }
  
  /// Clear validation state
  void clearValidation() {
    _lastValidationResult = null;
    _error = null;
    notifyListeners();
  }
  
  /// Generate a unique cache key for the validation function
  String _generateCacheKey(Future<Map<String, dynamic>> Function() validationFunction) {
    final functionString = validationFunction.toString();
    final bytes = utf8.encode(functionString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  

  
  /// Get cached validation result if available
  Map<String, dynamic>? _getCachedResult(String cacheKey) {
    final cachedResult = _validationCache[cacheKey];
    if (cachedResult != null) {
      // Check if result is still valid
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - cachedResult.timestamp <= _cacheDuration) {
        _cacheHits++;
        return cachedResult.result;
      } else {
        // Cached result has expired
        _validationCache.remove(cacheKey);
      }
    }
    
    _cacheMisses++;
    return null;
  }
  
  /// Cache a validation result
  void _cacheValidationResult(String cacheKey, Map<String, dynamic> result) {
    // Enforce maximum cache size by removing oldest entries if needed
    if (_validationCache.length >= _maxCacheSize) {
      final oldestKey = _validationCache.entries
          .reduce((a, b) => a.value.timestamp < b.value.timestamp ? a : b)
          .key;
      _validationCache.remove(oldestKey);
    }
    
    _validationCache[cacheKey] = _CachedValidationResult(
      result: result,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
  
  /// Clear the validation cache
  void clearCache() {
    _validationCache.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }
  
  /// Generate a cache key for a specific event
  String _generateEventCacheKey(Map<String, dynamic> eventData, String eventType) {
    // Generate a stable hash of the event data for caching
    final jsonStr = jsonEncode(eventData);
    final bytes = utf8.encode(jsonStr);
    final digest = md5.convert(bytes);
    return '$eventType:${digest.toString()}';
  }
}
