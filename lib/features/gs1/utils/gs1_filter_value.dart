/// “All” or null → [null] for API/nullable filter parameters (GTIN/GLN list).
String? gs1ValueUnlessAll(String? value) {
  if (value == null || value == 'All') return null;
  return value;
}
