import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/hierarchy/hierarchy_page.dart';
import 'package:traqtrace_app/data/models/operations/hierarchy/hierarchy_summary.dart';
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
  }) async {
    final normalizedParent = normalizeHierarchyEpc(parentEpc);
    try {
      final headers = await _headers;
      final encodedEpc = Uri.encodeComponent(normalizedParent);
      final response = await _dioService.get(
        '${_dioService.baseUrl}/events/aggregation/parent/$encodedEpc/children',
        queryParameters: {'page': page.toString(), 'size': size.toString()},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data) as Map<String, dynamic>;
        return HierarchyPage.fromJson(data);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to load hierarchy children',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, st) {
      throw _apiExceptionFromDio(
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

  /// Resolves the active parent SSCC for [childEpc], or null if not aggregated.
  Future<String?> getParentContainer(String childEpc) async {
    final normalized = normalizeHierarchyEpc(childEpc);
    try {
      final headers = await _headers;
      final encodedEpc = Uri.encodeComponent(normalized);
      final response = await _dioService.get(
        '${_dioService.baseUrl}/events/aggregation/child/$encodedEpc/container',
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

  /// Walks upward from [epc] through all parent containers and returns the
  /// root ancestor EPC. If [epc] has no parent, returns [epc] itself.
  /// Never throws — returns [epc] as a safe fallback on any error.
  Future<String> getRootContainer(String epc) async {
    final normalized = normalizeHierarchyEpc(epc);
    try {
      final headers = await _headers;
      final encodedEpc = Uri.encodeComponent(normalized);
      final response = await _dioService.get(
        '${_dioService.baseUrl}/events/aggregation/child/$encodedEpc/root-container',
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

  /// Fetches the full recursive hierarchy summary for [rootEpc] via the
  /// traversal endpoint. Returns null if the EPC has no aggregation history
  /// (404) — callers should treat null as "no summary available" rather than
  /// an error.
  Future<HierarchySummary?> getHierarchySummary(String rootEpc) async {
    final normalized = normalizeHierarchyEpc(rootEpc);
    try {
      final headers = await _headers;
      final encodedEpc = Uri.encodeComponent(normalized);
      final response = await _dioService.get(
        '${_dioService.baseUrl}/events/query/traversal/hierarchy/$encodedEpc',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data) as Map<String, dynamic>;
        return HierarchySummary.fromJson(data);
      }

      // 404 = no aggregation events for this EPC — not an error
      if (response.statusCode == 404) return null;

      // Any other status: log and return null (summary is best-effort)
      debugPrint(
        '[HierarchyService] getHierarchySummary status=${response.statusCode}',
      );
      return null;
    } catch (e, st) {
      // Summary is bonus info — never crash the screen because of it
      debugPrint('[HierarchyService] getHierarchySummary error: $e\n$st');
      return null;
    }
  }

  ApiException _apiExceptionFromResponse(
    Response<dynamic> response, {
    required String fallbackMessage,
  }) {
    return ApiException(
      statusCode: response.statusCode,
      message: fallbackMessage,
      responseBody: response.data?.toString(),
    );
  }

  ApiException _apiExceptionFromDio(
    DioException exception, {
    required String fallbackMessage,
    StackTrace? stackTrace,
  }) {
    return ApiException(
      statusCode: exception.response?.statusCode,
      message: fallbackMessage,
      responseBody: exception.response?.data?.toString(),
      originalException: exception,
    );
  }
}
