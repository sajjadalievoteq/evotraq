import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';

/// Service for interacting with aggregation events in the API
abstract class AggregationEventService {
  /// Get all aggregation events with pagination
  Future<List<AggregationEvent>> getAllAggregationEvents(int page, int size);
  
  /// Get an aggregation event by ID
  Future<AggregationEvent> getAggregationEventById(String id);
  
  /// Get an aggregation event by event ID
  Future<AggregationEvent> getAggregationEventByEventId(String eventId);
  
  /// Create a new aggregation event
  Future<AggregationEvent> createAggregationEvent(AggregationEvent event);
  
  /// Update an existing aggregation event
  Future<AggregationEvent> updateAggregationEvent(String id, AggregationEvent event);
  
  /// Delete an aggregation event
  Future<void> deleteAggregationEvent(String id);
  
  /// Find aggregation events by action
  Future<List<AggregationEvent>> findAggregationEventsByAction(String action);
  
  /// Find aggregation events by parent EPC
  Future<List<AggregationEvent>> findAggregationEventsByParentEPC(String parentEPC);
  
  /// Find aggregation events by child EPC
  Future<List<AggregationEvent>> findAggregationEventsByChildEPC(String childEPC);
  
  /// Find aggregation events by parent EPC and action
  Future<List<AggregationEvent>> findAggregationEventsByParentEPCAndAction(String parentEPC, String action);
  
  /// Find aggregation events by child EPC and action
  Future<List<AggregationEvent>> findAggregationEventsByChildEPCAndAction(String childEPC, String action);
  
  /// Find current children of a parent EPC (most recent ADD events)
  Future<List<AggregationEvent>> findCurrentChildrenOfParent(String parentEPC);
  
  /// Find current parent of a child EPC (most recent ADD event)
  /// Throws exception if not found
  Future<AggregationEvent> findCurrentParentOfChild(String childEPC);
  
  /// Track the history of a parent EPC's aggregations over time
  Future<List<AggregationEvent>> trackParentHistory(String parentEPC);
  
  /// Track the history of a child EPC's aggregations over time
  Future<List<AggregationEvent>> trackChildHistory(String childEPC);
  
  /// Find aggregation events by business step and parent EPC
  Future<List<AggregationEvent>> findAggregationEventsByBusinessStepAndParentEPC(String businessStep, String parentEPC);
  
  /// Find aggregation events by business location and time window
  Future<List<AggregationEvent>> findAggregationEventsByLocationAndTimeWindow(
      String locationGLN, DateTime startTime, DateTime endTime);
  
  /// Create an EPCIS ADD aggregation event for packing child EPCs into a parent
  Future<AggregationEvent> createPackEvent(
      String parentEPC, 
      List<String> childEPCs, 
      String locationGLN, 
      String businessStep,
      String disposition, 
      Map<String, String> bizData,
      {List<Map<String, dynamic>>? sourceList,
      List<Map<String, dynamic>>? destinationList});
  
  /// Create an EPCIS DELETE aggregation event for unpacking a parent
  Future<AggregationEvent> createUnpackEvent(
      String parentEPC, 
      List<String>? childEPCs, 
      String locationGLN, 
      String businessStep,
      String disposition, 
      Map<String, String> bizData,
      {List<Map<String, dynamic>>? sourceList,
      List<Map<String, dynamic>>? destinationList});

  /// Find contents of a container by parent EPC
  Future<List<String>> findContainerContents(String parentEPC);
  
  /// Verify the aggregation hierarchy for an EPC
  /// Returns true if the hierarchy is valid, false otherwise
  Future<bool> verifyHierarchy(String epc);
}