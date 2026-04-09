import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/sensor_element.dart';
import 'package:traqtrace_app/features/epcis/services/sensor_element_service.dart';

/// Implementation of the SensorElementService interface
class SensorElementServiceImpl implements SensorElementService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  
  /// Base endpoint for sensor element API
  late final String _baseUrl;
  
  /// Constructor
  SensorElementServiceImpl({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _httpClient = httpClient,
       _tokenManager = tokenManager,
       _appConfig = appConfig {
    _baseUrl = '${_appConfig.apiBaseUrl}/sensor-elements';
  }
  
  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<SensorElement>> getAllSensorElements() async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse(_baseUrl),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> sensorElementList = json.decode(response.body);
      return sensorElementList.map((json) => SensorElement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get sensor elements: ${response.statusCode}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getAllSensorElementsPaginated(int page, int size) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl?page=$page&size=$size'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> content = responseData['content'];
      
      responseData['content'] = content.map((json) => 
        SensorElement.fromJson(json)).toList();
        
      return responseData;
    } else {
      throw Exception('Failed to get paginated sensor elements: ${response.statusCode}');
    }
  }
  
  @override
  Future<SensorElement> getSensorElementById(String id) async {
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
      return SensorElement.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get sensor element: ${response.statusCode}');
    }
  }
  
  @override
  Future<SensorElement> createSensorElement(SensorElement sensorElement) async {
    final headers = await _getHeaders();
    final response = await _httpClient.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: json.encode(sensorElement.toJson()),
    );
    
    if (response.statusCode == 201) {
      return SensorElement.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create sensor element: ${response.statusCode}');
    }
  }
  
  @override
  Future<SensorElement> updateSensorElement(String id, SensorElement sensorElement) async {
    final headers = await _getHeaders();
    
    // Extract UUID if the ID is in URN format
    String cleanId = id;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    }
    
    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/$cleanId'),
      headers: headers,
      body: json.encode(sensorElement.toJson()),
    );
    
    if (response.statusCode == 200) {
      return SensorElement.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update sensor element: ${response.statusCode}');
    }
  }
  
  @override
  Future<void> deleteSensorElement(String id) async {
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
      throw Exception('Failed to delete sensor element: ${response.statusCode}');
    }
  }
  
  @override
  Future<List<SensorElement>> getSensorElementsByEventId(String eventId) async {
    final headers = await _getHeaders();
    
    // Extract UUID if the ID is in URN format
    String cleanId = eventId;
    if (eventId.contains(':')) {
      cleanId = eventId.split(':').last;
    }
    
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/event/$cleanId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> sensorElementList = json.decode(response.body);
      return sensorElementList.map((json) => SensorElement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get sensor elements by event: ${response.statusCode}');
    }
  }
  
  @override
  Future<List<SensorElement>> getSensorElementsByDeviceId(String deviceId) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/device/$deviceId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> sensorElementList = json.decode(response.body);
      return sensorElementList.map((json) => SensorElement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get sensor elements by device: ${response.statusCode}');
    }
  }
  
  @override
  Future<List<SensorElement>> getSensorElementsByMeasurementType(String type) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/measurement-type/$type'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> sensorElementList = json.decode(response.body);
      return sensorElementList.map((json) => SensorElement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get sensor elements by measurement type: ${response.statusCode}');
    }
  }
}
