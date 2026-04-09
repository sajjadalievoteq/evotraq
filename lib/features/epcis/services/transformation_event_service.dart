import 'package:traqtrace_app/features/epcis/models/transformation_event.dart';

/// Service for interacting with transformation events in the API
abstract class TransformationEventService {
  /// Get a transformation event by ID
  Future<TransformationEvent> getTransformationEventById(String id);
  
  /// Get a transformation event by event ID
  Future<TransformationEvent> getTransformationEventByEventId(String eventId);
  
  /// Create a new transformation event
  Future<TransformationEvent> createTransformationEvent(TransformationEvent event);
  
  /// Update an existing transformation event
  Future<TransformationEvent> updateTransformationEvent(String id, TransformationEvent event);
  
  /// Delete a transformation event
  Future<void> deleteTransformationEvent(String id);
  
  /// Find transformation events by transformation ID
  Future<List<TransformationEvent>> findTransformationEventsByTransformationId(String transformationId);
  
  /// Find transformation events by input EPC
  Future<List<TransformationEvent>> findTransformationEventsByInputEPC(String inputEPC);
  
  /// Find transformation events by output EPC
  Future<List<TransformationEvent>> findTransformationEventsByOutputEPC(String outputEPC);
  
  /// Find transformation events by input EPC class
  Future<List<TransformationEvent>> findTransformationEventsByInputEPCClass(String inputEPCClass);
  
  /// Find transformation events by output EPC class
  Future<List<TransformationEvent>> findTransformationEventsByOutputEPCClass(String outputEPCClass);
  
  /// Find transformation events by input and output EPC
  Future<List<TransformationEvent>> findTransformationEventsByInputAndOutputEPC(String inputEPC, String outputEPC);
  
  /// Find transformation events by transformation parameter
  Future<List<TransformationEvent>> findTransformationEventsByParameter(String paramName, String paramValue);
  
  /// Find history of transformations that produced an output EPC
  Future<List<TransformationEvent>> findTransformationHistoryForOutput(String outputEPC);
  
  /// Find transformation events by business location and time window
  Future<List<TransformationEvent>> findTransformationEventsByLocationAndTimeWindow(
    String locationGLN, 
    DateTime startTime, 
    DateTime endTime
  );
  
  /// Create a transformation event that transforms input EPCs into output EPCs
  Future<TransformationEvent> createTransformationProcess(
    String transformationId, 
    Set<String> inputEPCs, 
    Set<String> outputEPCs,
    String locationGLN, 
    String businessStep,
    String disposition, 
    Map<String, String> parameters,
    Map<String, String> bizData
  );
  /// Find transformations involving a specific EPC (either as input or output)
  Future<List<TransformationEvent>> findTransformationsByEPC(String epc);
  
  /// Find transformations with specific input-output relationship
  Future<List<TransformationEvent>> findTransformationsByInputAndOutputEPC(String inputEPC, String outputEPC);
  }