import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_session.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_master_data_api_consts.dart';

class CbvMasterDataService {
  final DioService _dioService;

  /// Cache for the enabled-only vocabulary session (used by event form dropdowns).
  /// Admin "all items" calls are never cached so they always reflect the latest state.
  CbvVocabularySession? _enabledOnlyCache;

  CbvMasterDataService({required DioService dioService})
      : _dioService = dioService;

  String get _base => _dioService.baseUrl;

  // ──────────────────────────────────────────────────────────────────────────
  // Load
  // ──────────────────────────────────────────────────────────────────────────

  /// Loads the combined vocabulary session.
  ///
  /// [enabledOnly] — when `true` (default) returns only enabled items and
  /// caches the result for fast repeat access (used by event form dropdowns).
  /// Pass `enabledOnly: false` to retrieve all items including disabled ones
  /// (admin management screen); this path is never cached.
  Future<CbvVocabularySession> loadVocabularySession({
    bool forceRefresh = false,
    bool enabledOnly = true,
  }) async {
    if (enabledOnly && !forceRefresh && _enabledOnlyCache != null) {
      return _enabledOnlyCache!;
    }

    final url = '$_base${CbvMasterDataApiConsts.vocabulary}';
    final response = await _dioService.get(
      url,
      queryParameters: {'enabledOnly': enabledOnly.toString()},
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load CBV vocabulary',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
    final decoded = json.decode(response.data as String);
    if (decoded is! Map) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unexpected CBV vocabulary format',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
    final session =
        CbvVocabularySession.fromJson(Map<String, dynamic>.from(decoded));
    if (enabledOnly) {
      _enabledOnlyCache = session;
    }
    return session;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Toggle enabled
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> toggleBizStepEnabled(String code,
      {required bool enabled}) async {
    final url = '$_base${CbvMasterDataApiConsts.bizStepEnabledPath(code)}';
    final response = await _dioService.patch(
      url,
      data: {'enabled': enabled},
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update biz step $code',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
    _enabledOnlyCache = null;
  }

  Future<void> toggleDispositionEnabled(String code,
      {required bool enabled}) async {
    final url =
        '$_base${CbvMasterDataApiConsts.dispositionEnabledPath(code)}';
    final response = await _dioService.patch(
      url,
      data: {'enabled': enabled},
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update disposition $code',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
    _enabledOnlyCache = null;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Create custom items
  // ──────────────────────────────────────────────────────────────────────────

  Future<CbvVocabularyItem> createBizStep({
    required String code,
    required String label,
    required String urn,
    required bool enabled,
    required String cbvVersion,
  }) async {
    final url = '$_base${CbvMasterDataApiConsts.bizSteps}';
    final response = await _dioService.post(
      url,
      data: {
        'code': code,
        'label': label,
        'urn': urn,
        'enabled': enabled,
        'cbvVersion': cbvVersion,
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 201) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create biz step',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
    _enabledOnlyCache = null;
    final decoded = json.decode(response.data as String);
    return CbvVocabularyItem.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<CbvVocabularyItem> createDisposition({
    required String code,
    required String label,
    required String urn,
    required bool enabled,
    required String cbvVersion,
  }) async {
    final url = '$_base${CbvMasterDataApiConsts.dispositions}';
    final response = await _dioService.post(
      url,
      data: {
        'code': code,
        'label': label,
        'urn': urn,
        'enabled': enabled,
        'cbvVersion': cbvVersion,
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 201) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create disposition',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
    _enabledOnlyCache = null;
    final decoded = json.decode(response.data as String);
    return CbvVocabularyItem.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Delete custom items
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> deleteBizStep(String code) async {
    final url = '$_base${CbvMasterDataApiConsts.bizStepPath(code)}';
    final response = await _dioService.delete(
      url,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to delete biz step $code',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
    _enabledOnlyCache = null;
  }

  Future<void> deleteDisposition(String code) async {
    final url = '$_base${CbvMasterDataApiConsts.dispositionPath(code)}';
    final response = await _dioService.delete(
      url,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to delete disposition $code',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
    _enabledOnlyCache = null;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Pair management (admin only)
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> addPair(String bizStepCode, String dispCode) async {
    final url = '$_base${CbvMasterDataApiConsts.pairPath(bizStepCode, dispCode)}';
    final response = await _dioService.post(
      url,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to add pair $bizStepCode → $dispCode',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
    _enabledOnlyCache = null;
  }

  Future<void> removePair(String bizStepCode, String dispCode) async {
    final url = '$_base${CbvMasterDataApiConsts.pairPath(bizStepCode, dispCode)}';
    final response = await _dioService.delete(
      url,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to remove pair $bizStepCode → $dispCode',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
    _enabledOnlyCache = null;
  }

  void clearCache() => _enabledOnlyCache = null;
}
