import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
/// Normalizes any scanned or stored EPC value to canonical EPC URI form
/// before hierarchy API calls or navigation.
String normalizeHierarchyEpc(String epc) {
  final trimmed = epc.trim();
  if (trimmed.isEmpty) return trimmed;
  return EPCURIConverter.convertToEPCUri(trimmed) ?? trimmed;
}

/// Concatenates EPC values from separate model fields for display only.
/// Does not interpret relationships — callers pass raw model data.
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
