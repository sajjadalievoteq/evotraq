import 'package:flutter/foundation.dart';

@immutable
abstract final class ActivityFeedMemory {
  static const int pageSize = 20;

  static const int maxPages = 5;
  static const int maxRecords = maxPages * pageSize;

  static List<T> appendBounded<T>({
    required List<T> existing,
    required List<T> incoming,
    required String Function(T item) idOf,
  }) {
    final seen = existing.map(idOf).toSet();
    final merged = <T>[
      ...existing,
      for (final item in incoming)
        if (!seen.contains(idOf(item))) item,
    ];
    return trimNewestSide(merged);
  }

  static List<T> trimNewestSide<T>(List<T> items) {
    if (items.length <= maxRecords) return List<T>.from(items);
    return items.sublist(items.length - maxRecords);
  }
}