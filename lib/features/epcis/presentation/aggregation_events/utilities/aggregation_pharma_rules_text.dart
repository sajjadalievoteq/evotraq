/// Plain-language GS1 pharmaceutical rules shown on the aggregation create form.
abstract final class AggregationPharmaRulesText {
  static const String sectionTitle = 'Pharmaceutical packing rules';

  static const String intro =
      'SSCC, SGTIN, and GLN values must already exist in the database, '
      'belong to your organisation, and be commissioned before packing.';

  static const List<String> rules = [
    'Location GLN must be registered, active, and the site where you are packing.',
    'Parent container (SSCC or GTIN+serial) must be commissioned and in ACTIVE or RECEIVED status.',
    'Containers that are traveling (IN_TRANSIT), voided, decommissioned, damaged, lost (STOLEN), destroyed, recalled, or expired cannot be packed.',
    'Every child SGTIN must be commissioned and in COMMISSIONED, ACTIVE, or RECEIVED status.',
    'All child items must be under your custody at the selected location GLN.',
    'All child items must be physically at the same location as the parent container when packing or repacking.',
    'Child items must share the same custodian as the parent box or case.',
    'Homogeneous SSCCs may only contain SGTINs with matching GTIN, batch, and expiry (XSC-005).',
    'Each serial may have only one active parent container at a time.',
  ];

  static const String parentPackHint =
      'Parent must be commissioned, on-site at your location GLN, and packable (not in transit or terminal).';

  static const String childEpcsHint =
      'Each child must be commissioned, at your location, and match the parent container custody.';

  static const String locationHint =
      'Select the GLN where packing occurs — all items must be available at this site.';
}
