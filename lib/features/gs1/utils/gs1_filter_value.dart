String? gs1ValueUnlessAll(String? value) {
  if (value == null || value == 'All') return null;
  return value;
}
