abstract final class GtinDetailConstants {
  /// Documentation: GDSN `tradeItemUnitDescriptorCode` (unit_descriptor).
  /// Note: backend `packagingLevel` currently supports a subset; unmapped values are blocked by validator.
  static const List<String> unitDescriptorOptions = [
    'BASE_UNIT_OR_EACH',
    'PACK_OR_INNER_PACK',
    'CASE',
    'PALLET',
    'DISPLAY_SHIPPER',
    'MIXED_MODULE',
    'PREPACK_ASSORTMENT',
  ];

  static const List<String> statusOptions = [
    'ACTIVE',
    'WITHDRAWN',
    'SUSPENDED',
    'DISCONTINUED',
  ];

}

