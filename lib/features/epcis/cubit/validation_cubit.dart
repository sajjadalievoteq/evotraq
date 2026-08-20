import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/epcis/validation_service.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart';
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/validation/validation_error_mapper.dart';
import 'package:traqtrace_app/core/validation/validation_status.dart';

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
  final Map<String, String?> fieldErrors;

  const ValidationState({
    required this.loading,
    required this.lastValidationResult,
    required this.error,
    required this.cacheHits,
    required this.cacheMisses,
    required this.fieldErrors,
  });

  factory ValidationState.initial() => const ValidationState(
    loading: false,
    lastValidationResult: null,
    error: null,
    cacheHits: 0,
    cacheMisses: 0,
    fieldErrors: {},
  );

  ValidationState copyWith({
    bool? loading,
    Map<String, dynamic>? lastValidationResult,
    String? error,
    int? cacheHits,
    int? cacheMisses,
    Map<String, String?>? fieldErrors,
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
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    lastValidationResult,
    error,
    cacheHits,
    cacheMisses,
    fieldErrors,
  ];
}

class ValidationCubit extends Cubit<ValidationState> {
  final ValidationService _validationService;

  final Map<String, _CachedValidationResult> _validationCache = {};

  final int _maxCacheSize = 50;

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

  String? getFieldError(String fieldName) => state.fieldErrors[fieldName];

  void setFieldError(String fieldName, String? error) {
    if (state.fieldErrors[fieldName] == error) {
      return;
    }
    final updated = Map<String, String?>.from(state.fieldErrors);
    updated[fieldName] = error;
    emit(state.copyWith(fieldErrors: updated));
  }

  void clearFieldErrors() {
    if (state.fieldErrors.isEmpty) {
      return;
    }
    emit(state.copyWith(fieldErrors: const {}));
  }

  void clearFieldError(String fieldName) {
    if (!state.fieldErrors.containsKey(fieldName)) {
      return;
    }
    final updated = Map<String, String?>.from(state.fieldErrors);
    updated.remove(fieldName);
    emit(state.copyWith(fieldErrors: updated));
  }

  bool validateAllFields(Map<String, Map<String, dynamic>> fieldValidators) {
    var isValid = true;
    final updatedErrors = <String, String?>{};

    fieldValidators.forEach((fieldName, validatorInfo) {
      final value = validatorInfo['value'] as String?;
      final validator = validatorInfo['validator'] as String? Function(String?);
      final error = validator(value);
      updatedErrors[fieldName] = error;
      if (error != null) {
        isValid = false;
      }
    });

    emit(state.copyWith(fieldErrors: updatedErrors));
    return isValid;
  }

  bool validateField(
    String fieldName,
    String value,
    String? Function(String) validator,
  ) {
    final error = validator(value);
    setFieldError(fieldName, error);
    return error == null;
  }

  bool validateFieldWithFeedback(
    String fieldName,
    String value,
    String? Function(String) validator, {
    bool updateState = true,
  }) {
    final error = validator(value);
    if (updateState) {
      setFieldError(fieldName, error);
    }
    return error == null;
  }

  void markFieldAsValid(String fieldName) => setFieldError(fieldName, null);

  ValidationStatus fieldStatus(String fieldName) {
    final error = state.fieldErrors[fieldName];
    if (error != null) {
      return ValidationStatus.invalid;
    }
    if (state.fieldErrors.containsKey(fieldName)) {
      return ValidationStatus.valid;
    }
    return ValidationStatus.notValidated;
  }

  bool hasBeenValidated(String fieldName) =>
      state.fieldErrors.containsKey(fieldName);

  void processValidationResult(
    Map<String, dynamic>? result,
    Map<String, String> fieldMappings,
  ) {
    if (result == null || result['valid'] == true) {
      return;
    }
    final errors = result.containsKey('validationErrors')
        ? result['validationErrors'] as List<dynamic>? ?? []
        : const <dynamic>[];
    mapValidationErrorsToFields(errors, fieldMappings);
  }

  void mapValidationErrorsToFields(
    List<dynamic> errors,
    Map<String, String> fieldMappings,
  ) {
    final mappedErrors = ValidationErrorMapper.mapErrors(errors, fieldMappings);
    emit(state.copyWith(fieldErrors: mappedErrors));
  }

  ValidationCubit({ValidationService? validationService})
    : _validationService = validationService ?? getIt<ValidationService>(),
      super(ValidationState.initial());

  Future<bool> validateObjectEvent(ObjectEvent event) async {
    return _validateEvent(
      () => _validationService.validateObjectEventModel(event),
      cacheKey: _generateEventCacheKey(event.toJson(), 'ObjectEvent'),
    );
  }

  Future<bool> validateAggregationEvent(AggregationEvent event) async {
    return _validateEvent(
      () => _validationService.validateAggregationEventModel(event),
      cacheKey: _generateEventCacheKey(event.toJson(), 'AggregationEvent'),
    );
  }

  Future<bool> validateTransactionEvent(TransactionEvent event) async {
    return _validateEvent(
      () => _validationService.validateTransactionEventModel(event),
      cacheKey: _generateEventCacheKey(event.toJson(), 'TransactionEvent'),
    );
  }

  Future<bool> validateTransformationEvent(TransformationEvent event) async {
    return _validateEvent(
      () => _validationService.validateTransformationEventModel(event),
      cacheKey: _generateEventCacheKey(event.toJson(), 'TransformationEvent'),
    );
  }

  Future<List<Map<String, dynamic>>> validateObjectEventBatch(
    List<ObjectEvent> events,
  ) async {
    return _validateBatch(
      events,
      (event) => _validationService.validateObjectEventModel(event),
    );
  }

  Future<List<Map<String, dynamic>>> validateAggregationEventBatch(
    List<AggregationEvent> events,
  ) async {
    return _validateBatch(
      events,
      (event) => _validationService.validateAggregationEventModel(event),
    );
  }

  Future<List<Map<String, dynamic>>> validateTransactionEventBatch(
    List<TransactionEvent> events,
  ) async {
    return _validateBatch(
      events,
      (event) => _validationService.validateTransactionEventModel(event),
    );
  }

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

  Future<List<Map<String, dynamic>>> _validateBatch<T>(
    List<T> events,
    Future<Map<String, dynamic>> Function(T event) validateFunction, {
    int concurrencyLimit = 5,
  }) async {
    emit(state.copyWith(loading: true, clearError: true));

    final results = <Map<String, dynamic>>[];

    try {
      for (int i = 0; i < events.length; i += concurrencyLimit) {
        final end = (i + concurrencyLimit < events.length)
            ? i + concurrencyLimit
            : events.length;
        final batch = events.sublist(i, end);

        final batchResults = await Future.wait(
          batch.map((event) async {
            try {
              final eventJson = event is Map
                  ? event
                  : (event as dynamic).toJson();
              final cacheKey = _generateEventCacheKey(eventJson, T.toString());

              final cachedResult = _getCachedResult(cacheKey);
              if (cachedResult != null) {
                emit(state.copyWith(cacheHits: state.cacheHits + 1));
                return cachedResult;
              }

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

  void clearValidation() {
    emit(
      state.copyWith(
        clearValidation: true,
        clearError: true,
        fieldErrors: const {},
      ),
    );
  }

  Map<String, dynamic>? _getCachedResult(String cacheKey) {
    final cachedResult = _validationCache[cacheKey];
    if (cachedResult != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - cachedResult.timestamp <= _cacheDuration) {
        return cachedResult.result;
      } else {
        _validationCache.remove(cacheKey);
      }
    }
    return null;
  }

  void _cacheValidationResult(String cacheKey, Map<String, dynamic> result) {
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

  void clearCache() {
    _validationCache.clear();
    emit(state.copyWith(cacheHits: 0, cacheMisses: 0));
  }

  String _generateEventCacheKey(
    Map<String, dynamic> eventData,
    String eventType,
  ) {
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
