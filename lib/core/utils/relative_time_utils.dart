abstract final class RelativeTimeUtils {
  static String compactAgo(DateTime dateTime, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final difference = current.difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  static String recentWithYesterdayOrDate(DateTime dateTime, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final difference = current.difference(dateTime);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) return '${difference.inMinutes}m ago';
      return '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
