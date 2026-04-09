import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';

/// Service for interacting with transaction events in the API
abstract class TransactionEventService {
  /// Get a transaction event by ID
  Future<TransactionEvent> getTransactionEventById(String id);
  
  /// Get a transaction event by event ID
  Future<TransactionEvent> getTransactionEventByEventId(String eventId);
  
  /// Create a new transaction event
  Future<TransactionEvent> createTransactionEvent(TransactionEvent event);
  
  /// Update an existing transaction event
  Future<TransactionEvent> updateTransactionEvent(String id, TransactionEvent event);
  
  /// Delete a transaction event
  Future<void> deleteTransactionEvent(String id);
  
  /// Find transaction events by action
  Future<List<TransactionEvent>> findTransactionEventsByAction(String action);
  
  /// Find transaction events by EPC
  Future<List<TransactionEvent>> findTransactionEventsByEPC(String epc);
  
  /// Find transaction events by EPC class
  Future<List<TransactionEvent>> findTransactionEventsByEPCClass(String epcClass);
  
  /// Find transaction events by business transaction type and ID
  Future<List<TransactionEvent>> findTransactionEventsByBizTransaction(String type, String id);
  
  /// Find transaction events by business step
  Future<List<TransactionEvent>> findTransactionEventsByBusinessStep(String businessStep);
  
  /// Find transaction events by business step and EPC
  Future<List<TransactionEvent>> findTransactionEventsByBusinessStepAndEPC(String businessStep, String epc);
  
  /// Find transaction events by disposition and EPC
  Future<List<TransactionEvent>> findTransactionEventsByDispositionAndEPC(String disposition, String epc);
  
  /// Find transaction events by business location and time window
  Future<List<TransactionEvent>> findTransactionEventsByLocationAndTimeWindow(
      String locationGLN, DateTime startTime, DateTime endTime);
  
  /// Find all active transactions for a specific EPC
  Future<List<TransactionEvent>> findActiveTransactionsForEPC(String epc);
  
  /// Find transaction history for a specific EPC
  Future<List<TransactionEvent>> findTransactionHistoryForEPC(String epc);
  
  /// Create an EPCIS ADD transaction event
  Future<TransactionEvent> createAddTransactionEvent(
      String bizTransactionType, 
      String bizTransactionId, 
      List<String> epcs, 
      String locationGLN, 
      String businessStep, 
      String disposition, 
      Map<String, String> bizData,
      DateTime eventTime);
  
  /// Create an EPCIS DELETE transaction event
  Future<TransactionEvent> createDeleteTransactionEvent(
      String bizTransactionType, 
      String bizTransactionId, 
      List<String> epcs, 
      String locationGLN, 
      String businessStep, 
      String disposition,
      Map<String, String> bizData,
      DateTime eventTime);
  
  /// Create an EPCIS OBSERVE transaction event
  Future<TransactionEvent> createObserveTransactionEvent(
      String bizTransactionType, 
      String bizTransactionId, 
      List<String> epcs, 
      String locationGLN, 
      String businessStep, 
      String disposition,
      Map<String, String> bizData,
      DateTime eventTime);
}