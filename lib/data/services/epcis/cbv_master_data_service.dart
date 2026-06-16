import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_master_data_api_consts.dart';

class CbvMasterDataService {
  final DioService _dioService;

  List<CbvVocabularyItem>? _cachedBizSteps;
  List<CbvVocabularyItem>? _cachedDispositions;
  final Map<String, List<CbvVocabularyItem>> _cachedValidDispositions = {};

  CbvMasterDataService({required DioService dioService})
      : _dioService = dioService;

  String get _base => _dioService.baseUrl;

  Future<List<CbvVocabularyItem>> getBizSteps({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedBizSteps != null) {
      return _cachedBizSteps!;
    }
    final items = await _fetchList(CbvMasterDataApiConsts.bizSteps);
    _cachedBizSteps = items;
    return items;
  }

  Future<List<CbvVocabularyItem>> getDispositions({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDispositions != null) {
      return _cachedDispositions!;
    }
    final items = await _fetchList(CbvMasterDataApiConsts.dispositions);
    _cachedDispositions = items;
    return items;
  }

  Future<List<CbvVocabularyItem>> getValidDispositionsForBizStep(
    String bizStepCode, {
    bool forceRefresh = false,
  }) async {
    final normalized = bizStepCode.trim().toLowerCase();
    if (!forceRefresh && _cachedValidDispositions.containsKey(normalized)) {
      return _cachedValidDispositions[normalized]!;
    }
    final items = await _fetchList(
      CbvMasterDataApiConsts.validDispositionsPath(normalized),
    );
    _cachedValidDispositions[normalized] = items;
    return items;
  }

  Future<void> preloadSessionCache() async {
    await getBizSteps();
    await getDispositions();
  }

  void clearCache() {
    _cachedBizSteps = null;
    _cachedDispositions = null;
    _cachedValidDispositions.clear();
  }

  Future<List<CbvVocabularyItem>> _fetchList(String path) async {
    final url = '$_base$path';
    final response = await _dioService.get(
      url,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load CBV vocabulary from $path',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }

    final decoded = json.decode(response.data);
    if (decoded is! List) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unexpected CBV vocabulary response format',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }

    return decoded
        .map((entry) => CbvVocabularyItem.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ))
        .toList();
  }
}
