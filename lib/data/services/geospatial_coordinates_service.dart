import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/geospatial_coordinates.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';

/// Implementation of the GeospatialCoordinatesService interface
class GeospatialCoordinatesService {
  final DioService _dioService;

  /// Base endpoint for geospatial coordinates API
  late final String _baseUrl;

  /// Base endpoint for GLN API
  late final String _glnBaseUrl;

  /// Constructor
  GeospatialCoordinatesService({required DioService dioService})
    : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/geospatial';
    _glnBaseUrl = '${_dioService.baseUrl}/identifiers/gln';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<GeospatialCoordinates>> getAllGeospatialCoordinates() async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      _baseUrl,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> coordinatesList = json.decode(response.data);
      return coordinatesList
          .map((json) => GeospatialCoordinates.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to get geospatial coordinates: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> getAllGeospatialCoordinatesPaginated(
    int page,
    int size,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      _baseUrl,
      queryParameters: {'page': page.toString(), 'size': size.toString()},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);
      final List<dynamic> content = responseData['content'];

      responseData['content'] = content
          .map((json) => GeospatialCoordinates.fromJson(json))
          .toList();

      return responseData;
    } else {
      throw Exception(
        'Failed to get paginated geospatial coordinates: ${response.statusCode}',
      );
    }
  }

  Future<GeospatialCoordinates> getGeospatialCoordinatesById(String id) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId = id;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    }

    final response = await _dioService.get(
      '$_baseUrl/$cleanId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GeospatialCoordinates.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to get geospatial coordinates: ${response.statusCode}',
      );
    }
  }

  Future<GeospatialCoordinates> createGeospatialCoordinates(
    GeospatialCoordinates coordinates,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: json.encode(coordinates.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return GeospatialCoordinates.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to create geospatial coordinates: ${response.statusCode}',
      );
    }
  }

  Future<GeospatialCoordinates> updateGeospatialCoordinates(
    String id,
    GeospatialCoordinates coordinates,
  ) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId = id;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    }

    final response = await _dioService.put(
      '$_baseUrl/$cleanId',
      headers: headers,
      data: json.encode(coordinates.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GeospatialCoordinates.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to update geospatial coordinates: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteGeospatialCoordinates(String id) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId = id;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    }

    final response = await _dioService.delete(
      '$_baseUrl/$cleanId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to delete geospatial coordinates: ${response.statusCode}',
      );
    }
  }

  Future<GeospatialCoordinates?> getGeospatialCoordinatesByGLN(
    String glnCode,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/gln/$glnCode',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.data);
      if (data != null) {
        return GeospatialCoordinates.fromJson(data);
      }
      return null;
    } else if (response.statusCode == 404) {
      // No coordinates found for this GLN
      return null;
    } else {
      throw Exception(
        'Failed to get coordinates by GLN: ${response.statusCode}',
      );
    }
  }

  Future<GLN> addCoordinatesToLocation(
    String glnCode,
    GeospatialCoordinates coordinates,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.post(
      '$_glnBaseUrl/$glnCode/coordinates',
      headers: headers,
      data: json.encode(coordinates.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLN.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to add coordinates to location: ${response.statusCode}',
      );
    }
  }

  Future<List<GLN>> findLocationsByProximity(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/locations/nearby',
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'radius': radiusKm.toString(),
      },
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> locationsList = json.decode(response.data);
      return locationsList.map((json) => GLN.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find nearby locations: ${response.statusCode}',
      );
    }
  }
}
