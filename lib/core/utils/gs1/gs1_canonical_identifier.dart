import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/utils/gs1_ai_normalizer.dart';
import 'package:traqtrace_app/core/utils/epc_uri_validators.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';


enum Gs1CanonicalKind {
  sgtin,
  sscc,
  lgtin,
  sgln,
  pgln,
  classGtin,
  unknown,
}












abstract final class Gs1CanonicalIdentifier {
  
  static String forStorage(String anyInput) {
    final trimmed = anyInput.trim();
    if (trimmed.isEmpty) return trimmed;
    return normalizeEpcInput(trimmed);
  }

  static bool isValid(String anyInput) => isValidEpcUri(anyInput);

  static String? typeOf(String anyInput) => epcUriType(anyInput);

  
  static Gs1CanonicalKind classify(String anyInput) {
    final trimmed = anyInput.trim();
    if (trimmed.isEmpty) return Gs1CanonicalKind.unknown;

    final lower = trimmed.toLowerCase();
    
    if (lower.startsWith('urn:epc:id:lgtin:') ||
        lower.startsWith('urn:epc:class:lgtin:') ||
        lower.startsWith('urn:epc:idpat:lgtin:')) {
      return Gs1CanonicalKind.lgtin;
    }
    if (lower.startsWith('urn:epc:idpat:sgtin:')) {
      return Gs1CanonicalKind.classGtin;
    }

    final canonical = forStorage(trimmed);
    final converterType = EPCURIConverter.getEPCType(canonical);
    switch (converterType) {
      case 'sgtin':
        return Gs1CanonicalKind.sgtin;
      case 'sscc':
        return Gs1CanonicalKind.sscc;
      case 'lgtin':
        return Gs1CanonicalKind.lgtin;
      case 'sgtin-class':
        return Gs1CanonicalKind.classGtin;
      case 'sgln':
        return Gs1CanonicalKind.sgln;
    }

    final canonicalLower = canonical.toLowerCase();
    if (canonicalLower.startsWith('https://id.gs1.org/01/') &&
        canonicalLower.contains('/10/') &&
        !canonicalLower.contains('/21/')) {
      return Gs1CanonicalKind.lgtin;
    }
    if (RegExp(r'^https://id\.gs1\.org/01/\d{14}$', caseSensitive: false)
        .hasMatch(canonical)) {
      return Gs1CanonicalKind.classGtin;
    }
    if (canonicalLower.startsWith('https://id.gs1.org/414/') ||
        canonicalLower.startsWith('urn:epc:id:sgln:')) {
      return Gs1CanonicalKind.sgln;
    }
    if (canonicalLower.startsWith('https://id.gs1.org/417/')) {
      return Gs1CanonicalKind.pgln;
    }

    final t = typeOf(trimmed);
    return switch (t) {
      'SGTIN' => Gs1CanonicalKind.sgtin,
      'SSCC' => Gs1CanonicalKind.sscc,
      'LGTIN' => Gs1CanonicalKind.lgtin,
      'SGLN' => Gs1CanonicalKind.sgln,
      _ => Gs1CanonicalKind.unknown,
    };
  }

  static bool isSgtin(String anyInput) =>
      classify(anyInput) == Gs1CanonicalKind.sgtin;

  static bool isSscc(String anyInput) =>
      classify(anyInput) == Gs1CanonicalKind.sscc;

  static bool isSerializedInstance(String anyInput) =>
      isSgtin(anyInput) || isSscc(anyInput);

  
  static bool isLgtin(String anyInput) =>
      classify(anyInput) == Gs1CanonicalKind.lgtin || typeOf(anyInput) == 'LGTIN';

  
  static bool isClassGtin(String anyInput) =>
      classify(anyInput) == Gs1CanonicalKind.classGtin;

  
  static bool isLotOrClassLevel(String anyInput) {
    final kind = classify(anyInput);
    return kind == Gs1CanonicalKind.lgtin || kind == Gs1CanonicalKind.classGtin;
  }

  
  static bool areEquivalent(String a, String b) {
    final left = forStorage(a);
    final right = forStorage(b);
    return left == right;
  }

  
  static List<String> forStorageList(List<String>? inputs) {
    if (inputs == null || inputs.isEmpty) return const [];
    return [
      for (final raw in inputs)
        if (raw.trim().isNotEmpty) forStorage(raw),
    ];
  }

  
  static List<String> lookupVariants(String anyInput) {
    final trimmed = anyInput.trim();
    if (trimmed.isEmpty) return const [];
    final variants = <String>{trimmed};
    final canonical = forStorage(trimmed);
    if (canonical.isNotEmpty) variants.add(canonical);
    return variants.toList(growable: false);
  }

  
  static bool isAbsoluteUri(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final lower = value.trim().toLowerCase();
    return lower.startsWith('urn:') ||
        lower.startsWith('http://') ||
        lower.startsWith('https://');
  }

  static String? extractGtin(String anyInput) {
    final fromConverter = Gs1Converter.epcToGTIN(forStorage(anyInput));
    if (fromConverter != null) return fromConverter;

    
    final trimmed = anyInput.trim();
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('urn:epc:class:lgtin:')) {
      final parts = trimmed.substring('urn:epc:class:lgtin:'.length).split('.');
      if (parts.length >= 2) return '${parts[0]}${parts[1]}';
    }
    return null;
  }

  static String? extractSerial(String anyInput) =>
      Gs1Converter.epcToSerial(forStorage(anyInput));

  static String? extractSscc18(String anyInput) {
    final canonical = forStorage(anyInput);
    return Gs1Converter.epcToSscc(canonical) ??
        Gs1Converter.epcToSscc(anyInput.trim());
  }

  
  static String normalizeViaConverter(String input) =>
      EPCURIConverter.normalizeForStorage(input);
}
