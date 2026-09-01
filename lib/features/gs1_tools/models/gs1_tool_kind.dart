enum Gs1ToolKind {
  
  convert,
  validate,
  build,
  barcode,
  aiElement,
  ndc,
  lookup,
  
  serializeConvert,
  serializeExport,
  serializeImport,
}

extension Gs1ToolKindX on Gs1ToolKind {
  String get id => switch (this) {
    Gs1ToolKind.convert => 'convert',
    Gs1ToolKind.validate => 'validate',
    Gs1ToolKind.build => 'build',
    Gs1ToolKind.barcode => 'barcode',
    Gs1ToolKind.aiElement => 'ai',
    Gs1ToolKind.ndc => 'ndc',
    Gs1ToolKind.lookup => 'lookup',
    Gs1ToolKind.serializeConvert => 'serialize-convert',
    Gs1ToolKind.serializeExport => 'serialize-export',
    Gs1ToolKind.serializeImport => 'serialize-import',
  };

  String get label => switch (this) {
    Gs1ToolKind.convert => 'Convert',
    Gs1ToolKind.validate => 'Validate',
    Gs1ToolKind.build => 'Build',
    Gs1ToolKind.barcode => 'Barcode',
    Gs1ToolKind.aiElement => 'Application Identifier Parser',
    Gs1ToolKind.ndc => 'NDC ↔ GTIN',
    Gs1ToolKind.lookup => 'GS1 Lookup',
    Gs1ToolKind.serializeConvert => 'Format Conversion',
    Gs1ToolKind.serializeExport => 'Export',
    Gs1ToolKind.serializeImport => 'Import',
  };

  static const toolKinds = [
    Gs1ToolKind.convert,
    Gs1ToolKind.validate,
    Gs1ToolKind.build,
    Gs1ToolKind.barcode,
    Gs1ToolKind.aiElement,
    Gs1ToolKind.ndc,
    
  ];

  static const serializationKinds = [Gs1ToolKind.serializeConvert];

  static Gs1ToolKind fromId(String? id, {void Function(String mode)? onMode}) {
    switch ((id ?? '').trim().toLowerCase()) {
      
      case 'convert':
        return Gs1ToolKind.convert;
      case 'epc':
      case 'epc-conversion':
      case 'conversion':
        onMode?.call('epc');
        return Gs1ToolKind.convert;
      case 'digital-link':
      case 'digitallink':
      case 'dl':
        onMode?.call('digital-link');
        return Gs1ToolKind.convert;
      case 'element':
      case 'element-string':
        onMode?.call('convert');
        return Gs1ToolKind.aiElement;

      case 'validate':
      case 'validator':
      case 'validation':
      case 'validation-demo':
      case 'identifier':
        onMode?.call('single');
        return Gs1ToolKind.validate;
      case 'check-digit':
      case 'checkdigit':
        onMode?.call('check-digit');
        return Gs1ToolKind.validate;
      case 'batch':
      case 'tests':
      case 'gs1-validation':
        onMode?.call('batch');
        return Gs1ToolKind.validate;
      case 'decomposer':
      case 'anatomy':
        onMode?.call('anatomy');
        return Gs1ToolKind.validate;

      case 'build':
        return Gs1ToolKind.build;
      case 'sscc-builder':
        onMode?.call('sscc');
        return Gs1ToolKind.build;
      case 'gtin-packaging':
      case 'packaging':
        onMode?.call('gtin');
        return Gs1ToolKind.build;

      case 'barcode':
      case 'generate':
        return Gs1ToolKind.barcode;
      case 'verify':
        onMode?.call('verify');
        return Gs1ToolKind.barcode;
      case 'pharma-datamatrix':
      case 'pharma':
        onMode?.call('pharma');
        return Gs1ToolKind.barcode;

      case 'ai':
      case 'ai-parser':
        return Gs1ToolKind.aiElement;
      case 'ai-table':
      case 'cheat-sheet':
        onMode?.call('table');
        return Gs1ToolKind.aiElement;

      case 'ndc':
      case 'ndc-gtin':
        return Gs1ToolKind.ndc;
      case 'lookup':
      case 'gepir':
      case 'verified':
        return Gs1ToolKind.lookup;

      case 'serialize-convert':
      case 'serialize':
      case 'serialization':
      case 'format-conversion':
        return Gs1ToolKind.serializeConvert;
      case 'serialize-validate':
      case 'schema-validation':
        onMode?.call('validate');
        return Gs1ToolKind.serializeConvert;
      case 'serialize-export':
      case 'export':
      case 'serialize-import':
      case 'import':
        
        return Gs1ToolKind.serializeConvert;

      default:
        return Gs1ToolKind.convert;
    }
  }
}