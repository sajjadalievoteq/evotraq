import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart' show FormData, MultipartFile, DioMediaType;
import 'package:traqtrace_app/core/network/dio_service.dart';

class PostmanDownloadInfo {
  final String url;
  final String filename;
  PostmanDownloadInfo({required this.url, required this.filename});
}

class PostmanCollectionService {
  final DioService _dioService;

  PostmanCollectionService({required DioService dioService})
      : _dioService = dioService;

  Future<PostmanDownloadInfo> getDownloadUrl() async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}/admin/postman/download-url',
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final data = _decodeMap(response.data);
      return PostmanDownloadInfo(
        url: data['url'] as String,
        filename: data['filename'] as String,
      );
    }

    final err = _extractError(response.data);
    throw Exception(err);
  }

  Future<void> uploadCollection(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: filename.toLowerCase().endsWith('.zip')
            ? DioMediaType('application', 'zip')
            : DioMediaType('application', 'json'),
      ),
    });

    final response = await _dioService.post(
      '${_dioService.baseUrl}/admin/postman/upload',
      data: formData,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      final err = _extractError(response.data);
      throw Exception(err);
    }
  }

  Map<String, dynamic> _decodeMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      return Map<String, dynamic>.from(json.decode(data) as Map);
    }
    throw Exception('Unexpected response format');
  }

  String _extractError(dynamic data) {
    try {
      final map = _decodeMap(data);
      return map['error'] as String? ?? 'Unknown error';
    } catch (_) {
      return data?.toString() ?? 'Unknown error';
    }
  }
}
