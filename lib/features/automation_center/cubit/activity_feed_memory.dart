import 'package:flutter/foundation.dart';

/// Sliding window for newest-first Activity feeds.
///
/// Pages are appended as the user loads older history. When the in-memory
/// window exceeds [maxRecords], one page is dropped from the **newest** side
/// so older pagination can continue without unbounded growth. Pull-to-refresh
/// / filter changes reload page 0 and restore the newest window.
@immutable
abstract final class ActivityFeedMemory {
  static const int pageSize = 20;

  /// Five pages of [pageSize] — documented bound for delivery + exhausted batches.
  static const int maxPages = 5;
  static const int maxRecords = maxPages * pageSize;

  /// Deduplicate by [idOf], append [incoming], then enforce [maxRecords].
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

  /// Drops from the newest side until within [maxRecords].
  static List<T> trimNewestSide<T>(List<T> items) {
    if (items.length <= maxRecords) return List<T>.from(items);
    return items.sublist(items.length - maxRecords);
  }
}
