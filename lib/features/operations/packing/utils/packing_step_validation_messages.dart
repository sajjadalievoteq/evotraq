
abstract final class PackingStepValidationMessages {
  static const packingLocationRequired =
      'Select where packing is taking place. Search for your site by name or GLN.';

  static const parentContainerRequired =
      'Scan or enter the parent container — an SSCC (carton/pallet) or a case-level SGTIN (GTIN + serial).';

  static const itemsRequired =
      'Add at least one product to pack. Scan each item\'s GTIN + serial barcode.';

  static const invalidParentType =
      'Parent container must be an SSCC (carton/pallet) or a case-level SGTIN (GTIN + serial).';

  static const invalidItemForPacking =
      'This barcode is not valid for packing. Scan a product serial (SGTIN) or a nested SSCC.';

  static const invalidItemEpc =
      'This barcode is not a valid product label. Scan a GTIN + serial, lot-based GTIN, or nested SSCC.';

  static const itemAddFallback =
      'This item cannot be added to the packing list. Use a commissioned SGTIN or SSCC only.';
}
