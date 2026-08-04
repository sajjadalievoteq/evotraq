class ValidationErrorMapper {
  const ValidationErrorMapper._();

  static Map<String, String?> mapErrors(
    List<dynamic> errors,
    Map<String, String> fieldMappings,
  ) {
    final mappedErrors = <String, String?>{};

    for (final error in errors) {
      if (error is Map<String, dynamic>) {
        if (error.containsKey('field')) {
          final fieldName = _mapBackendFieldToFormField(
            error['field'].toString(),
            fieldMappings,
          );
          mappedErrors[fieldName] = error['message'].toString();
        } else if (error.containsKey('message')) {
          final message = error['message'].toString();
          _tryExtractFieldFromMessage(message, fieldMappings, mappedErrors);
        }
      } else if (error is String) {
        _tryExtractFieldFromMessage(error, fieldMappings, mappedErrors);
      }
    }

    return mappedErrors;
  }

  static void _tryExtractFieldFromMessage(
    String message,
    Map<String, String> fieldMappings,
    Map<String, String?> mappedErrors,
  ) {
    final patterns = [
      RegExp(r'"([^"]+)"'),
      RegExp(r"'([^']+)'"),
      RegExp(r'field ([^ ]+)'),
      RegExp(r'property ([^ ]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null && match.groupCount >= 1) {
        final backendField = match.group(1)!.toLowerCase();
        final fieldName = _mapBackendFieldToFormField(
          backendField,
          fieldMappings,
        );

        mappedErrors[fieldName] = message;
        return;
      }
    }

    mappedErrors['_general'] = message;
  }

  static String _mapBackendFieldToFormField(
    String backendField,
    Map<String, String> fieldMappings,
  ) {
    final simplifiedField = backendField
        .replaceAll(RegExp(r'\[\d+\]'), '')
        .split('.')
        .last
        .toLowerCase();

    return fieldMappings[simplifiedField] ?? simplifiedField;
  }
}
