import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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

  Future<({Uint8List bytes, String filename})> downloadCollection() async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}/admin/postman/download',
      responseType: ResponseType.bytes,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final raw = response.data;
      final bytes = raw is Uint8List
          ? raw
          : Uint8List.fromList(List<int>.from(raw as List));
      final filename = _filenameFromHeaders(response.headers) ??
          'TraqTrace-API-Collection.zip';
      return (bytes: bytes, filename: filename);
    }

    final err = _extractError(response.data);
    throw Exception(err);
  }

  String? _filenameFromHeaders(Headers headers) {
    final values = headers['content-disposition'];
    if (values == null || values.isEmpty) return null;
    final match =
        RegExp(r'filename="?([^";\n]+)"?').firstMatch(values.first);
    return match?.group(1);
  }

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
