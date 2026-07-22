import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
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

  Future<Map<String, dynamic>> _postAdminJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    final response = await _dioService.post(
      '$_baseUrl$path',
      data: body,
      queryParameters: queryParameters,
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
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
    final head = errors.take(5).map(_shortError).join('; ');
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

  static String _shortError(String raw) {
    
    final oneLine = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (oneLine.length <= 160) return oneLine;
    return '${oneLine.substring(0, 160)}…';
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

  void _assertSupplyChainSeed(
    Map<String, dynamic> body,
    String label, {
    bool allowPartialSuccess = false,
  }) {
    final errors = _stringList(body['errors']);
    if (errors.isEmpty) return;
    if (allowPartialSuccess) {
      final shipping = (body['shippingOperationsCreated'] as num?)?.toInt() ?? 0;
      final packing = (body['packingOperationsCreated'] as num?)?.toInt() ?? 0;
      final commissioning =
          (body['commissioningBatchesCreated'] as num?)?.toInt() ?? 0;
      if (shipping > 0 || packing > 0 || commissioning > 0) {
        
        return;
      }
    }
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
    
    
    onProgress(1, 1, 'Delegating to connected supply-chain orchestrator…');
    await generatePharmaFullConnectedSupplyChain(
      onProgress: (current, total, status) => onProgress(current, total, status),
    );
  }

  
  
  Future<Map<String, dynamic>> generatePharmaFullConnectedSupplyChain({
    required Function(int current, int total, String status) onProgress,
  }) async {
    onProgress(1, 3, 'Seeding GLNs, GTINs, SGTINs, SSCCs…');
    onProgress(2, 3, 'Running commissioning, packing, shipping, receiving…');
    // No client timeout — full supply-chain seed can run for many minutes.
    // Dio: Duration.zero disables the limit (null would fall back to BaseOptions).
    final body = await _postAdminJson(
      '/admin/industry-demo-data/pharma/supply-chain/full',
      queryParameters: const {'reset': 'true'},
      connectTimeout: Duration.zero,
      receiveTimeout: Duration.zero,
      sendTimeout: Duration.zero,
    );
    _assertSupplyChainSeed(
      body,
      'Pharma full connected supply chain',
      allowPartialSuccess: true,
    );
    final shipping = (body['shippingOperationsCreated'] as num?)?.toInt() ?? 0;
    final inTransit = (body['inTransitShipmentsOpen'] as num?)?.toInt() ?? 0;
    final errCount = _stringList(body['errors']).length;
    onProgress(
      3,
      3,
      errCount == 0
          ? 'Done — $shipping shipments, $inTransit open in-transit'
          : 'Done — $shipping shipments, $inTransit open in-transit '
              '($errCount non-fatal warning(s); see server logs)',
    );
    return body;
  }

  
  
  Future<Map<String, dynamic>> generatePackedHierarchy({
    int levels = 10,
    int childrenPerLevel = 100,
    String? gtinCode,
    String? rootGln,
    required Function(int current, int total, String status) onProgress,
  }) async {
    onProgress(1, 2, 'Commissioning + packing nested hierarchy…');
    final body = <String, dynamic>{
      'levels': levels,
      'childrenPerLevel': childrenPerLevel,
      if (gtinCode != null && gtinCode.trim().isNotEmpty) 'gtinCode': gtinCode.trim(),
      if (rootGln != null && rootGln.trim().isNotEmpty) 'rootGln': rootGln.trim(),
    };
    final response = await _postAdminJson(
      '/test-data/hierarchy',
      body: body,
      connectTimeout: Duration(
        milliseconds: AppConfig.longRunningConnectTimeout,
      ),
      receiveTimeout: Duration(
        milliseconds: AppConfig.longRunningReceiveTimeout,
      ),
      sendTimeout: Duration(milliseconds: AppConfig.longRunningSendTimeout),
    );
    final rootEpc = response['rootEpc']?.toString() ?? '';
    final rootSscc = response['rootSsccCode']?.toString() ?? '';
    final depth = (response['depth'] as num?)?.toInt() ?? levels;
    final sgtin = (response['totalSgtin'] as num?)?.toInt() ?? 0;
    final sscc = (response['totalSscc'] as num?)?.toInt() ?? 0;
    final ms = (response['processingTimeMs'] as num?)?.toInt() ?? 0;
    if (rootEpc.isEmpty) {
      throw Exception('Hierarchy seed returned no rootEpc');
    }
    final rootLabel = rootSscc.isNotEmpty ? rootSscc : rootEpc;
    onProgress(
      2,
      2,
      'Done — root $rootLabel (depth $depth, $sscc SSCC / $sgtin SGTIN, ${ms}ms)',
    );
    return response;
  }

  
  Future<Map<String, dynamic>> cleanupPackedHierarchy({
    required String runId,
  }) async {
    final trimmed = runId.trim();
    if (trimmed.isEmpty) {
      throw Exception('runId is required for hierarchy cleanup');
    }
    return _deleteAdminJson(
      '/test-data/hierarchy',
      queryParameters: {'runId': trimmed},
    );
  }

  Future<Map<String, dynamic>> _deleteAdminJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dioService.delete(
      '$_baseUrl$path',
      queryParameters: queryParameters,
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    final code = response.statusCode ?? 0;
    final bodyStr = _stringifyBody(response.data);
    if (code != 200 && code != 204) {
      throw Exception(
        'Request failed: HTTP $code — ${_truncate(bodyStr, 1500)}',
      );
    }
    if (bodyStr.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(bodyStr);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {};
    } catch (_) {
      return {};
    }
  }
}
