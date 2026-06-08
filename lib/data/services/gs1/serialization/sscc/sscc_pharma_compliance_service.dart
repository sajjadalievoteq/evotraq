import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_controlled_chain_audit_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_emvo_submission_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_reporting_regime_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_tatmeen_submission_model.dart';

abstract final class _Paths {
  static String base(String ssccId) => '/identifiers/ssccs/$ssccId/pharma';

  static String regimes(String id) => '${base(id)}/regimes';
  static String regime(String id, String code) => '${base(id)}/regimes/$code';
  static String tatmeen(String id) => '${base(id)}/tatmeen';
  static String emvo(String id) => '${base(id)}/emvo';
  static String controlledChain(String id) => '${base(id)}/controlled-chain';
  static String coldChainExcursion(String id) => '${base(id)}/cold-chain/excursion';
  static String tatmeenAck(String submissionId) =>
      '/identifiers/ssccs/pharma/tatmeen/$submissionId/acknowledge';
}

class SsccPharmaComplianceService {
  SsccPharmaComplianceService({required DioService dioService})
      : _dio = dioService;

  final DioService _dio;

  Future<String> _token() async {
    final token = await _dio.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    return token;
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  List<T> _decodeList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = json.decode(data as String) as List<dynamic>;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SsccReportingRegime>> getRegimes(String ssccId) async {
    final token = await _token();
    final response = await _dio.get(
      '${_dio.baseUrl}${_Paths.regimes(ssccId)}',
      headers: _headers(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      return _decodeList(response.data, SsccReportingRegime.fromJson);
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to load SSCC reporting regimes',
    );
  }

  Future<SsccReportingRegime> enrolRegime(
    String ssccId,
    String regimeCode,
  ) async {
    final token = await _token();
    final response = await _dio.post(
      '${_dio.baseUrl}${_Paths.regimes(ssccId)}',
      headers: _headers(token),
      data: json.encode({'regimeCode': regimeCode}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return SsccReportingRegime.fromJson(
        json.decode(response.data) as Map<String, dynamic>,
      );
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to enrol SSCC reporting regime',
    );
  }

  Future<void> removeRegime(String ssccId, String regimeCode) async {
    final token = await _token();
    final response = await _dio.delete(
      '${_dio.baseUrl}${_Paths.regime(ssccId, regimeCode)}',
      headers: _headers(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to remove SSCC reporting regime',
      );
    }
  }

  Future<List<SsccTatmeenSubmission>> getTatmeenSubmissions(
    String ssccId,
  ) async {
    final token = await _token();
    final response = await _dio.get(
      '${_dio.baseUrl}${_Paths.tatmeen(ssccId)}',
      headers: _headers(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      return _decodeList(response.data, SsccTatmeenSubmission.fromJson);
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to load Tatmeen submissions',
    );
  }

  Future<List<SsccEmvoSubmission>> getEmvoSubmissions(String ssccId) async {
    final token = await _token();
    final response = await _dio.get(
      '${_dio.baseUrl}${_Paths.emvo(ssccId)}',
      headers: _headers(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      return _decodeList(response.data, SsccEmvoSubmission.fromJson);
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to load EMVO submissions',
    );
  }

  Future<List<SsccControlledChainAudit>> getControlledChainAudits(
    String ssccId,
  ) async {
    final token = await _token();
    final response = await _dio.get(
      '${_dio.baseUrl}${_Paths.controlledChain(ssccId)}',
      headers: _headers(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      return _decodeList(response.data, SsccControlledChainAudit.fromJson);
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to load controlled chain audits',
    );
  }

  Future<SsccTatmeenSubmission> acknowledgeTatmeen(int submissionId) async {
    final token = await _token();
    final response = await _dio.patch(
      '${_dio.baseUrl}${_Paths.tatmeenAck(submissionId.toString())}',
      headers: _headers(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      return SsccTatmeenSubmission.fromJson(
        json.decode(response.data) as Map<String, dynamic>,
      );
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to acknowledge Tatmeen submission',
    );
  }

  Future<void> reportColdChainExcursion(String ssccId) async {
    final token = await _token();
    final response = await _dio.post(
      '${_dio.baseUrl}${_Paths.coldChainExcursion(ssccId)}',
      headers: _headers(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to report cold-chain excursion',
      );
    }
  }

  Future<SsccControlledChainAudit> recordControlledChainTransfer(
    String ssccId,
    SsccControlledChainAudit audit,
  ) async {
    final token = await _token();
    final response = await _dio.post(
      '${_dio.baseUrl}${_Paths.controlledChain(ssccId)}',
      headers: _headers(token),
      data: json.encode(audit.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return SsccControlledChainAudit.fromJson(
        json.decode(response.data) as Map<String, dynamic>,
      );
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to record controlled chain transfer',
    );
  }
}
