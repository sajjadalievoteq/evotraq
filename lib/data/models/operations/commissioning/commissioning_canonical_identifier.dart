String? parseCommissioningCanonicalIdentifier(Map<String, dynamic> json) {
  final canonical = json['canonicalIdentifier'];
  if (canonical is String && canonical.trim().isNotEmpty) {
    return canonical.trim();
  }
  for (final key in ['epcUri', 'gs1DigitalLinkUri', 'ssccUri']) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
