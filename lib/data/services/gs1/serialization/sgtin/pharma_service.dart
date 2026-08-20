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
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/pharma_paths.dart';

class PharmaService {
  final DioService _dio;

  PharmaService({required DioService dioService}) : _dio = dioService;

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

  List<T> _decodeList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = json.decode(data as String) as List<dynamic>;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  T _decode<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) =>
      fromJson(json.decode(data as String) as Map<String, dynamic>);

  Future<Response> _get(String path, String token) => _dio.get(
    _url(path),
    headers: _headers(token),
    responseType: ResponseType.plain,
    acceptAllStatusCodes: true,
  );

  Future<Response> _post(String path, String token, [Object? body]) =>
      _dio.post(
        _url(path),
        headers: _headers(token),
        data: body != null ? json.encode(body) : null,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

  Future<Response> _patch(String path, String token, [Object? body]) =>
      _dio.patch(
        _url(path),
        headers: _headers(token),
        data: body != null ? json.encode(body) : null,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

  Future<Response> _delete(String path, String token) => _dio.delete(
    _url(path),
    headers: _headers(token),
    responseType: ResponseType.plain,
    acceptAllStatusCodes: true,
  );

  void _assertOk(Response r, [List<int> ok = const [200, 201]]) {
    if (!ok.contains(r.statusCode)) {
      throw ApiException(
        message: 'Request failed (${r.statusCode}): ${r.data}',
      );
    }
  }

  Future<List<SGTINReportingRegime>> getRegimes(String sgtinId) async {
    final t = await _token();
    final r = await _get(PharmaPaths.regimes(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINReportingRegime.fromJson);
  }

  Future<SGTINReportingRegime> enrolRegime(
    String sgtinId,
    SGTINReportingRegime regime,
  ) async {
    final t = await _token();
    final r = await _post(PharmaPaths.regimes(sgtinId), t, regime.toJson());
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINReportingRegime.fromJson);
  }

  Future<SGTINReportingRegime> unenrolRegime(
    String sgtinId,
    String regimeType,
  ) async {
    final t = await _token();
    final r = await _delete(PharmaPaths.regime(sgtinId, regimeType), t);
    _assertOk(r);
    return _decode(r.data, SGTINReportingRegime.fromJson);
  }

  Future<List<SGTINEmvoUpload>> getEmvoUploads(String sgtinId) async {
    final t = await _token();
    final r = await _get(PharmaPaths.emvo(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> getLatestEmvoUpload(String sgtinId) async {
    final t = await _token();
    final r = await _get(PharmaPaths.emvoLatest(sgtinId), t);
    _assertOk(r);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> initiateEmvoUpload(String sgtinId) async {
    final t = await _token();
    final r = await _post(PharmaPaths.emvoInitiate(sgtinId), t);
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> submitEmvoCommissioning(String sgtinId) async {
    final t = await _token();
    final r = await _post(PharmaPaths.emvoCommission(sgtinId), t);
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> submitEmvoDecommissioning(
    String sgtinId, {
    String? reason,
  }) async {
    final t = await _token();
    final path = reason != null
        ? '${PharmaPaths.emvoDecommission(sgtinId)}?reason=${Uri.encodeComponent(reason)}'
        : PharmaPaths.emvoDecommission(sgtinId);
    final r = await _post(path, t);
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> acknowledgeEmvoUpload(
    String uploadId,
    String emvoReferenceId,
  ) async {
    final t = await _token();
    final r = await _patch(
      '${PharmaPaths.emvoAck(uploadId)}?emvoReferenceId=${Uri.encodeComponent(emvoReferenceId)}',
      t,
    );
    _assertOk(r);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> recordEmvoFailure(
    String uploadId,
    String errorMessage,
  ) async {
    final t = await _token();
    final r = await _patch(
      '${PharmaPaths.emvoFail(uploadId)}?errorMessage=${Uri.encodeComponent(errorMessage)}',
      t,
    );
    _assertOk(r);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<SGTINEmvoUpload> scheduleEmvoRetry(String uploadId) async {
    final t = await _token();
    final r = await _post(PharmaPaths.emvoRetry(uploadId), t);
    _assertOk(r);
    return _decode(r.data, SGTINEmvoUpload.fromJson);
  }

  Future<List<SGTINTatmeenSubmission>> getTatmeenSubmissions(
    String sgtinId,
  ) async {
    final t = await _token();
    final r = await _get(PharmaPaths.tatmeen(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINTatmeenSubmission.fromJson);
  }

  Future<SGTINTatmeenSubmission> submitToTatmeen(
    String sgtinId,
    String submissionType,
  ) async {
    final t = await _token();
    final r = await _post(
      '${PharmaPaths.tatmeen(sgtinId)}?submissionType=${Uri.encodeComponent(submissionType)}',
      t,
    );
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINTatmeenSubmission.fromJson);
  }

  Future<SGTINTatmeenSubmission> acknowledgeTatmeen(
    String submissionId,
    String tatmeenRef,
  ) async {
    final t = await _token();
    final r = await _patch(
      '${PharmaPaths.tatmeenAccept(submissionId)}?tatmeenRef=${Uri.encodeComponent(tatmeenRef)}',
      t,
    );
    _assertOk(r);
    return _decode(r.data, SGTINTatmeenSubmission.fromJson);
  }

  Future<SGTINTatmeenSubmission> rejectTatmeen(
    String submissionId,
    String reason,
  ) async {
    final t = await _token();
    final r = await _patch(
      '${PharmaPaths.tatmeenReject(submissionId)}?reason=${Uri.encodeComponent(reason)}',
      t,
    );
    _assertOk(r);
    return _decode(r.data, SGTINTatmeenSubmission.fromJson);
  }

  Future<List<SGTINDscsaOwnership>> getDscsaChain(String sgtinId) async {
    final t = await _token();
    final r = await _get(PharmaPaths.dscsa(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINDscsaOwnership.fromJson);
  }

  Future<SGTINDscsaOwnership> recordOwnershipTransfer(
    String sgtinId,
    SGTINDscsaOwnership dto,
  ) async {
    final t = await _token();
    final r = await _post(PharmaPaths.dscsa(sgtinId), t, dto.toJson());
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINDscsaOwnership.fromJson);
  }

  Future<List<SGTINControlledChain>> getColdChain(String sgtinId) async {
    final t = await _token();
    final r = await _get(PharmaPaths.coldChain(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINControlledChain.fromJson);
  }

  Future<SGTINControlledChain> recordSensorReading(
    String sgtinId,
    double tempMin,
    double tempMax, {
    String? sensorEventId,
    String chainType = 'COLD',
  }) async {
    final t = await _token();
    var path =
        '${PharmaPaths.coldChainReading(sgtinId)}'
        '?tempMin=$tempMin&tempMax=$tempMax&chainType=${Uri.encodeComponent(chainType)}';
    if (sensorEventId != null) {
      path += '&sensorEventId=${Uri.encodeComponent(sensorEventId)}';
    }
    final r = await _post(path, t);
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINControlledChain.fromJson);
  }

  Future<List<SGTINDuplicateEvidence>> getDuplicateEvidence(
    String sgtinId,
  ) async {
    final t = await _token();
    final r = await _get(PharmaPaths.duplicates(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINDuplicateEvidence.fromJson);
  }

  Future<SGTINDuplicateEvidence> recordDuplicateDetection(
    String sgtinId,
    SGTINDuplicateEvidence dto,
  ) async {
    final t = await _token();
    final r = await _post(PharmaPaths.duplicates(sgtinId), t, dto.toJson());
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINDuplicateEvidence.fromJson);
  }

  Future<SGTINDuplicateEvidence> resolveDuplicateEvidence(
    String evidenceId, {
    String? notes,
  }) async {
    final t = await _token();
    final path = notes != null
        ? '${PharmaPaths.duplicateResolve(evidenceId)}?notes=${Uri.encodeComponent(notes)}'
        : PharmaPaths.duplicateResolve(evidenceId);
    final r = await _patch(path, t);
    _assertOk(r);
    return _decode(r.data, SGTINDuplicateEvidence.fromJson);
  }

  Future<List<SGTINRepackagingLink>> getRepackagingLinks(String sgtinId) async {
    final t = await _token();
    final r = await _get(PharmaPaths.repackaging(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINRepackagingLink.fromJson);
  }

  Future<SGTINRepackagingLink> createRepackagingLink(
    SGTINRepackagingLink dto,
  ) async {
    final t = await _token();
    final r = await _post(PharmaPaths.repackagingCreate, t, dto.toJson());
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINRepackagingLink.fromJson);
  }

  Future<List<SGTINAlert>> getAlerts(String sgtinId) async {
    final t = await _token();
    final r = await _get(PharmaPaths.alerts(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINAlert.fromJson);
  }

  Future<List<SGTINAlert>> getOpenAlerts(String sgtinId) async {
    final t = await _token();
    final r = await _get(PharmaPaths.alertsOpen(sgtinId), t);
    _assertOk(r);
    return _decodeList(r.data, SGTINAlert.fromJson);
  }

  Future<SGTINAlert> raiseAlert(
    String sgtinId, {
    required String alertType,
    String severity = 'MEDIUM',
    required String message,
    String? regimeContext,
  }) async {
    final t = await _token();
    final r = await _post(PharmaPaths.alerts(sgtinId), t, {
      'alertType': alertType,
      'severity': severity,
      'message': message,
      'regimeContext': ?regimeContext,
    });
    _assertOk(r, [200, 201]);
    return _decode(r.data, SGTINAlert.fromJson);
  }

  Future<SGTINAlert> acknowledgeAlert(
    String alertId, {
    String? acknowledgedBy,
  }) async {
    final t = await _token();
    final path = acknowledgedBy != null
        ? '${PharmaPaths.alertAck(alertId)}?acknowledgedBy=${Uri.encodeComponent(acknowledgedBy)}'
        : PharmaPaths.alertAck(alertId);
    final r = await _patch(path, t);
    _assertOk(r);
    return _decode(r.data, SGTINAlert.fromJson);
  }

  Future<SGTINAlert> resolveAlert(
    String alertId, {
    String? resolvedBy,
    String? notes,
  }) async {
    final t = await _token();
    var path = PharmaPaths.alertResolve(alertId);
    final params = <String>[];
    if (resolvedBy != null) {
      params.add('resolvedBy=${Uri.encodeComponent(resolvedBy)}');
    }
    if (notes != null) params.add('notes=${Uri.encodeComponent(notes)}');
    if (params.isNotEmpty) path += '?${params.join('&')}';
    final r = await _patch(path, t);
    _assertOk(r);
    return _decode(r.data, SGTINAlert.fromJson);
  }

  Future<void> dispatchCommissioning(String sgtinId) async {
    final t = await _token();
    final r = await _post(PharmaPaths.dispatchCommission(sgtinId), t);
    _assertOk(r);
  }

  Future<void> dispatchDecommissioning(String sgtinId, {String? reason}) async {
    final t = await _token();
    final path = reason != null
        ? '${PharmaPaths.dispatchDecommission(sgtinId)}?reason=${Uri.encodeComponent(reason)}'
        : PharmaPaths.dispatchDecommission(sgtinId);
    final r = await _post(path, t);
    _assertOk(r);
  }

  Future<void> dispatchOwnershipTransfer(
    String sgtinId,
    String fromGln,
    String toGln,
  ) async {
    final t = await _token();
    final r = await _post(
      '${PharmaPaths.dispatchOwnershipTransfer(sgtinId)}'
      '?fromGln=${Uri.encodeComponent(fromGln)}&toGln=${Uri.encodeComponent(toGln)}',
      t,
    );
    _assertOk(r);
  }

  Future<List<GtinBatch>> getBatches(String gtinId) async {
    final t = await _token();
    final r = await _get(PharmaPaths.batches(gtinId), t);
    _assertOk(r);
    return _decodeList(r.data, GtinBatch.fromJson);
  }

  Future<GtinBatch> getBatchByLot(String gtinId, String batchLot) async {
    final t = await _token();
    final r = await _get(PharmaPaths.batchByLot(gtinId, batchLot), t);
    _assertOk(r);
    return _decode(r.data, GtinBatch.fromJson);
  }

  Future<GtinBatch?> tryGetBatchByLot(int gtinId, String batchLot) async {
    final t = await _token();
    final r = await _get(PharmaPaths.batchByLot('$gtinId', batchLot), t);
    if (r.statusCode == 404) return null;
    if (r.statusCode == 200) {
      return _decode(r.data, GtinBatch.fromJson);
    }
    throw ApiException(
      statusCode: r.statusCode,
      message: 'Failed to look up batch/lot',
      responseBody: r.data is String ? r.data as String? : null,
    );
  }

  Future<GtinBatch> createBatch(int gtinId, GtinBatch batch) async {
    final t = await _token();
    final r = await _post(PharmaPaths.batches('$gtinId'), t, batch.toJson());
    if (r.statusCode == 200 || r.statusCode == 201) {
      return _decode(r.data, GtinBatch.fromJson);
    }
    throw ApiException(
      statusCode: r.statusCode,
      message: 'Failed to register batch',
      responseBody: r.data is String ? r.data as String? : null,
    );
  }

  Future<GtinBatch> updateBatch(
    String gtinId,
    String batchId,
    GtinBatch batch,
  ) async {
    final t = await _token();
    final r = await _patch(
      PharmaPaths.batchById(gtinId, batchId),
      t,
      batch.toJson(),
    );
    _assertOk(r);
    return _decode(r.data, GtinBatch.fromJson);
  }
}
