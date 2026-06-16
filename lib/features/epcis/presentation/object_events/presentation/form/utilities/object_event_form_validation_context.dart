class ObjectEventFormValidationContext {
  final String? Function(String fieldName) getFieldError;
  final bool Function(String fieldName) hasFieldBeenValidated;
  final void Function(String fieldName, String? error) setFieldError;
  final void Function(String fieldName) markFieldAsValid;
  final void Function(
    String fieldName,
    String value,
    String? Function(String) validator,
  ) validateField;

  const ObjectEventFormValidationContext({
    required this.getFieldError,
    required this.hasFieldBeenValidated,
    required this.setFieldError,
    required this.markFieldAsValid,
    required this.validateField,
  });
}
