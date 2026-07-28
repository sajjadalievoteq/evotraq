enum ValidationSection {
  identifier,
  batch,
}

extension ValidationSectionX on ValidationSection {
  String get id => switch (this) {
        ValidationSection.identifier => 'identifier',
        ValidationSection.batch => 'batch',
      };

  String get label => switch (this) {
        ValidationSection.identifier => 'Identifier / GS1',
        ValidationSection.batch => 'Batch Validation',
      };

  static ValidationSection fromId(String? id) {
    switch ((id ?? '').trim().toLowerCase()) {
      case 'batch':
      case 'tests':
      case 'gs1-validation':
        return ValidationSection.batch;
      // Removed QA sections — redirect aliases to real tools.
      case 'integration':
      case 'rules':
      case 'validation-rules':
      case 'identifier':
      case 'demo':
      case 'validator':
      default:
        return ValidationSection.identifier;
    }
  }
}
