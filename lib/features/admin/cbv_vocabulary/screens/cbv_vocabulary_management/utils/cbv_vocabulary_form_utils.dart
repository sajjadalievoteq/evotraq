String computeCbvUrn({required bool isBizStep, required String code}) {
  if (code.isEmpty) return '';
  final ns = isBizStep ? 'urn:epcglobal:cbv:bizstep' : 'urn:epcglobal:cbv:disp';
  return '$ns:$code';
}

String labelToCbvCode(String label) {
  return label
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}
