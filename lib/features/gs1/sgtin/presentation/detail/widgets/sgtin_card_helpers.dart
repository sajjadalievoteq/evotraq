import 'package:intl/intl.dart';

String? sgtinFormatDt(DateTime? dt) {
  if (dt == null) return null;
  return DateFormat('dd MMM yyyy HH:mm').format(dt);
}

String sgtinFormatGuessingProb(double prob) {
  if (prob <= 0) return '1 in > 1,000,000';
  final n = (1.0 / prob).round();
  return '1 in ${NumberFormat('#,###').format(n)}';
}
