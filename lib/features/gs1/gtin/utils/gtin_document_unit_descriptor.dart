abstract final class GtinDocumentUnitDescriptor {
  static String? fromBackend({
    required String? unitDescriptor,
    required String? packagingLevel,
  }) {
    final unit = (unitDescriptor ?? '').trim();
    if (unit.isNotEmpty) return unit;

    final packaging = (packagingLevel ?? '').trim().toUpperCase();
    return switch (packaging) {
      'ITEM' => 'BASE_UNIT_OR_EACH',
      'PACK' => 'PACK_OR_INNER_PACK',
      'CASE' => 'CASE',
      'PALLET' => 'PALLET',
      _ => null,
    };
  }
}
