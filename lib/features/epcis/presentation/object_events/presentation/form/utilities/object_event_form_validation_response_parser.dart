/// Extracts human-readable error messages from a validation API response.
class ObjectEventFormValidationResponseParser {
  ObjectEventFormValidationResponseParser._();

  static List<String> extractErrorMessages(Map<String, dynamic>? response) {
    final List<String> errorMessages = [];

    if (response == null) return errorMessages;

    print('Validation response details: $response');

    if (response.containsKey('errors')) {
      final errors = response['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        for (final category in [
          ('schema', 'Schema'),
          ('businessRule', 'Business Rule'),
          ('referenceData', 'Reference Data'),
          ('other', 'Other'),
        ]) {
          if (errors.containsKey(category.$1)) {
            final list = errors[category.$1] as List<dynamic>? ?? [];
            for (final error in list) {
              errorMessages.add('${category.$2}: $error');
            }
          }
        }
      }
    } else if (response.containsKey('validationErrors')) {
      final validationErrors =
          response['validationErrors'] as List<dynamic>? ?? [];
      for (final error in validationErrors) {
        errorMessages.add(error.toString());
      }
    } else if (response.containsKey('error')) {
      errorMessages.add(response['error'].toString());
    } else if (response.containsKey('message')) {
      errorMessages.add(response['message'].toString());
    }

    if (response.containsKey('status') && response.containsKey('message')) {
      final status = response['status'];
      final message = response['message'];
      if (status == 409) {
        errorMessages.add('HTTP $status: $message');
        if (message.toString().contains('Enhanced validation failed')) {
          errorMessages.add(
            'Common causes: Missing required fields, invalid GLN/EPC formats, or schema validation errors',
          );
          errorMessages.add(
            'Please check that all required fields are filled and properly formatted',
          );
        }
      }
    }

    if (errorMessages.isEmpty) {
      response.forEach((key, value) {
        if (key.toLowerCase().contains('error') ||
            key.toLowerCase().contains('message')) {
          errorMessages.add('$key: $value');
        }
      });
    }

    return errorMessages;
  }
}
