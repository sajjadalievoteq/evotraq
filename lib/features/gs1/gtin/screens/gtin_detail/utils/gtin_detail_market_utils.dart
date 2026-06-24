bool isRegulatoryAuthorityMarket(String? targetMarketCountry) {
  final raw = (targetMarketCountry ?? '').trim();
  if (raw.isEmpty) return false;
  final digits = RegExp(r'\d+').stringMatch(raw);
  return digits == '784';
}
