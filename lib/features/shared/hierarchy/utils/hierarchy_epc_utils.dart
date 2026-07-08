import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
String normalizeHierarchyEpc(String epc) {
  final trimmed = epc.trim();
  if (trimmed.isEmpty) return trimmed;
  return Gs1Converter.barcodeToEpc(trimmed) ?? trimmed;
}

List<String> mergeModelEpcFields({
  String? leading,
  Iterable<String>? trailing,
}) {
  final result = <String>[];
  final seen = <String>{};

  void add(String? value) {
    if (value == null) return;
    final trimmed = value.trim();
    if (trimmed.isEmpty || !seen.add(trimmed)) return;
    result.add(trimmed);
  }

  add(leading);
  if (trailing != null) {
    for (final value in trailing) {
      add(value);
    }
  }
  return result;
}
