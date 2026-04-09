import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_types.dart';

/// Service for interacting with object events in the API
/// Follows the GS1 EPCIS 2.0/1.3 standards with enhanced Phase 3 capabilities
abstract class ObjectEventService {
  /// Get all events with pagination
  Future<Map<String, dynamic>> getAllEventsPaginated(int page, int size);

  /// Get an object event by ID
  Future<ObjectEvent> getObjectEventById(String id);
  
  /// Get an object event by event ID
  Future<ObjectEvent> getObjectEventByEventId(String eventId);
  
  /// Create a new object event
  Future<ObjectEvent> createObjectEvent({
    required String action,
    required String businessStep,
    required String disposition,
    String? readPointGLN,
    String? businessLocationGLN,
    List<String>? epcs,
    List<String>? epcClasses,
    List<QuantityElement>? quantities,
    Map<String, dynamic>? ilmd,
    Map<String, String>? bizData,
    List<SourceDestination>? sources,
    List<SourceDestination>? destinations,
    String? persistentDisposition,
    List<Map<String, dynamic>>? sensorElements,
    List<Map<String, dynamic>>? certificationInfo,
    EPCISVersion epcisVersion = EPCISVersion.v2_0,
  });
  
  /// Validate an object event without persisting it
  Future<Map<String, dynamic>> validateObjectEvent(ObjectEvent event);
  
  /// Create multiple object events in batch
  Future<List<ObjectEvent>> createObjectEventsBatch(List<ObjectEvent> events);
  
  /// Update an existing object event
  Future<ObjectEvent> updateObjectEvent(String id, ObjectEvent event);
  
  /// Delete an object event
  Future<void> deleteObjectEvent(String id);
  
  /// Find object events by action
  Future<List<ObjectEvent>> findObjectEventsByAction(String action);
  
  /// Find object events by EPC
  Future<List<ObjectEvent>> findObjectEventsByEPC(String epc);
  
  /// Find object events by multiple EPCs
  Future<List<ObjectEvent>> findObjectEventsByEPCs(List<String> epcs);
  
  /// Find object events by EPC class
  Future<List<ObjectEvent>> findObjectEventsByEPCClass(String epcClass);
  
  /// Find object events by ILMD property
  Future<List<ObjectEvent>> findObjectEventsByILMD(String property, String value);
  
  /// Find object events by quantity
  Future<List<ObjectEvent>> findObjectEventsByQuantity(String epcClass, double minQuantity, double maxQuantity);
  
  /// Find object events by business step and location
  Future<List<ObjectEvent>> findObjectEventsByBusinessStep(String businessStep);
  
  /// Find object events by disposition
  Future<List<ObjectEvent>> findObjectEventsByDisposition(String disposition);
  
  /// Find object events by location GLN
  Future<List<ObjectEvent>> findObjectEventsByLocation(String locationGLN);
  
  /// Find object events by time window
  Future<List<ObjectEvent>> findObjectEventsByTimeWindow(DateTime startTime, DateTime endTime);
  
  /// Find object events by location and time window
  Future<List<ObjectEvent>> findObjectEventsByLocationAndTimeWindow(
      String locationGLN, DateTime startTime, DateTime endTime);
  
  /// Find object events by business step and EPC
  Future<List<ObjectEvent>> findObjectEventsByBusinessStepAndEPC(String businessStep, String epc);

  /// Get object event statistics
  Future<Map<String, dynamic>> getEventStatistics({DateTime? startTime, DateTime? endTime});
  
  /// Find EPC history (all events for a specific EPC)
  Future<List<ObjectEvent>> findEPCHistory(String epc);
  
  /// Get current status of EPC (most recent object event)
  Future<ObjectEvent> getCurrentStatusOfEPC(String epc);
  
  /// Create an OBSERVE object event
  Future<ObjectEvent> createObserveEvent(String epc, String locationGLN, String businessStep, 
      String disposition, Map<String, String> bizData);
  
  /// Create an ADD object event
  Future<ObjectEvent> createAddEvent(String epc, String locationGLN, String businessStep, 
      String disposition, Map<String, dynamic> ilmd, Map<String, String> bizData);
      
  /// Create a DELETE object event
  Future<ObjectEvent> createDeleteEvent(String epc, String locationGLN, String businessStep, 
      String disposition, Map<String, String> bizData);
      
  /// Find object events with sensor data (EPCIS 2.0)
  Future<List<ObjectEvent>> findObjectEventsWithSensorData(Map<String, dynamic> sensorCriteria);
  
  /// Validate EPC format according to GS1 standards
  Future<bool> validateEPC(String epc);
  
  /// Convert GS1 element string to EPC URI
  Future<String> convertGS1ElementStringToEPC(String gs1ElementString);
}
