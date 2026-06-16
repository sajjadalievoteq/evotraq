enum AggregationReferenceKind { gln, gtin, sgtin, sscc }

class AggregationMissingReference {
  const AggregationMissingReference({
    required this.kind,
    required this.displayValue,
    required this.createRoute,
    this.contextLabel,
  });

  final AggregationReferenceKind kind;
  final String displayValue;
  final String createRoute;
  final String? contextLabel;

  String get kindLabel => switch (kind) {
        AggregationReferenceKind.gln => 'GLN',
        AggregationReferenceKind.gtin => 'GTIN',
        AggregationReferenceKind.sgtin => 'SGTIN',
        AggregationReferenceKind.sscc => 'SSCC',
      };

  String get createActionLabel => switch (kind) {
        AggregationReferenceKind.gln => 'Create GLN',
        AggregationReferenceKind.gtin => 'Create GTIN',
        AggregationReferenceKind.sgtin => 'Create SGTIN',
        AggregationReferenceKind.sscc => 'Create SSCC',
      };

  int get sortOrder => switch (kind) {
        AggregationReferenceKind.gln => 0,
        AggregationReferenceKind.gtin => 1,
        AggregationReferenceKind.sscc => 2,
        AggregationReferenceKind.sgtin => 3,
      };
}
