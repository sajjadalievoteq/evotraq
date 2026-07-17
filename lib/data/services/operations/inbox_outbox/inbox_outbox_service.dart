import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/api_response_body.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/services/operations/inbox_outbox/inbox_outbox_direction.dart';
import 'package:traqtrace_app/features/inbox_outbox/models/inbox_outbox_list_filter.dart';

class InboxOutboxService {
  InboxOutboxService({required DioService dioService}) : _dioService = dioService;

  final DioService _dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/in-transit';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<OperationPage<ShippingResponse>> getFilteredInTransitPage({
    required String gln,
    required InboxOutboxListFilter filter,
    int page = 0,
    int size = 20,
    String? search,
  }) {
    return switch (filter) {
      InboxOutboxListFilter.inbox => getInTransitOperationsPage(
          gln: gln,
          direction: InboxOutboxDirection.inbound,
          page: page,
          size: size,
          search: search,
        ),
      InboxOutboxListFilter.outbox => getInTransitOperationsPage(
          gln: gln,
          direction: InboxOutboxDirection.outbound,
          page: page,
          size: size,
          search: search,
        ),
      InboxOutboxListFilter.all => _getAllInTransitPage(
          gln: gln,
          page: page,
          size: size,
          search: search,
        ),
    };
  }

  Future<OperationPage<ShippingResponse>> _getAllInTransitPage({
    required String gln,
    required int page,
    required int size,
    String? search,
  }) async {
    final results = await Future.wait([
      getInTransitOperationsPage(
        gln: gln,
        direction: InboxOutboxDirection.inbound,
        page: page,
        size: size,
        search: search,
      ),
      getInTransitOperationsPage(
        gln: gln,
        direction: InboxOutboxDirection.outbound,
        page: page,
        size: size,
        search: search,
      ),
    ]);

    final merged = <String, ShippingResponse>{};
    for (final response in results) {
      for (final operation in response.operations) {
        final id = operation.navigableOperationId;
        if (id == null) continue;
        merged[id] = operation;
      }
    }

    final operations = merged.values.toList()
      ..sort((a, b) {
        final aTime = a.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.processedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

    final inbound = results[0];
    final outbound = results[1];
    final hasMore = inbound.hasMore || outbound.hasMore;
    final estimatedTotalPages = inbound.totalPages > outbound.totalPages
        ? inbound.totalPages
        : outbound.totalPages;
    final totalPages = hasMore
        ? (estimatedTotalPages > page + 1 ? estimatedTotalPages : page + 2)
        : (operations.isEmpty ? 0 : page + 1);

    return OperationPage<ShippingResponse>(
      operations: operations,
      page: page,
      size: size,
      count: operations.length,
      total: inbound.total + outbound.total,
      totalPages: totalPages,
    );
  }

  Future<OperationPage<ShippingResponse>> getInTransitOperationsPage({
    required String gln,
    required InboxOutboxDirection direction,
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        _baseUrl,
        queryParameters: {
          'gln': gln,
          'direction': direction.apiValue,
          'page': page.toString(),
          'size': size.toString(),
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = decodeApiResponseMap(response.data);
        return OperationPage.fromJson(responseData, ShippingResponse.fromJson);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to load in-transit operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading in-transit operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[InboxOutboxService.page] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading in-transit operations',
        originalException: e,
      );
    }
  }
}
