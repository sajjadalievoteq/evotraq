import 'package:traqtrace_app/features/epcis/models/sensor_element.dart';

/// Service interface for SensorElement operations
abstract class SensorElementService {
  /// Get all sensor elements
  /// 
  /// Returns a list of all sensor elements
  Future<List<SensorElement>> getAllSensorElements();
  
  /// Get paginated sensor elements
  /// 
  /// [page] is the page number (0-indexed)
  /// [size] is the number of elements per page
  /// Returns a page of sensor elements
  Future<Map<String, dynamic>> getAllSensorElementsPaginated(int page, int size);
  
  /// Get a sensor element by ID
  /// 
  /// [id] is the sensor element ID
  /// Returns the sensor element or throws an exception if not found
  Future<SensorElement> getSensorElementById(String id);
  
  /// Create a new sensor element
  /// 
  /// [sensorElement] is the sensor element to create
  /// Returns the created sensor element
  Future<SensorElement> createSensorElement(SensorElement sensorElement);
  
  /// Update an existing sensor element
  /// 
  /// [id] is the ID of the sensor element to update
  /// [sensorElement] contains the updated data
  /// Returns the updated sensor element
  Future<SensorElement> updateSensorElement(String id, SensorElement sensorElement);
  
  /// Delete a sensor element by ID
  /// 
  /// [id] is the ID of the sensor element to delete
  Future<void> deleteSensorElement(String id);
  
  /// Get sensor elements by event ID
  /// 
  /// [eventId] is the ID of the EPCIS event
  /// Returns sensor elements associated with the event
  Future<List<SensorElement>> getSensorElementsByEventId(String eventId);
  
  /// Get sensor elements by device ID
  /// 
  /// [deviceId] is the ID of the sensor device
  /// Returns sensor elements from the specified device
  Future<List<SensorElement>> getSensorElementsByDeviceId(String deviceId);
  
  /// Get sensor elements by measurement type
  /// 
  /// [type] is the type of measurement (e.g., "Temperature", "Humidity")
  /// Returns sensor elements with the specified measurement type
  Future<List<SensorElement>> getSensorElementsByMeasurementType(String type);
}
