import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_alert.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_controlled_chain.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_dscsa_ownership.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_duplicate_evidence.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_emvo_upload.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_repackaging_link.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_reporting_regime.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_tatmeen_submission.dart';
abstract final class _P {
  static String base(String sgtinId) => '/identifiers/sgtins/$sgtinId/pharma';

  // Regimes
  static String regimes(String id)                => '${base(id)}/regimes';
  static String regime(String id, String type)    => '${base(id)}/regimes/$type';

  // EMVO
  static String emvo(String id)                   => '${base(id)}/emvo';
  static String emvoLatest(String id)             => '${base(id)}/emvo/latest';
  static String emvoInitiate(String id)           => '${base(id)}/emvo/initiate';
  static String emvoCommission(String id)         => '${base(id)}/emvo/commission';
  static String emvoDecommission(String id)       => '${base(id)}/emvo/decommission';
  static String emvoAck(String uploadId)          => '/identifiers/sgtins/pharma/emvo/$uploadId/acknowledge';
  static String emvoFail(String uploadId)         => '/identifiers/sgtins/pharma/emvo/$uploadId/fail';
  static String emvoRetry(String uploadId)        => '/identifiers/sgtins/pharma/emvo/$uploadId/retry';

  // Tatmeen
  static String tatmeen(String id)                => '${base(id)}/tatmeen';
  static String tatmeenAccept(String subId)       => '/identifiers/sgtins/pharma/tatmeen/$subId/accept';
  static String tatmeenReject(String subId)       => '/identifiers/sgtins/pharma/tatmeen/$subId/reject';

  // DSCSA
  static String dscsa(String id)                  => '${base(id)}/dscsa';

  // Cold chain
  static String coldChain(String id)              => '${base(id)}/cold-chain';
  static String coldChainReading(String id)       => '${base(id)}/cold-chain/reading';

  // Duplicates
  static String duplicates(String id)             => '${base(id)}/duplicates';
  static String duplicateResolve(String evidId)   => '/identifiers/sgtins/pharma/duplicates/$evidId/resolve';

  // Repackaging
  static String repackaging(String id)            => '${base(id)}/repackaging';
  static const String repackagingCreate           = '/identifiers/sgtins/pharma/repackaging';

  // Alerts
  static String alerts(String id)                 => '${base(id)}/alerts';
  static String alertsOpen(String id)             => '${base(id)}/alerts/open';
  static String alertAck(String alertId)          => '/identifiers/sgtins/pharma/alerts/$alertId/acknowledge';
  static String alertResolve(String alertId)      => '/identifiers/sgtins/pharma/alerts/$alertId/resolve';

  // Dispatch
  static String dispatchCommission(String id)       => '${base(id)}/dispatch/commission';
  static String dispatchDecommission(String id)     => '${base(id)}/dispatch/decommission';
  static String dispatchOwnershipTransfer(String id) => '${base(id)}/dispatch/ownership-transfer';

  // Batches
  static String batches(String gtinId)              => '/identifiers/gtins/$gtinId/batches';
  static String batchByLot(String gtinId, String lot) => '/identifiers/gtins/$gtinId/batches/$lot';
  static String batchById(String gtinId, String batchId) => '/identifiers/gtins/$gtinId/batches/$batchId';
}

/// Pharma compliance HTTP service.
/// Covers all SGTIN pharma extension endpoints (EMVO, Tatmeen, DSCSA,
/// cold chain, duplicates, repackaging, alerts, batches).
class PharmaService {
  final DioService _dio;

  PharmaService({required DioService dioService}) : _dio = dioService;

  // ── private helpers ────────────────────────────────────────────────────────

  Future<String> _token() async {
    final t = await _dio.getAuthToken();
    if (t == null) throw ApiException(message: 'No auth token');
    return t;
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  String _url(String path) => '${_dio.baseUrl}$path';

  List<T> _decodeList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final list = json.decode(data as String) as List<dynamic>;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  T _decode<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) =>
      fromJson(json.decode(data as String) as Map<String, dynamic>);

  Future<Response> _get(String path, String token) =>
      _dio.get(_url(path), headers: _headers(token),
          responseType: ResponseType.plain, acceptAllStatusCodes: true);

  Future<Response> _post(String path, String token, [Object? body]) =>
      _dio.post(_url(path), headers: _headers(token),
          data: body != null ? json.encode(body) : null,
          responseType: ResponseType.plain, acceptAllStatusCodes: true);

  Future<Response> _patch(String path, String token, [Object? body]) =>
      _dio.patch(_url(path), headers: _headers(token),
          data: body != null ? json.encode(body) : null,
          responseType: ResponseType.plain, acceptAllStatusCodes: true);

  Future<Response> _delete(String path, String token) =>
      _dio.delete(_url(path), headers: _headers(token),
          responseType: ResponseType.plain, acceptAllStatusCodes: true);

  void _assertOk(Response r, [List<int> ok = const [200, 201]]) {
    if (!ok.contains(r.statusCode)) {
      throw ApiException(message: 'Request failed (${r.statusCode}): ${r.data}');
    }
  }

  // ── Reporting Regimes ──────────────────────────────────────────────────────

  Future<List<SGTINReportingRegime>> getRegimes(String sgtinId) async {
    final t = await _token();
    final r = await _get(_P.regimes(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINReportingRegime.fromJson);
  }

  Future<SGTINReportingRegime> enrolRegime(String sgtinId, SGTINReportingRegime regime) async {
    final t = await _token();
    final r = await _post(_P.regimes(sgtinId), t, regime.toJson());
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINReportingRegime.fromJson);
  }

  Future<SGTINReportingRegime> unenrolRegime(String sgtinId, String regimeType) async {
    final t = await _token();
    final r = await _delete(_P.regime(sgtinId, regimeType), t);
    _assertOk(r);
    return _decode(r.data, SGTINReportingRegime.fromJson);
  }

  // ── EMVO ──────────────────────────────────────────────────────────────────

  Future<List<SGTINEmvoUpload>> getEmvoUploads(String sgtinId) async {
    final t = await _token();
    final r = await _get(_P.emvo(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> getLatestEmvoUpload(String sgtinId) async {
    final t = await _token();
    final r = await _get(_P.emvoLatest(sgtinId), t);
    _assertOk(r);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> initiateEmvoUpload(String sgtinId) async {
    final t = await _token();
    final r = await _post(_P.emvoInitiate(sgtinId), t);
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> submitEmvoCommissioning(String sgtinId) async {
    final t = await _token();
    final r = await _post(_P.emvoCommission(sgtinId), t);
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> submitEmvoDecommissioning(String sgtinId, {String? reason}) async {
    final t = await _token();
    final path = reason != null
        ? '${_P.emvoDecommission(sgtinId)}?reason=${Uri.encodeComponent(reason)}'
        : _P.emvoDecommission(sgtinId);
    final r = await _post(path, t);
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> acknowledgeEmvoUpload(String uploadId, String emvoReferenceId) async {
    final t = await _token();
    final r = await _patch(
        '${_P.emvoAck(uploadId)}?emvoReferenceId=${Uri.encodeComponent(emvoReferenceId)}', t);
    _assertOk(r);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> recordEmvoFailure(String uploadId, String errorMessage) async {
    final t = await _token();
    final r = await _patch(
        '${_P.emvoFail(uploadId)}?errorMessage=${Uri.encodeComponent(errorMessage)}', t);
    _assertOk(r);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> scheduleEmvoRetry(String uploadId) async {
    final t = await _token();
    final r = await _post(_P.emvoRetry(uploadId), t);
    _assertOk(r);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  // ── Tatmeen ────────────────────────────────────────────────────────────────

  Future<List<SGTINTatmeenSubmission>> getTatmeenSubmissions(String sgtinId) async {
    final t = await _token();
    final r = await _get(_P.tatmeen(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINTatmeenSubmission.fromJson);
  }

  Future<SGTINTatmeenSubmission> submitToTatmeen(String sgtinId, String submissionType) async {
    final t = await _token();
    final r = await _post(
        '${_P.tatmeen(sgtinId)}?submissionType=${Uri.encodeComponent(submissionType)}', t);
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINTatmeenSubmission.fromJson);
  }

  Future<SGTINTatmeenSubmission> acknowledgeTatmeen(String submissionId, String tatmeenRef) async {
    final t = await _token();
    final r = await _patch(
        '${_P.tatmeenAccept(submissionId)}?tatmeenRef=${Uri.encodeComponent(tatmeenRef)}', t);
    _assertOk(r);
    return _decode(r.data, SGTINTatmeenSubmission.fromJson);
  }

  Future<SGTINTatmeenSubmission> rejectTatmeen(String submissionId, String reason) async {
    final t = await _token();
    final r = await _patch(
        '${_P.tatmeenReject(submissionId)}?reason=${Uri.encodeComponent(reason)}', t);
    _assertOk(r);
    return _decode(r.data, SGTINTatmeenSubmission.fromJson);
  }

  // ── DSCSA ─────────────────────────────────────────────────────────────────

  Future<List<SGTINDscsaOwnership>> getDscsaChain(String sgtinId) async {
    final t = await _token();
    final r = await _get(_P.dscsa(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINDscsaOwnership.fromJson);
  }

  Future<SGTINDscsaOwnership> recordOwnershipTransfer(
      String sgtinId, SGTINDscsaOwnership dto) async {
    final t = await _token();
    final r = await _post(_P.dscsa(sgtinId), t, dto.toJson());
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINDscsaOwnership.fromJson);
  }

  // ── Cold Chain ────────────────────────────────────────────────────────────

  Future<List<SGTINControlledChain>> getColdChain(String sgtinId) async {
    final t = await _token();
    final r = await _get(_P.coldChain(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINControlledChain.fromJson);
  }

  Future<SGTINControlledChain> recordSensorReading(
      String sgtinId, double tempMin, double tempMax,
      {String? sensorEventId, String chainType = 'COLD'}) async {
    final t = await _token();
    var path = '${_P.coldChainReading(sgtinId)}'
        '?tempMin=$tempMin&tempMax=$tempMax&chainType=${Uri.encodeComponent(chainType)}';
    if (sensorEventId != null) path += '&sensorEventId=${Uri.encodeComponent(sensorEventId)}';
    final r = await _post(path, t);
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINControlledChain.fromJson);
  }

  // ── Duplicate Evidence ────────────────────────────────────────────────────

  Future<List<SGTINDuplicateEvidence>> getDuplicateEvidence(String sgtinId) async {
    final t = await _token();
    final r = await _get(_P.duplicates(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINDuplicateEvidence.fromJson);
  }

  Future<SGTINDuplicateEvidence> recordDuplicateDetection(
      String sgtinId, SGTINDuplicateEvidence dto) async {
    final t = await _token();
    final r = await _post(_P.duplicates(sgtinId), t, dto.toJson());
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINDuplicateEvidence.fromJson);
  }

  Future<SGTINDuplicateEvidence> resolveDuplicateEvidence(
      String evidenceId, {String? notes}) async {
    final t = await _token();
    final path = notes != null
        ? '${_P.duplicateResolve(evidenceId)}?notes=${Uri.encodeComponent(notes)}'
        : _P.duplicateResolve(evidenceId);
    final r = await _patch(path, t);
    _assertOk(r);
    return _decode(r.data, SGTINDuplicateEvidence.fromJson);
  }

  // ── Repackaging ───────────────────────────────────────────────────────────

  Future<List<SGTINRepackagingLink>> getRepackagingLinks(String sgtinId) async {
    final t = await _token();
    final r = await _get(_P.repackaging(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINRepackagingLink.fromJson);
  }

  Future<SGTINRepackagingLink> createRepackagingLink(SGTINRepackagingLink dto) async {
    final t = await _token();
    final r = await _post(_P.repackagingCreate, t, dto.toJson());
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINRepackagingLink.fromJson);
  }

  // ── Alerts ────────────────────────────────────────────────────────────────

  Future<List<SGTINAlert>> getAlerts(String sgtinId) async {
    final t = await _token();
    final r = await _get(_P.alerts(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINAlert.fromJson);
  }

  Future<List<SGTINAlert>> getOpenAlerts(String sgtinId) async {
    final t = await _token();
    final r = await _get(_P.alertsOpen(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINAlert.fromJson);
  }

  Future<SGTINAlert> raiseAlert(String sgtinId,
      {required String alertType,
      String severity = 'MEDIUM',
      required String message,
      String? regimeContext}) async {
    final t = await _token();
    final r = await _post(_P.alerts(sgtinId), t, {
      'alertType': alertType,
      'severity': severity,
      'message': message,
      if (regimeContext != null) 'regimeContext': regimeContext,
    });
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINAlert.fromJson);
  }

  Future<SGTINAlert> acknowledgeAlert(String alertId, {String? acknowledgedBy}) async {
    final t = await _token();
    final path = acknowledgedBy != null
        ? '${_P.alertAck(alertId)}?acknowledgedBy=${Uri.encodeComponent(acknowledgedBy)}'
        : _P.alertAck(alertId);
    final r = await _patch(path, t);
    _assertOk(r);
    return _decode(r.data, SGTINAlert.fromJson);
  }

  Future<SGTINAlert> resolveAlert(String alertId,
      {String? resolvedBy, String? notes}) async {
    final t = await _token();
    var path = _P.alertResolve(alertId);
    final params = <String>[];
    if (resolvedBy != null) params.add('resolvedBy=${Uri.encodeComponent(resolvedBy)}');
    if (notes != null) params.add('notes=${Uri.encodeComponent(notes)}');
    if (params.isNotEmpty) path += '?${params.join('&')}';
    final r = await _patch(path, t);
    _assertOk(r);
    return _decode(r.data, SGTINAlert.fromJson);
  }

  // ── Dispatch ──────────────────────────────────────────────────────────────

  Future<void> dispatchCommissioning(String sgtinId) async {
    final t = await _token();
    final r = await _post(_P.dispatchCommission(sgtinId), t);
    _assertOk(r);
  }

  Future<void> dispatchDecommissioning(String sgtinId, {String? reason}) async {
    final t = await _token();
    final path = reason != null
        ? '${_P.dispatchDecommission(sgtinId)}?reason=${Uri.encodeComponent(reason)}'
        : _P.dispatchDecommission(sgtinId);
    final r = await _post(path, t);
    _assertOk(r);
  }

  Future<void> dispatchOwnershipTransfer(
      String sgtinId, String fromGln, String toGln) async {
    final t = await _token();
    final r = await _post(
        '${_P.dispatchOwnershipTransfer(sgtinId)}'
        '?fromGln=${Uri.encodeComponent(fromGln)}&toGln=${Uri.encodeComponent(toGln)}',
        t);
    _assertOk(r);
  }

  // ── GTIN Batches ──────────────────────────────────────────────────────────

  Future<List<GtinBatch>> getBatches(String gtinId) async {
    final t = await _token();
    final r = await _get(_P.batches(gtinId), t);
    _assertOk(r);
    return _decodeList(r.data, GtinBatch.fromJson);
  }

  Future<GtinBatch> getBatchByLot(String gtinId, String batchLot) async {
    final t = await _token();
    final r = await _get(_P.batchByLot(gtinId, batchLot), t);
    _assertOk(r);
    return _decode(r.data, GtinBatch.fromJson);
  }

  Future<GtinBatch> createBatch(String gtinId, GtinBatch batch) async {
    final t = await _token();
    final r = await _post(_P.batches(gtinId), t, batch.toJson());
    _assertOk(r, [200, 201]);
    return _decode(r.data, GtinBatch.fromJson);
  }

  Future<GtinBatch> updateBatch(String gtinId, String batchId, GtinBatch batch) async {
    final t = await _token();
    final r = await _patch(_P.batchById(gtinId, batchId), t, batch.toJson());
    _assertOk(r);
    return _decode(r.data, GtinBatch.fromJson);
  }
}
