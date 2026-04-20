import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/validation_service.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/models/transformation_event.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

/// Cache validation result storage class
class _CachedValidationResult {
  final Map<String, dynamic> result;
  final int timestamp;

  _CachedValidationResult({required this.result, required this.timestamp});
}

class ValidationState extends Equatable {
  final bool loading;
  final Map<String, dynamic>? lastValidationResult;
  final String? error;
  final int cacheHits;
  final int cacheMisses;

  const ValidationState({
    required this.loading,
    required this.lastValidationResult,
    required this.error,
    required this.cacheHits,
    required this.cacheMisses,
  });

  factory ValidationState.initial() => const ValidationState(
    loading: false,
    lastValidationResult: null,
    error: null,
    cacheHits: 0,
    cacheMisses: 0,
  );

  ValidationState copyWith({
    bool? loading,
    Map<String, dynamic>? lastValidationResult,
    String? error,
    int? cacheHits,
    int? cacheMisses,
    bool clearError = false,
    bool clearValidation = false,
  }) {
    return ValidationState(
      loading: loading ?? this.loading,
      lastValidationResult: clearValidation
          ? null
          : (lastValidationResult ?? this.lastValidationResult),
      error: clearError ? null : (error ?? this.error),
      cacheHits: cacheHits ?? this.cacheHits,
      cacheMisses: cacheMisses ?? this.cacheMisses,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    lastValidationResult,
    error,
    cacheHits,
    cacheMisses,
  ];
}

class ValidationCubit extends Cubit<ValidationState> {
  final ValidationService _validationService;

  // Cache for validation results to avoid redundant API calls
  final Map<String, _CachedValidationResult> _validationCache = {};

  // Maximum cache size
  final int _maxCacheSize = 50;

  /// Cache validity duration in milliseconds (5 minutes)
  final int _cacheDuration = 300000;

  double get cacheHitRate {
    if (state.cacheHits + state.cacheMisses == 0) return 0;
    return state.cacheHits / (state.cacheHits + state.cacheMisses);
  }

  bool get isValid =>
      state.lastValidationResult != null &&
      (state.lastValidationResult!['valid'] as bool? ?? false);

  List<dynamic> get validationErrors =>
      _validationErrorsFromResult(state.lastValidationResult);

  ValidationCubit({
    ValidationService? validationService,
  }) : _validationService =
           validationService ??
           ValidationService(
             dioService: getIt<DioService>(),
           ),
       super(ValidationState.initial());

  /// Validate an object event
  Future<bool> validateObjectEvent(ObjectEvent event) async {
    return _validateEvent(
      () => _validationService.validateObjectEventModel(event),
      cacheKey: _generateEventCacheKey(event.toJson(), 'ObjectEvent'),
    );
  }

  /// Validate an aggregation event
  Future<bool> validateAggregationEvent(AggregationEvent event) async {
    return _validateEvent(
      () => _validationService.validateAggregationEventModel(event),
      cacheKey: _generateEventCacheKey(event.toJson(), 'AggregationEvent'),
    );
  }

  /// Validate a transaction event
  Future<bool> validateTransactionEvent(TransactionEvent event) async {
    return _validateEvent(
      () => _validationService.validateTransactionEventModel(event),
      cacheKey: _generateEventCacheKey(event.toJson(), 'TransactionEvent'),
    );
  }

  /// Validate a transformation event
  Future<bool> validateTransformationEvent(TransformationEvent event) async {
    return _validateEvent(
      () => _validationService.validateTransformationEventModel(event),
      cacheKey: _generateEventCacheKey(event.toJson(), 'TransformationEvent'),
    );
  }

  /// Validate a batch of object events
  Future<List<Map<String, dynamic>>> validateObjectEventBatch(
    List<ObjectEvent> events,
  ) async {
    return _validateBatch(
      events,
      (event) => _validationService.validateObjectEventModel(event),
    );
  }

  /// Validate a batch of aggregation events
  Future<List<Map<String, dynamic>>> validateAggregationEventBatch(
    List<AggregationEvent> events,
  ) async {
    return _validateBatch(
      events,
      (event) => _validationService.validateAggregationEventModel(event),
    );
  }

  /// Validate a batch of transaction events
  Future<List<Map<String, dynamic>>> validateTransactionEventBatch(
    List<TransactionEvent> events,
  ) async {
    return _validateBatch(
      events,
      (event) => _validationService.validateTransactionEventModel(event),
    );
  }

  /// Validate a batch of transformation events
  Future<List<Map<String, dynamic>>> validateTransformationEventBatch(
    List<TransformationEvent> events,
  ) async {
    return _validateBatch(
      events,
      (event) => _validationService.validateTransformationEventModel(event),
    );
  }

  Future<bool> _validateEvent(
    Future<Map<String, dynamic>> Function() validationFunction, {
    required String cacheKey,
  }) async {
    try {
      final cachedResult = _getCachedResult(cacheKey);

      if (cachedResult != null) {
        emit(
          state.copyWith(
            loading: false,
            clearError: true,
            lastValidationResult: Map<String, dynamic>.from(cachedResult),
            cacheHits: state.cacheHits + 1,
          ),
        );
        return isValid;
      }

      emit(state.copyWith(loading: true, clearError: true));
      final result = await validationFunction();
      _cacheValidationResult(cacheKey, result);
      emit(
        state.copyWith(
          loading: false,
          lastValidationResult: Map<String, dynamic>.from(result),
          cacheMisses: state.cacheMisses + 1,
        ),
      );
      return isValid;
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.toString(),
          lastValidationResult: {
            'valid': false,
            'error': e.toString(),
            'validationErrors': [],
          },
        ),
      );
      return false;
    }
  }

  /// Helper method to handle batch validation process with concurrency control
  Future<List<Map<String, dynamic>>> _validateBatch<T>(
    List<T> events,
    Future<Map<String, dynamic>> Function(T event) validateFunction, {
    int concurrencyLimit = 5,
  }) async {
    emit(state.copyWith(loading: true, clearError: true));

    final results = <Map<String, dynamic>>[];

    try {
      // Process events in batches to control concurrency
      for (int i = 0; i < events.length; i += concurrencyLimit) {
        final end = (i + concurrencyLimit < events.length)
            ? i + concurrencyLimit
            : events.length;
        final batch = events.sublist(i, end);

        // Process current batch in parallel
        final batchResults = await Future.wait(
          batch.map((event) async {
            try {
              // Generate cache key for this specific event
              final eventJson = event is Map
                  ? event
                  : (event as dynamic).toJson();
              final cacheKey = _generateEventCacheKey(eventJson, T.toString());

              // Check cache
              final cachedResult = _getCachedResult(cacheKey);
              if (cachedResult != null) {
                emit(state.copyWith(cacheHits: state.cacheHits + 1));
                return cachedResult;
              }

              // Perform validation and cache the result
              final result = await validateFunction(event);
              _cacheValidationResult(cacheKey, result);
              emit(state.copyWith(cacheMisses: state.cacheMisses + 1));
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
      final lastValidationResult = {
        'valid': results.every((r) => r['valid'] == true),
        'validationErrors': results
            .expand(
              (r) => r.containsKey('validationErrors')
                  ? (r['validationErrors'] as List? ?? [])
                  : [],
            )
            .toList(),
        'batchResults': results,
      };

      emit(
        state.copyWith(
          loading: false,
          lastValidationResult: lastValidationResult,
        ),
      );
      return results;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return List.filled(events.length, {
        'valid': false,
        'error': e.toString(),
        'validationErrors': [],
      });
    }
  }

  /// Clear validation state
  void clearValidation() {
    emit(state.copyWith(clearValidation: true, clearError: true));
  }

  /// Get cached validation result if available
  Map<String, dynamic>? _getCachedResult(String cacheKey) {
    final cachedResult = _validationCache[cacheKey];
    if (cachedResult != null) {
      // Check if result is still valid
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - cachedResult.timestamp <= _cacheDuration) {
        return cachedResult.result;
      } else {
        // Cached result has expired
        _validationCache.remove(cacheKey);
      }
    }
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
    emit(state.copyWith(cacheHits: 0, cacheMisses: 0));
  }

  /// Generate a cache key for a specific event
  String _generateEventCacheKey(
    Map<String, dynamic> eventData,
    String eventType,
  ) {
    // Generate a stable hash of the event data for caching
    final jsonStr = jsonEncode(eventData);
    final bytes = utf8.encode(jsonStr);
    final digest = md5.convert(bytes);
    return '$eventType:${digest.toString()}';
  }

  List<dynamic> _validationErrorsFromResult(Map<String, dynamic>? result) {
    if (result == null) return [];

    if (result.containsKey('errors') &&
        result['errors'] is Map<String, dynamic>) {
      final errorsMap = result['errors'] as Map<String, dynamic>;
      final allErrors = <String>[];
      errorsMap.forEach((_, errors) {
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

    if (result.containsKey('validationErrors')) {
      return result['validationErrors'] as List<dynamic>? ?? [];
    }

    return [];
  }
}
