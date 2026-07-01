/// Date/time formatting helpers for return Return Receiving operation detail.
class ReturnReceivingDetailFormatters {
  ReturnReceivingDetailFormatters._();

  static String formatDateTime(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}  '
        '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}


