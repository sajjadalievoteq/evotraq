/// Helpers for backend {@code PageResponse} (content + page metadata).
class PageResponseUtils {
  PageResponseUtils._();

  static const int defaultPageSize = 50;
  static const int maxPageSize = 200;

  static int clampSize(int size) {
    if (size <= 0) return defaultPageSize;
    return size > maxPageSize ? maxPageSize : size;
  }

  static List<dynamic> contentList(Map<String, dynamic> data) =>
      data['content'] as List<dynamic>? ?? const [];

  static bool isLast(Map<String, dynamic> data) => data['last'] as bool? ?? true;

  static int pageNumber(Map<String, dynamic> data, {int fallback = 0}) =>
      (data['pageNumber'] ?? data['number'] ?? fallback) as int;

  static int pageSize(Map<String, dynamic> data, {int fallback = defaultPageSize}) =>
      (data['pageSize'] ?? data['size'] ?? fallback) as int;

  static int totalPages(Map<String, dynamic> data, {int fallback = 1}) =>
      (data['totalPages'] ?? fallback) as int;

  /// Normalizes a decoded GET body into page metadata + [content] list.
  /// Supports legacy bare JSON arrays.
  static Map<String, dynamic> normalizeBody(dynamic decoded, {int fallbackSize = defaultPageSize}) {
    if (decoded is List) {
      return {
        'content': decoded,
        'totalElements': decoded.length,
        'totalPages': 1,
        'pageNumber': 0,
        'pageSize': decoded.length,
        'first': true,
        'last': true,
      };
    }
    if (decoded is Map<String, dynamic>) {
      if (decoded['content'] is List) {
        return decoded;
      }
    }
    throw FormatException('Expected PageResponse or JSON array, got: ${decoded.runtimeType}');
  }

  static Map<String, dynamic> toResultMap({
    required List<dynamic> content,
    required Map<String, dynamic> raw,
  }) {
    return {
      'content': content,
      'totalElements': raw['totalElements'],
      'totalPages': totalPages(raw),
      'currentPage': pageNumber(raw),
      'size': pageSize(raw, fallback: content.length),
      'first': raw['first'],
      'last': isLast(raw),
    };
  }

  static Future<List<T>> fetchAllPages<T>({
    required Future<Map<String, dynamic>> Function(int page, int size) fetchPage,
    required T Function(Map<String, dynamic> json) parseItem,
    int pageSize = maxPageSize,
  }) async {
    final all = <T>[];
    var page = 0;
    final size = clampSize(pageSize);

    while (true) {
      final raw = await fetchPage(page, size);
      final content = contentList(raw);
      for (final item in content) {
        if (item is Map<String, dynamic>) {
          all.add(parseItem(item));
        } else if (item is Map) {
          all.add(parseItem(Map<String, dynamic>.from(item)));
        }
      }
      if (isLast(raw)) break;
      page++;
    }

    return all;
  }
}
