enum Gs1ToolKind {
  // TOOLS
  checkDigit,
  epcConversion,
  digitalLink,
  aiParser,
  barcode,
  validator,
  // VALIDATION
  identifier,
  batch,
  // EPCIS SERIALIZATION
  serializeConvert,
  serializeValidate,
  serializeExport,
  serializeImport,
}

extension Gs1ToolKindX on Gs1ToolKind {
  String get id => switch (this) {
        Gs1ToolKind.checkDigit => 'check-digit',
        Gs1ToolKind.epcConversion => 'epc',
        Gs1ToolKind.digitalLink => 'digital-link',
        Gs1ToolKind.aiParser => 'ai-parser',
        Gs1ToolKind.barcode => 'barcode',
        Gs1ToolKind.validator => 'validator',
        Gs1ToolKind.identifier => 'identifier',
        Gs1ToolKind.batch => 'batch',
        Gs1ToolKind.serializeConvert => 'serialize-convert',
        Gs1ToolKind.serializeValidate => 'serialize-validate',
        Gs1ToolKind.serializeExport => 'serialize-export',
        Gs1ToolKind.serializeImport => 'serialize-import',
      };

  String get label => switch (this) {
        Gs1ToolKind.checkDigit => 'Check Digit',
        Gs1ToolKind.epcConversion => 'EPC Conversion',
        Gs1ToolKind.digitalLink => 'Digital Link',
        Gs1ToolKind.aiParser => 'AI Parser',
        Gs1ToolKind.barcode => 'Barcode',
        Gs1ToolKind.validator => 'Validator',
        Gs1ToolKind.identifier => 'Identifier / GS1',
        Gs1ToolKind.batch => 'Batch Validation',
        Gs1ToolKind.serializeConvert => 'Format Conversion',
        Gs1ToolKind.serializeValidate => 'Schema Validation',
        Gs1ToolKind.serializeExport => 'Export',
        Gs1ToolKind.serializeImport => 'Import',
      };

  static const toolKinds = [
    Gs1ToolKind.checkDigit,
    Gs1ToolKind.epcConversion,
    Gs1ToolKind.digitalLink,
    Gs1ToolKind.aiParser,
    Gs1ToolKind.barcode,
    Gs1ToolKind.validator,
  ];

  static const validationKinds = [
    Gs1ToolKind.identifier,
    Gs1ToolKind.batch,
  ];

  static const serializationKinds = [
    Gs1ToolKind.serializeConvert,
    Gs1ToolKind.serializeValidate,
    Gs1ToolKind.serializeExport,
    Gs1ToolKind.serializeImport,
  ];

  static Gs1ToolKind fromId(String? id) {
    switch ((id ?? '').trim().toLowerCase()) {
      case 'check-digit':
      case 'checkdigit':
        return Gs1ToolKind.checkDigit;
      case 'epc':
      case 'epc-conversion':
      case 'conversion':
        return Gs1ToolKind.epcConversion;
      case 'digital-link':
      case 'digitallink':
      case 'dl':
        return Gs1ToolKind.digitalLink;
      case 'ai-parser':
      case 'ai':
      case 'element-string':
        return Gs1ToolKind.aiParser;
      case 'barcode':
      case 'generate':
      case 'verify':
        return Gs1ToolKind.barcode;
      case 'validator':
      case 'validation-demo':
        return Gs1ToolKind.validator;
      case 'identifier':
      case 'validation':
        return Gs1ToolKind.identifier;
      case 'batch':
      case 'tests':
      case 'gs1-validation':
        return Gs1ToolKind.batch;
      case 'serialize-convert':
      case 'serialize':
      case 'serialization':
      case 'format-conversion':
        return Gs1ToolKind.serializeConvert;
      case 'serialize-validate':
      case 'schema-validation':
        return Gs1ToolKind.serializeValidate;
      case 'serialize-export':
      case 'export':
        return Gs1ToolKind.serializeExport;
      case 'serialize-import':
      case 'import':
        return Gs1ToolKind.serializeImport;
      default:
        return Gs1ToolKind.checkDigit;
    }
  }
}
