import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/sensor_element.dart';

/// Implementation of the SensorElementService interface
class SensorElementService {
  final DioService _dioService;

  /// Base endpoint for sensor element API
  late final String _baseUrl;
  
  /// Constructor
  SensorElementService({
    required DioService dioService,
  }) : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/sensor-elements';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<SensorElement>> getAllSensorElements() async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      _baseUrl,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> sensorElementList = json.decode(response.data);
      return sensorElementList.map((json) => SensorElement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get sensor elements: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> getAllSensorElementsPaginated(int page, int size) async {
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

      responseData['content'] = content.map((json) =>
        SensorElement.fromJson(json)).toList();

      return responseData;
    } else {
      throw Exception('Failed to get paginated sensor elements: ${response.statusCode}');
    }
  }
  
  Future<SensorElement> getSensorElementById(String id) async {
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
      return SensorElement.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to get sensor element: ${response.statusCode}');
    }
  }
  
  Future<SensorElement> createSensorElement(SensorElement sensorElement) async {
    final headers = await _getHeaders();
    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: json.encode(sensorElement.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return SensorElement.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to create sensor element: ${response.statusCode}');
    }
  }
  
  Future<SensorElement> updateSensorElement(String id, SensorElement sensorElement) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId = id;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    }

    final response = await _dioService.put(
      '$_baseUrl/$cleanId',
      headers: headers,
      data: json.encode(sensorElement.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SensorElement.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to update sensor element: ${response.statusCode}');
    }
  }
  
  Future<void> deleteSensorElement(String id) async {
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
      throw Exception('Failed to delete sensor element: ${response.statusCode}');
    }
  }
  
  Future<List<SensorElement>> getSensorElementsByEventId(String eventId) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId = eventId;
    if (eventId.contains(':')) {
      cleanId = eventId.split(':').last;
    }

    final response = await _dioService.get(
      '$_baseUrl/event/$cleanId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> sensorElementList = json.decode(response.data);
      return sensorElementList.map((json) => SensorElement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get sensor elements by event: ${response.statusCode}');
    }
  }
  
  Future<List<SensorElement>> getSensorElementsByDeviceId(String deviceId) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/device/$deviceId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> sensorElementList = json.decode(response.data);
      return sensorElementList.map((json) => SensorElement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get sensor elements by device: ${response.statusCode}');
    }
  }
  
  Future<List<SensorElement>> getSensorElementsByMeasurementType(String type) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/measurement-type/$type',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> sensorElementList = json.decode(response.data);
      return sensorElementList.map((json) => SensorElement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get sensor elements by measurement type: ${response.statusCode}');
    }
  }
}
