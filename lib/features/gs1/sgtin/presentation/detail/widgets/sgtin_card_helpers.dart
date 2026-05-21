import 'package:intl/intl.dart';

/// Formats [dt] as "dd MMM yyyy HH:mm" for display in SGTIN detail cards.
/// Returns `null` when [dt] is null.
String? sgtinFormatDt(DateTime? dt) {
  if (dt == null) return null;
  return DateFormat('dd MMM yyyy HH:mm').format(dt);
}

/// Formats a guessing-probability fraction (e.g. 0.0001) as "1 in 10,000".
String sgtinFormatGuessingProb(double prob) {
  if (prob <= 0) return '1 in > 1,000,000';
  final n = (1.0 / prob).round();
  return '1 in ${NumberFormat('#,###').format(n)}';
}
