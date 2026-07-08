import 'dart:convert';

dynamic decodeApiResponseBody(dynamic data) {
  if (data == null) return null;
  if (data is String) {
    final trimmed = data.trim();
    if (trimmed.isEmpty) return null;
    return jsonDecode(trimmed);
  }
  return data;
}

Map<String, dynamic> decodeApiResponseMap(dynamic data) {
  final decoded = decodeApiResponseBody(data);
  if (decoded is Map<String, dynamic>) return decoded;
  if (decoded is Map) return Map<String, dynamic>.from(decoded);
  throw FormatException(
    'Expected a JSON object in the response body, got ${decoded.runtimeType}',
  );
}

List<dynamic> decodeApiResponseList(dynamic data) {
  final decoded = decodeApiResponseBody(data);
  if (decoded is List) return decoded;
  throw FormatException(
    'Expected a JSON array in the response body, got ${decoded.runtimeType}',
  );
}
