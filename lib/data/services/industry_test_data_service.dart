import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

/// Service for generating industry-specific test data (server-side seeding; client calls admin APIs only).
class IndustryTestDataService {
  final DioService _dioService;

  IndustryTestDataService({required DioService dioService})
    : _dioService = dioService;

  String get _baseUrl => _dioService.baseUrl;

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _postAdmin(String path) async {
    final response = await _dioService.post(
      '$_baseUrl$path',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Request failed: HTTP ${response.statusCode}');
    }
  }

  /// Generate tobacco GTINs with extensions (payloads built on the server).
  Future<void> generateTobaccoGTINs({
    required Function(int current, int total, String productName) onProgress,
  }) async {
    onProgress(1, 1, 'UAE tobacco GTINs — seeding on server…');
    await _postAdmin('/admin/industry-demo-data/tobacco/gtins');
    onProgress(1, 1, 'UAE tobacco GTINs — done');
  }

  /// Generate tobacco GLNs with extensions (payloads built on the server).
  Future<void> generateTobaccoGLNs({
    required Function(int current, int total, String locationName) onProgress,
  }) async {
    onProgress(1, 1, 'UAE tobacco — seeding on server…');
    await _postAdmin('/admin/industry-demo-data/tobacco/glns');
    onProgress(1, 1, 'UAE tobacco — done');
  }

  /// Generate tobacco SGTINs (serialized items) from existing GTINs (server-side).
  Future<void> generateTobaccoSGTINs({
    required Function(int current, int total, String productInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE tobacco SGTINs — seeding on server…');
    await _postAdmin('/admin/industry-demo-data/tobacco/sgtins');
    onProgress(1, 1, 'UAE tobacco SGTINs — done');
  }

  /// Generate tobacco SSCCs with tobacco extensions (server-side).
  Future<void> generateTobaccoSSCCs({
    required Function(int current, int total, String containerInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE tobacco SSCCs — seeding on server…');
    await _postAdmin('/admin/industry-demo-data/tobacco/ssccs');
    onProgress(1, 1, 'UAE tobacco SSCCs — done');
  }

  /// Generate EPCIS events for the tobacco supply chain (server-side).
  Future<void> generateTobaccoEvents({
    required Function(int current, int total, String eventInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE tobacco EPCIS events — seeding on server…');
    await _postAdmin('/admin/industry-demo-data/tobacco/events');
    onProgress(1, 1, 'UAE tobacco EPCIS events — done');
  }

  /// Generate pharmaceutical GTINs with extensions (payloads built on the server).
  Future<void> generatePharmaGTINs({
    required Function(int current, int total, String productName) onProgress,
  }) async {
    onProgress(1, 1, 'UAE pharma GTINs — seeding on server…');
    await _postAdmin('/admin/industry-demo-data/pharma/gtins');
    onProgress(1, 1, 'UAE pharma GTINs — done');
  }

  /// Generate pharmaceutical GLNs with extensions (payloads built on the server).
  Future<void> generatePharmaGLNs({
    required Function(int current, int total, String locationName) onProgress,
  }) async {
    onProgress(1, 1, 'UAE pharma — seeding on server…');
    await _postAdmin('/admin/industry-demo-data/pharma/glns');
    onProgress(1, 1, 'UAE pharma — done');
  }

  /// Generate pharmaceutical SGTINs (server-side).
  Future<void> generatePharmaSGTINs({
    required Function(int current, int total, String productInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE pharma SGTINs — seeding on server…');
    await _postAdmin('/admin/industry-demo-data/pharma/sgtins');
    onProgress(1, 1, 'UAE pharma SGTINs — done');
  }

  /// Generate pharmaceutical SSCCs with extensions (server-side).
  Future<void> generatePharmaSSCCs({
    required Function(int current, int total, String containerInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE pharma SSCCs — seeding on server…');
    await _postAdmin('/admin/industry-demo-data/pharma/ssccs');
    onProgress(1, 1, 'UAE pharma SSCCs — done');
  }

  /// Generate EPCIS events for the pharmaceutical supply chain (server-side).
  Future<void> generatePharmaEvents({
    required Function(int current, int total, String eventInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE pharma EPCIS events — seeding on server…');
    await _postAdmin('/admin/industry-demo-data/pharma/events');
    onProgress(1, 1, 'UAE pharma EPCIS events — done');
  }
}
