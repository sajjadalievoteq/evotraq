import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/automation_center/inbound_catalog.dart';

class InboundCatalogService {
  InboundCatalogService({required DioService dioService})
    : _dioService = dioService;

  final DioService _dioService;

  static const _catalogPath = '/automation-center/inbound-catalog';
  static const _postmanPath = '/automation-center/inbound-catalog/postman';

  Future<InboundCatalog> fetchCatalog() async {
    final response = await _dioService.get(_catalogPath);
    final data = response.data;
    if (data is! Map) {
      throw const FormatException(
        'Inbound catalog response was not a JSON object',
      );
    }
    return InboundCatalog.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Uint8List> downloadPostmanCollection({
    required String categoryId,
  }) async {
    final response = await _dioService.get(
      _postmanPath,
      queryParameters: {'category': categoryId},
      responseType: ResponseType.bytes,
    );
    final data = response.data;
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    if (data is String) return Uint8List.fromList(data.codeUnits);
    throw const FormatException('Unexpected Postman collection response type');
  }
}
