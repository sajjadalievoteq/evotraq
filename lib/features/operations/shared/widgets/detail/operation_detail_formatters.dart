import 'package:traqtrace_app/core/utils/app_time.dart';

class OperationDetailFormatters {
  OperationDetailFormatters._();

  static String formatDateTime(DateTime dt) {
    final uae = AppTime.toUae(dt);
    return '${uae.year}-${_pad(uae.month)}-${_pad(uae.day)}  '
        '${_pad(uae.hour)}:${_pad(uae.minute)}:${_pad(uae.second)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
