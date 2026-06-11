/// Error codes for EPCIS validation
///
/// This file contains the error code constants used in the EPCIS validation system.
/// These codes are used to identify specific validation errors in the UI and API.

/// EPCIS validation error codes
class EPCISErrorCodes {
  /// No error / valid
  static const String valid = 'VALID';
  
  /// General validation error
  static const String generalError = 'GENERAL_ERROR';
  
  /// Field is required
  static const String required = 'REQUIRED_FIELD';
  
  /// Invalid format
  static const String invalidFormat = 'INVALID_FORMAT';
  
  /// Invalid value
  static const String invalidValue = 'INVALID_VALUE';
  
  /// Entity not found
  static const String notFound = 'NOT_FOUND';
  
  /// Reference not found
  static const String referenceNotFound = 'REFERENCE_NOT_FOUND';
  
  /// Date/time validation error
  static const String invalidDateTime = 'INVALID_DATE_TIME';
  
  /// Invalid GLN
  static const String invalidGLN = 'INVALID_GLN';
  
  /// Invalid GTIN
  static const String invalidGTIN = 'INVALID_GTIN';
  
  /// Invalid SGTIN
  static const String invalidSGTIN = 'INVALID_SGTIN';
  
  /// Invalid SSCC
  static const String invalidSSCC = 'INVALID_SSCC';
  
  /// Business rule violation
  static const String businessRuleViolation = 'BUSINESS_RULE_VIOLATION';
  
  /// Invalid event action
  static const String invalidAction = 'INVALID_ACTION';
  
  /// Invalid business step
  static const String invalidBusinessStep = 'INVALID_BUSINESS_STEP';
  
  /// Invalid disposition
  static const String invalidDisposition = 'INVALID_DISPOSITION';
  
  /// Missing ILMD for ADD event
  static const String missingILMD = 'MISSING_ILMD';
}

/// Validation severity levels (matches with RuleSeverity but in a separate enum for API consistency)
enum ValidationSeverity {
  /// Information only, does not affect validation result
  info,
  
  /// Warning level, validation passes with warnings
  warning,
  
  /// Error level, validation fails
  error,
  
  /// Critical error, validation fails and indicates high importance
  critical
}

/// Extension methods for ValidationSeverity
extension ValidationSeverityExtension on ValidationSeverity {
  /// Convert to string representation
  String get name {
    return toString().split('.').last;
  }
}
