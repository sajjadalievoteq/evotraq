
class EPCISErrorCodes {
  static const String valid = 'VALID';
  
  static const String generalError = 'GENERAL_ERROR';
  
  static const String required = 'REQUIRED_FIELD';
  
  static const String invalidFormat = 'INVALID_FORMAT';
  
  static const String invalidValue = 'INVALID_VALUE';
  
  static const String notFound = 'NOT_FOUND';
  
  static const String referenceNotFound = 'REFERENCE_NOT_FOUND';
  
  static const String invalidDateTime = 'INVALID_DATE_TIME';
  
  static const String invalidGLN = 'INVALID_GLN';
  
  static const String invalidGTIN = 'INVALID_GTIN';
  
  static const String invalidSGTIN = 'INVALID_SGTIN';
  
  static const String invalidSSCC = 'INVALID_SSCC';
  
  static const String businessRuleViolation = 'BUSINESS_RULE_VIOLATION';
  
  static const String invalidAction = 'INVALID_ACTION';
  
  static const String invalidBusinessStep = 'INVALID_BUSINESS_STEP';
  
  static const String invalidDisposition = 'INVALID_DISPOSITION';
  
  static const String missingILMD = 'MISSING_ILMD';
}

enum ValidationSeverity {
  info,
  
  warning,
  
  error,
  
  critical
}

extension ValidationSeverityExtension on ValidationSeverity {
  String get name {
    return toString().split('.').last;
  }
}
