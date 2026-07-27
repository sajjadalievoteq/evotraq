import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_page.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';

class HierarchyService {
  HierarchyService({required DioService dioService}) : _dioService = dioService;

  final DioService _dioService;

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<HierarchyPage> getHierarchyChildren(
    String parentEpc, {
    int page = 0,
    int size = 20,
    List<String>? ancestorEpcs,
  }) async {
    final normalizedParent = normalizeHierarchyEpc(parentEpc);
    try {
      final headers = await _headers;
      final queryParameters = <String, dynamic>{
        'parentEPC': normalizedParent,
        'page': page.toString(),
        'size': size.toString(),
      };
      if (ancestorEpcs != null && ancestorEpcs.isNotEmpty) {
        queryParameters['ancestorEpcs'] = ancestorEpcs
            .map(normalizeHierarchyEpc)
            .toList();
      }
      final response = await _dioService.get(
        '${_dioService.baseUrl}/events/aggregation/children',
        queryParameters: queryParameters,
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data) as Map<String, dynamic>;
        return HierarchyPage.fromJson(data);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to load hierarchy children',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, st) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: st,
        fallbackMessage: 'Network error loading hierarchy',
      );
    } catch (e, st) {
      debugPrint('[HierarchyService] unexpected: $e\n$st');
      throw ApiException(
        message: 'Unexpected error loading hierarchy',
        originalException: e,
      );
    }
  }

  /// Climb one level: resolve active parent of [focusEpc] and return siblings page.
  Future<HierarchyPage> getParentContext(
    String focusEpc, {
    int size = 20,
    List<String>? ancestorEpcs,
  }) async {
    final normalizedFocus = normalizeHierarchyEpc(focusEpc);
    try {
      final headers = await _headers;
      final queryParameters = <String, dynamic>{
        'focusEpc': normalizedFocus,
        'size': size.toString(),
      };
      if (ancestorEpcs != null && ancestorEpcs.isNotEmpty) {
        queryParameters['ancestorEpcs'] = ancestorEpcs
            .map(normalizeHierarchyEpc)
            .toList();
      }
      final response = await _dioService.get(
        '${_dioService.baseUrl}/events/aggregation/children',
        queryParameters: queryParameters,
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data) as Map<String, dynamic>;
        return HierarchyPage.fromJson(data);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to load parent context',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, st) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: st,
        fallbackMessage: 'Network error loading parent context',
      );
    } catch (e, st) {
      debugPrint('[HierarchyService] getParentContext unexpected: $e\n$st');
      throw ApiException(
        message: 'Unexpected error loading parent context',
        originalException: e,
      );
    }
  }

  Future<String?> getParentContainer(String childEpc) async {
    final normalized = normalizeHierarchyEpc(childEpc);
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '${_dioService.baseUrl}/events/aggregation/container',
        queryParameters: {'childEPC': normalized},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final raw = response.data?.toString().trim();
        if (raw != null && raw.isNotEmpty && raw != 'null') {
          return normalizeHierarchyEpc(raw.replaceAll('"', ''));
        }
      }
      return null;
    } catch (e, st) {
      debugPrint('[HierarchyService] getParentContainer error: $e\n$st');
      return null;
    }
  }

  Future<String> getRootContainer(String epc) async {
    final normalized = normalizeHierarchyEpc(epc);
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '${_dioService.baseUrl}/events/aggregation/root-container',
        queryParameters: {'childEPC': normalized},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final raw = response.data?.toString().trim() ?? '';
        final cleaned = normalizeHierarchyEpc(raw.replaceAll('"', ''));
        return cleaned.isNotEmpty ? cleaned : normalized;
      }
      return normalized;
    } catch (e, st) {
      debugPrint('[HierarchyService] getRootContainer error: $e\n$st');
      return normalized;
    }
  }
}
