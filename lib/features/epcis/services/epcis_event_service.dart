import 'package:traqtrace_app/features/epcis/models/epcis_document_dto.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_query_parameters_dto.dart';

/// Service interface for EPCIS Event operations
abstract class EPCISEventService {
  
  /// Get all EPCIS events
  /// 
  /// Returns a list of all EPCIS events
  Future<List<EPCISEvent>> getAllEvents();
  
  /// Get paginated EPCIS events
  /// 
  /// [page] is the page number (0-indexed)
  /// [size] is the number of events per page
  /// Returns a page of EPCIS events
  Future<Map<String, dynamic>> getAllEventsPaginated(int page, int size);
  
  /// Delete an EPCIS event by ID
  /// 
  /// [id] is the ID of the event to delete
  /// Throws an exception if event not found
  Future<void> deleteEvent(String id);
  
  /// Find events by time window
  /// 
  /// [startTime] is the start of the time window
  /// [endTime] is the end of the time window
  /// Returns events that occurred within the specified time window
  Future<List<EPCISEvent>> findEventsByTimeWindow(DateTime startTime, DateTime endTime);
  
  /// Capture multiple events in an EPCIS document
  /// 
  /// [epcisDocument] is the document containing events
  /// Returns a summary of captured events
  Future<Map<String, dynamic>> captureEvents(EPCISDocumentDTO epcisDocument);
  
  /// Get an event by ID
  /// 
  /// [id] is the event ID
  /// Returns the event or throws an exception if not found
  Future<EPCISEvent> getEventById(String id);
  
  /// Get events by EPC
  /// 
  /// [epc] is the EPC to search for
  /// Returns events associated with the EPC
  Future<List<EPCISEvent>> getEventsByEPC(String epc);
  
  /// Query events using complex parameters
  /// 
  /// [queryParams] contains all query criteria
  /// Returns events matching the query parameters
  Future<List<EPCISEvent>> queryEvents(EPCISQueryParametersDTO queryParams);
  
  /// Get events by business step
  /// 
  /// [businessStep] is the business step
  /// Returns events with the matching business step
  Future<List<EPCISEvent>> getEventsByBusinessStep(String businessStep);
  
  /// Get events by disposition
  /// 
  /// [disposition] is the disposition
  /// Returns events with the matching disposition
  Future<List<EPCISEvent>> getEventsByDisposition(String disposition);
  
  /// Get events by location
  /// 
  /// [locationGLN] is the location GLN
  /// Returns events at the specified location
  Future<List<EPCISEvent>> getEventsByLocation(String locationGLN);
  
  /// Get the history of events for a specific item
  /// 
  /// [epc] is the EPC
  /// Returns chronological list of events
  Future<List<EPCISEvent>> getItemHistory(String epc);
  
  /// Get the current status of an item
  /// 
  /// [epc] is the EPC
  /// Returns the current status information
  Future<Map<String, dynamic>> getItemStatus(String epc);
}