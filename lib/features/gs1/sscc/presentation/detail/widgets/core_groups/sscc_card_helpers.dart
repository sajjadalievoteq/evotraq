import 'package:intl/intl.dart';

String? ssccFormatDt(DateTime? dt) {
  if (dt == null) return null;
  return DateFormat('dd MMM yyyy HH:mm').format(dt);
}

String? ssccFormatDate(DateTime? dt) {
  if (dt == null) return null;
  return DateFormat('dd MMM yyyy').format(dt);
}
