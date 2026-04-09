import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/features/epcis/models/transformation_event.dart';
import 'package:traqtrace_app/features/epcis/services/transformation_event_service.dart';

/// Provider for managing transformation events state
class TransformationEventsProvider with ChangeNotifier {
  final TransformationEventService _service;
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  
  List<TransformationEvent> _transformationEvents = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  /// Constructor
  TransformationEventsProvider(this._service, this._httpClient, this._tokenManager, this._appConfig);
  
  /// Get all transformation events
  List<TransformationEvent> get transformationEvents => _transformationEvents;
  
  /// Loading state
  bool get isLoading => _isLoading;
  
  /// Error message
  String? get errorMessage => _errorMessage;
  /// Load all transformation events
  Future<void> loadTransformationEvents() async {
    _setLoading(true);
    try {
      // Use the direct API call to match the backend's paginated response
      final response = await _httpClient.get(
        Uri.parse('${_appConfig.apiBaseUrl}/transformation-events'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['content'] != null && data['content'] is List) {
          _transformationEvents = (data['content'] as List)
              .map((json) => TransformationEvent.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
        _clearError();
      } else {
        throw Exception('Failed to load transformation events: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Failed to load transformation events: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
    /// Create a transformation process
  Future<TransformationEvent> createTransformationProcess(
      {required String transformationId,
      required Set<String> inputEPCs,
      required Set<String> outputEPCs,
      required String locationGLN,
      required String businessStep,
      required String disposition,
      required Map<String, String> parameters,
      required Map<String, String> bizData}) async {
    _setLoading(true);
    try {
      final newEvent = await _service.createTransformationProcess(
        transformationId,
        inputEPCs,
        outputEPCs,
        locationGLN,
        businessStep,
        disposition,
        parameters,
        bizData,
      );
      
      _transformationEvents = [newEvent, ..._transformationEvents];
      _clearError();
      notifyListeners();
      return newEvent;
    } catch (e) {
      _setError('Failed to create transformation process: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Create a transformation event
  Future<TransformationEvent> createTransformationEvent(TransformationEvent event) async {
    _setLoading(true);
    try {
      final newEvent = await _service.createTransformationEvent(event);
      
      _transformationEvents = [newEvent, ..._transformationEvents];
      _clearError();
      notifyListeners();
      return newEvent;
    } catch (e) {
      _setError('Failed to create transformation event: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Find transformation events by transformation ID
  Future<List<TransformationEvent>> findByTransformationId(String transformationId) async {
    _setLoading(true);
    try {
      final events = await _service.findTransformationEventsByTransformationId(transformationId);
      _clearError();
      return events;
    } catch (e) {
      _setError('Failed to find transformation events: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Find transformation events by input EPC
  Future<List<TransformationEvent>> findByInputEPC(String inputEPC) async {
    _setLoading(true);
    try {
      final events = await _service.findTransformationEventsByInputEPC(inputEPC);
      _clearError();
      return events;
    } catch (e) {
      _setError('Failed to find transformation events: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Find transformation events by output EPC
  Future<List<TransformationEvent>> findByOutputEPC(String outputEPC) async {
    _setLoading(true);
    try {
      final events = await _service.findTransformationEventsByOutputEPC(outputEPC);
      _clearError();
      return events;
    } catch (e) {
      _setError('Failed to find transformation events: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Find transformation events by input EPC class
  Future<List<TransformationEvent>> findByInputEPCClass(String inputEPCClass) async {
    _setLoading(true);
    try {
      final events = await _service.findTransformationEventsByInputEPCClass(inputEPCClass);
      _clearError();
      return events;
    } catch (e) {
      _setError('Failed to find transformation events: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Find transformation events by output EPC class
  Future<List<TransformationEvent>> findByOutputEPCClass(String outputEPCClass) async {
    _setLoading(true);
    try {
      final events = await _service.findTransformationEventsByOutputEPCClass(outputEPCClass);
      _clearError();
      return events;
    } catch (e) {
      _setError('Failed to find transformation events: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Find transformation history for an output EPC
  Future<List<TransformationEvent>> findTransformationHistory(String outputEPC) async {
    _setLoading(true);
    try {
      final events = await _service.findTransformationHistoryForOutput(outputEPC);
      _clearError();
      return events;
    } catch (e) {
      _setError('Failed to find transformation history: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get a transformation event by ID
  Future<TransformationEvent> getTransformationEventById(String eventId) async {
    _setLoading(true);
    try {
      final event = await _service.getTransformationEventByEventId(eventId);
      _clearError();
      return event;
    } catch (e) {
      _setError('Failed to get transformation event: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
    /// Update a transformation event
  Future<void> updateTransformationEvent(TransformationEvent event) async {
    _setLoading(true);
    try {
      if (event.id == null) {
        throw Exception('Cannot update transformation event without an ID');
      }
      
      final updatedEvent = await _service.updateTransformationEvent(event.id!, event);
      
      _transformationEvents = _transformationEvents.map((e) {
        return e.id == updatedEvent.id ? updatedEvent : e;
      }).toList();
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update transformation event: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Delete a transformation event
  Future<void> deleteTransformationEvent(String id) async {
    _setLoading(true);
    try {
      await _service.deleteTransformationEvent(id);
      
      _transformationEvents = _transformationEvents.where((e) => e.id != id).toList();
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete transformation event: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Track transformations for a specific EPC
  Future<List<TransformationEvent>> trackTransformationsByEPC(String epc) async {
    _setLoading(true);
    try {
      final events = await _service.findTransformationsByEPC(epc);
      _clearError();
      return events;
    } catch (e) {
      _setError('Failed to track EPC transformations: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  /// Find transformations by input and output relationship
  Future<List<TransformationEvent>> findTransformationsByInputOutput(
      String inputEPC, String outputEPC) async {
    _setLoading(true);
    try {
      final events = await _service.findTransformationsByInputAndOutputEPC(inputEPC, outputEPC);
      _clearError();
      return events;
    } catch (e) {
      _setError('Failed to find input-output transformations: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get transformation events by transformation ID
  Future<List<TransformationEvent>> getTransformationsByTransformationId(String transformationId) async {
    _setLoading(true);
    try {
      final events = await _service.findTransformationEventsByTransformationId(transformationId);
      _clearError();
      return events;
    } catch (e) {
      _setError('Failed to get transformations by ID: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}