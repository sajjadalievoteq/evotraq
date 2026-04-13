import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/geospatial_coordinates.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';

/// Implementation of the GeospatialCoordinatesService interface
class GeospatialCoordinatesService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  /// Base endpoint for geospatial coordinates API
  late final String _baseUrl;

  /// Base endpoint for GLN API
  late final String _glnBaseUrl;

  /// Constructor
  GeospatialCoordinatesService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _httpClient = httpClient,
       _tokenManager = tokenManager,
       _appConfig = appConfig {
    _baseUrl = '${_appConfig.apiBaseUrl}/geospatial';
    _glnBaseUrl = '${_appConfig.apiBaseUrl}/identifiers/gln';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<GeospatialCoordinates>> getAllGeospatialCoordinates() async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse(_baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> coordinatesList = json.decode(response.body);
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
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
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

    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$cleanId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return GeospatialCoordinates.fromJson(json.decode(response.body));
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
    final response = await _httpClient.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: json.encode(coordinates.toJson()),
    );

    if (response.statusCode == 201) {
      return GeospatialCoordinates.fromJson(json.decode(response.body));
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

    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/$cleanId'),
      headers: headers,
      body: json.encode(coordinates.toJson()),
    );

    if (response.statusCode == 200) {
      return GeospatialCoordinates.fromJson(json.decode(response.body));
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

    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/$cleanId'),
      headers: headers,
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
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/gln/$glnCode'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
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
    final response = await _httpClient.post(
      Uri.parse('$_glnBaseUrl/$glnCode/coordinates'),
      headers: headers,
      body: json.encode(coordinates.toJson()),
    );

    if (response.statusCode == 200) {
      return GLN.fromJson(json.decode(response.body));
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
    final response = await _httpClient.get(
      Uri.parse(
        '$_baseUrl/locations/nearby?lat=$latitude&lon=$longitude&radius=$radiusKm',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> locationsList = json.decode(response.body);
      return locationsList.map((json) => GLN.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find nearby locations: ${response.statusCode}',
      );
    }
  }
}
