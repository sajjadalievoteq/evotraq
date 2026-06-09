import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

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

  static String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…(truncated)';
  }

  static String _stringifyBody(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  Future<Map<String, dynamic>> _postAdminJson(String path) async {
    final response = await _dioService.post(
      '$_baseUrl$path',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    final code = response.statusCode ?? 0;
    final bodyStr = _stringifyBody(response.data);
    if (code != 200 && code != 201) {
      throw Exception(
        'Request failed: HTTP $code — ${_truncate(bodyStr, 1500)}',
      );
    }
    if (bodyStr.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(bodyStr);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return {};
    } catch (_) {
      throw Exception(
        'Seeding succeeded (HTTP $code) but response was not JSON: '
        '${_truncate(bodyStr, 800)}',
      );
    }
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }

  static void _throwIfErrors(
    List<String> errors, {
    required String label,
    int? created,
    int? skipped,
  }) {
    if (errors.isEmpty) return;
    final head = errors.take(10).join('; ');
    final counts = (created != null || skipped != null)
        ? ' created=${created ?? '?'} skippedDuplicates=${skipped ?? '?'}'
        : '';
    final partial =
        (created != null && created > 0) ? ' Partial rows were written.' : '';
    throw Exception(
      '$label: server reported ${errors.length} error(s).$counts$partial '
      'First messages: $head',
    );
  }

  void _assertGtinSeed(Map<String, dynamic> body, String label) {
    final errors = _stringList(body['errors']);
    final created = (body['gtinCreated'] as num?)?.toInt() ?? 0;
    final skipped = (body['gtinSkippedDuplicate'] as num?)?.toInt() ?? 0;
    _throwIfErrors(errors, label: label, created: created, skipped: skipped);
    if (created == 0 && skipped == 0) {
      throw Exception(
        '$label: no GTINs created and none skipped as duplicates — '
        'check backend logs and demo JSON on the server.',
      );
    }
  }

  void _assertGlnSeed(Map<String, dynamic> body, String label) {
    final errors = _stringList(body['errors']);
    final created = (body['glnCreated'] as num?)?.toInt() ?? 0;
    final skipped = (body['glnSkippedDuplicate'] as num?)?.toInt() ?? 0;
    _throwIfErrors(errors, label: label, created: created, skipped: skipped);
    if (created == 0 && skipped == 0) {
      throw Exception(
        '$label: no GLNs created and none skipped — '
        'check backend logs and demo JSON on the server.',
      );
    }
  }

  void _assertSupplyChainSeed(Map<String, dynamic> body, String label) {
    final errors = _stringList(body['errors']);
    _throwIfErrors(errors, label: label);
  }

  Future<void> generateTobaccoGTINs({
    required Function(int current, int total, String productName) onProgress,
  }) async {
    onProgress(1, 1, 'UAE tobacco GTINs — seeding on server…');
    final body = await _postAdminJson('/admin/industry-demo-data/tobacco/gtins');
    _assertGtinSeed(body, 'Tobacco GTIN seed');
    onProgress(1, 1, 'UAE tobacco GTINs — done');
  }

  Future<void> generateTobaccoGLNs({
    required Function(int current, int total, String locationName) onProgress,
  }) async {
    onProgress(1, 1, 'UAE tobacco — seeding on server…');
    final body = await _postAdminJson('/admin/industry-demo-data/tobacco/glns');
    _assertGlnSeed(body, 'Tobacco GLN seed');
    onProgress(1, 1, 'UAE tobacco — done');
  }

  Future<void> generateTobaccoSGTINs({
    required Function(int current, int total, String productInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE tobacco SGTINs — seeding on server…');
    final body = await _postAdminJson('/admin/industry-demo-data/tobacco/sgtins');
    _assertSupplyChainSeed(body, 'Tobacco SGTIN seed');
    onProgress(1, 1, 'UAE tobacco SGTINs — done');
  }

  Future<void> generateTobaccoSSCCs({
    required Function(int current, int total, String containerInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE tobacco SSCCs — seeding on server…');
    final body = await _postAdminJson('/admin/industry-demo-data/tobacco/ssccs');
    _assertSupplyChainSeed(body, 'Tobacco SSCC seed');
    onProgress(1, 1, 'UAE tobacco SSCCs — done');
  }

  Future<void> generateTobaccoEvents({
    required Function(int current, int total, String eventInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE tobacco EPCIS events — seeding on server…');
    final body = await _postAdminJson('/admin/industry-demo-data/tobacco/events');
    _assertSupplyChainSeed(body, 'Tobacco EPCIS events seed');
    onProgress(1, 1, 'UAE tobacco EPCIS events — done');
  }

  Future<void> generatePharmaGTINs({
    required Function(int current, int total, String productName) onProgress,
  }) async {
    onProgress(1, 1, 'UAE pharma GTINs — seeding on server…');
    final body = await _postAdminJson('/admin/industry-demo-data/pharma/gtins');
    _assertGtinSeed(body, 'Pharma GTIN seed');
    onProgress(1, 1, 'UAE pharma GTINs — done');
  }

  Future<void> generatePharmaGLNs({
    required Function(int current, int total, String locationName) onProgress,
  }) async {
    onProgress(1, 1, 'UAE pharma — seeding on server…');
    final body = await _postAdminJson('/admin/industry-demo-data/pharma/glns');
    _assertGlnSeed(body, 'Pharma GLN seed');
    onProgress(1, 1, 'UAE pharma — done');
  }

  Future<void> generatePharmaSGTINs({
    required Function(int current, int total, String productInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE pharma SGTINs — seeding on server…');
    final body = await _postAdminJson('/admin/industry-demo-data/pharma/sgtins');
    _assertSupplyChainSeed(body, 'Pharma SGTIN seed');
    onProgress(1, 1, 'UAE pharma SGTINs — done');
  }

  Future<void> generatePharmaSSCCs({
    required Function(int current, int total, String containerInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE pharma SSCCs — seeding on server…');
    final body = await _postAdminJson('/admin/industry-demo-data/pharma/ssccs');
    _assertSupplyChainSeed(body, 'Pharma SSCC seed');
    onProgress(1, 1, 'UAE pharma SSCCs — done');
  }

  Future<void> generatePharmaEvents({
    required Function(int current, int total, String eventInfo) onProgress,
  }) async {
    onProgress(1, 1, 'UAE pharma EPCIS events — seeding on server…');
    final body = await _postAdminJson('/admin/industry-demo-data/pharma/events');
    _assertSupplyChainSeed(body, 'Pharma EPCIS events seed');
    onProgress(1, 1, 'UAE pharma EPCIS events — done');
  }
}
