import 'package:traqtrace_app/features/epcis/models/geospatial_coordinates.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';

/// Service interface for GeospatialCoordinates operations
abstract class GeospatialCoordinatesService {
  /// Get all geospatial coordinates records
  /// 
  /// Returns a list of all geospatial coordinates records
  Future<List<GeospatialCoordinates>> getAllGeospatialCoordinates();
  
  /// Get paginated geospatial coordinates
  /// 
  /// [page] is the page number (0-indexed)
  /// [size] is the number of records per page
  /// Returns a page of geospatial coordinates records
  Future<Map<String, dynamic>> getAllGeospatialCoordinatesPaginated(int page, int size);
  
  /// Get geospatial coordinates by ID
  /// 
  /// [id] is the coordinates record ID
  /// Returns the coordinates record or throws an exception if not found
  Future<GeospatialCoordinates> getGeospatialCoordinatesById(String id);
  
  /// Create new geospatial coordinates
  /// 
  /// [coordinates] is the coordinates record to create
  /// Returns the created coordinates record
  Future<GeospatialCoordinates> createGeospatialCoordinates(GeospatialCoordinates coordinates);
  
  /// Update existing geospatial coordinates
  /// 
  /// [id] is the ID of the coordinates record to update
  /// [coordinates] contains the updated data
  /// Returns the updated coordinates record
  Future<GeospatialCoordinates> updateGeospatialCoordinates(String id, GeospatialCoordinates coordinates);
  
  /// Delete geospatial coordinates by ID
  /// 
  /// [id] is the ID of the coordinates record to delete
  Future<void> deleteGeospatialCoordinates(String id);
  
  /// Get geospatial coordinates by location GLN
  /// 
  /// [glnCode] is the GLN code of the location
  /// Returns coordinates record associated with the GLN
  Future<GeospatialCoordinates?> getGeospatialCoordinatesByGLN(String glnCode);
  
  /// Add geospatial coordinates to a location
  /// 
  /// [glnCode] is the GLN code of the location
  /// [coordinates] is the coordinates to add
  /// Returns the updated GLN record with coordinates
  Future<GLN> addCoordinatesToLocation(String glnCode, GeospatialCoordinates coordinates);
  
  /// Search for locations by proximity
  /// 
  /// [latitude] is the latitude of the center point
  /// [longitude] is the longitude of the center point
  /// [radiusKm] is the search radius in kilometers
  /// Returns locations within the specified radius
  Future<List<GLN>> findLocationsByProximity(double latitude, double longitude, double radiusKm);
}
