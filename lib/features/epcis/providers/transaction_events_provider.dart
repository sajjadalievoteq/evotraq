import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_event_service.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_event_service_impl.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

/// Provider for managing Transaction Events state and operations
class TransactionEventsProvider with ChangeNotifier {
  final TransactionEventService _service;
  
  List<TransactionEvent> _transactionEvents = [];
  bool _loading = false;
  String? _error;
  int _totalPages = 0;
  int _totalElements = 0;
  TransactionEvent? _selectedEvent;
  
  /// Constructor with optional service dependency injection for testing
  TransactionEventsProvider({TransactionEventService? service, required AppConfig appConfig}) 
      : _service = service ?? TransactionEventServiceImpl(
          httpClient: http.Client(),
          tokenManager: TokenManager(),
          appConfig: appConfig,
        );
  
  /// Current list of transaction events
  List<TransactionEvent> get transactionEvents => _transactionEvents;
  
  /// Whether data is currently loading
  bool get loading => _loading;
  
  /// Any error message
  String? get error => _error;
  
  /// Total number of pages
  int get totalPages => _totalPages;
  
  /// Total number of elements
  int get totalElements => _totalElements;
  
  /// Currently selected event
  TransactionEvent? get selectedEvent => _selectedEvent;
  
  /// Load Transaction Events with pagination and optional filters
  Future<void> loadTransactionEvents({
    int page = 0,
    int size = 20,
    String? bizStep,
    String? disposition,
    String? locationGLN,
    DateTime? startTime,
    DateTime? endTime,
    bool loadMore = false,
  }) async {
    _loading = true;
    _error = null;
    if (!loadMore) {
      // If not loading more, clear the existing events
      _transactionEvents = [];
    }
    notifyListeners();
    
    try {
      List<TransactionEvent> events = [];
      
      // Apply filters if provided
      if (bizStep != null && locationGLN != null && startTime != null && endTime != null) {
        events = await _service.findTransactionEventsByLocationAndTimeWindow(
          locationGLN, startTime, endTime);
      } else if (bizStep != null) {
        events = await _service.findTransactionEventsByBusinessStep(bizStep);
      } else if (disposition != null) {
        // Using a placeholder EPC since the API requires an EPC
        events = await _service.findTransactionEventsByDispositionAndEPC(disposition, "");      } else {
        // No filters applied, get all events by fetching each action type and combining them
        List<TransactionEvent> addEvents = await _service.findTransactionEventsByAction("ADD");
        List<TransactionEvent> observeEvents = await _service.findTransactionEventsByAction("OBSERVE");
        List<TransactionEvent> deleteEvents = await _service.findTransactionEventsByAction("DELETE");
        
        events = [...addEvents, ...observeEvents, ...deleteEvents];
        // Sort by eventTime descending to show newest first
        events.sort((a, b) => b.eventTime.compareTo(a.eventTime));
      }
      
      if (loadMore) {
        _transactionEvents.addAll(events);
      } else {
        _transactionEvents = events;
      }
      
      _totalElements = events.length;
      _totalPages = 1; // Basic pagination handling
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
    /// Get a Transaction Event by ID (UUID) or Event ID (string like event_xxx)
  Future<TransactionEvent?> getTransactionEventById(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Clean up the ID by extracting just the UUID part if it's in a URN format
      String cleanId;
      if (id.contains(':')) {
        cleanId = id.split(':').last;
      } else {
        cleanId = id;
      }
      
      // Check if this is a UUID or an event ID string
      // UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
      // Event ID format: event_xxxxxxxxxx_xxx
      final isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(cleanId);
      
      if (isUuid) {
        _selectedEvent = await _service.getTransactionEventById(cleanId);
      } else {
        _selectedEvent = await _service.getTransactionEventByEventId(cleanId);
      }
      _loading = false;
      notifyListeners();
      return _selectedEvent;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Create an ADD Transaction Event
  Future<TransactionEvent> createAddTransactionEvent({
    required String bizTransactionType,
    required String bizTransactionId,
    required List<String> epcs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required Map<String, String> bizData,
    required DateTime eventTime,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newEvent = await _service.createAddTransactionEvent(
        bizTransactionType,
        bizTransactionId,
        epcs,
        locationGLN,
        businessStep,
        disposition,
        bizData,
        eventTime,
      );
      
      _transactionEvents.insert(0, newEvent);
      _loading = false;
      notifyListeners();
      return newEvent;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
  
  /// Create a DELETE Transaction Event
  Future<TransactionEvent> createDeleteTransactionEvent({
    required String bizTransactionType,
    required String bizTransactionId,
    required List<String> epcs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required Map<String, String> bizData,
    required DateTime eventTime,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newEvent = await _service.createDeleteTransactionEvent(
        bizTransactionType,
        bizTransactionId,
        epcs,
        locationGLN,
        businessStep,
        disposition,
        bizData,
        eventTime,
      );
      
      _transactionEvents.insert(0, newEvent);
      _loading = false;
      notifyListeners();
      return newEvent;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
  
  /// Create an OBSERVE Transaction Event
  Future<TransactionEvent> createObserveTransactionEvent({
    required String bizTransactionType,
    required String bizTransactionId,
    required List<String> epcs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required Map<String, String> bizData,
    required DateTime eventTime,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newEvent = await _service.createObserveTransactionEvent(
        bizTransactionType,
        bizTransactionId,
        epcs,
        locationGLN,
        businessStep,
        disposition,
        bizData,
        eventTime,
      );
      
      _transactionEvents.insert(0, newEvent);
      _loading = false;
      notifyListeners();
      return newEvent;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
  
  /// Update an existing Transaction Event
  Future<void> updateTransactionEvent(TransactionEvent event) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedEvent = await _service.updateTransactionEvent(event.id!, event);
      
      // Update in list if present
      final index = _transactionEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _transactionEvents[index] = updatedEvent;
      }
      
      // Update selected event if it's the same one
      if (_selectedEvent != null && _selectedEvent!.id == event.id) {
        _selectedEvent = updatedEvent;
      }
      
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
  
  /// Delete a Transaction Event
  Future<void> deleteTransactionEvent(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _service.deleteTransactionEvent(id);
      
      // Remove from list
      _transactionEvents.removeWhere((event) => event.id == id);
      
      // Clear selected event if it's the same one
      if (_selectedEvent != null && _selectedEvent!.id == id) {
        _selectedEvent = null;
      }
      
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
  
  /// Find Transaction Events by EPC
  Future<void> findEventsByEPC(String epc) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      _transactionEvents = await _service.findTransactionEventsByEPC(epc);
      _totalElements = _transactionEvents.length;
      _totalPages = 1; // Simplified pagination for search results
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Find Transaction Events by business step and EPC
  Future<void> findEventsByBusinessStepAndEPC(String businessStep, String epc) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      _transactionEvents = await _service.findTransactionEventsByBusinessStepAndEPC(businessStep, epc);
      _totalElements = _transactionEvents.length;
      _totalPages = 1; // Simplified pagination for search results
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Find active transactions for an EPC
  Future<void> findActiveTransactionsForEPC(String epc) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      _transactionEvents = await _service.findActiveTransactionsForEPC(epc);
      _totalElements = _transactionEvents.length;
      _totalPages = 1;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Find transaction history for an EPC
  Future<void> findTransactionHistoryForEPC(String epc) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      _transactionEvents = await _service.findTransactionHistoryForEPC(epc);
      _totalElements = _transactionEvents.length;
      _totalPages = 1;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}