/// Shared date/time formatter for all operation detail screens.
/// Replaces 10 identical *DetailFormatters classes.
class OperationDetailFormatters {
  OperationDetailFormatters._();

  static String formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${_pad(local.month)}-${_pad(local.day)}  '
        '${_pad(local.hour)}:${_pad(local.minute)}:${_pad(local.second)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
