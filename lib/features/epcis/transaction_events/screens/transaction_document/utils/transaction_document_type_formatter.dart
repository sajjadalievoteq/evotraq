class TransactionDocumentTypeFormatter {
  const TransactionDocumentTypeFormatter._();

  static String displayName(String value) {
    const prefix = 'urn:epcglobal:cbv:btt:';
    if (!value.startsWith(prefix)) return value;

    final shortName = value.substring(prefix.length);
    return switch (shortName) {
      'inv' => 'Invoice',
      'po' => 'Purchase Order',
      'desadv' => 'Despatch Advice',
      'packing-list' => 'Packing List',
      'receipt' => 'Receipt Advice',
      'bol' => 'Bill of Lading',
      'cert' => 'Certificate',
      'pedigree' => 'Pedigree',
      'prodorder' => 'Production Order',
      'transdoc' => 'Transport Document',
      'customs' => 'Customs Declaration',
      'contract' => 'Contract',
      _ => shortName,
    };
  }
}
