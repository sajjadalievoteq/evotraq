import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';  
import 'package:traqtrace_app/features/epcis/widgets/validation_error_widget.dart';

/// Show validation errors dialog
  void showValidationErrors(BuildContext context, List<dynamic> errors, {String? title}) {
    // Format errors for proper display
    final formattedErrors = errors.map((error) {
      if (error is String) {
        return error;
      } else {
        return error.toString();
      }
    }).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Validation Errors'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ...formattedErrors.map((error) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(error, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

/// Mixin that adds validation capabilities to EPCIS event form screens
mixin EventFormValidationMixin<T extends StatefulWidget> on State<T> {
  /// Field validation state
  final Map<String, String?> _fieldValidationErrors = {};
  
  /// Get the validation provider from context
  ValidationCubit get validationProvider => context.read<ValidationCubit>();
  
  /// Get field error by name
  String? getFieldError(String fieldName) => _fieldValidationErrors[fieldName];
  
  /// Set field error
  void setFieldError(String fieldName, String? error) {
    if (_fieldValidationErrors[fieldName] != error) {
      setState(() {
        _fieldValidationErrors[fieldName] = error;
      });
    }
  }
  
  /// Clear all field errors
  void clearFieldErrors() {
    setState(() {
      _fieldValidationErrors.clear();
    });
  }
  
  /// Validate a field with a specific validation function
  bool validateField(String fieldName, String value, String? Function(String) validator) {
    final error = validator(value);
    setFieldError(fieldName, error);
    return error == null;
  }
    
  /// Get validation status for a field
  ValidationStatus getFieldValidationStatus(String fieldName) {
    final error = _fieldValidationErrors[fieldName];
    if (error != null) {
      return ValidationStatus.invalid;
    } else if (_fieldValidationErrors.containsKey(fieldName) && error == null) {
      return ValidationStatus.valid;
    } else {
      return ValidationStatus.notValidated;
    }
  }
  
  /// Check if a field has been validated (either valid or invalid)
  bool hasFieldBeenValidated(String fieldName) {
    return _fieldValidationErrors.containsKey(fieldName);
  }
  
  /// Mark field as validated without error
  void markFieldAsValid(String fieldName) {
    setFieldError(fieldName, null);
  }
  
  /// Validate a field with progressive feedback
  bool validateFieldWithFeedback(
    String fieldName, 
    String value,
    String? Function(String) validator,
    {bool updateState = true}
  ) {
    final error = validator(value);
    
    if (updateState) {
      setFieldError(fieldName, error);
    }
    
    return error == null;
  }
  
  /// Process validation results and map them to fields with detailed feedback
  void processValidationResult(
    Map<String, dynamic>? result, 
    Map<String, String> fieldMappings
  ) {
    if (result == null || result['valid'] == true) {
      return;
    }
    
    final errors = result.containsKey('validationErrors')
      ? result['validationErrors'] as List<dynamic>? ?? []
      : [];
      
    mapValidationErrorsToFields(errors, fieldMappings);
  }
  
  /// Map validation errors to fields with custom field mappings
  void mapValidationErrorsToFields(
    List<dynamic> errors,
    Map<String, String> fieldMappings
  ) {
    // Clear existing errors first
    clearFieldErrors();
    
    // Map errors to fields based on their field path or description
    for (final error in errors) {
      if (error is Map<String, dynamic>) {
        // If the error has a field path, use it
        if (error.containsKey('field')) {
          final fieldName = _mapBackendFieldToFormField(
            error['field'].toString(), 
            fieldMappings
          );
          setFieldError(fieldName, error['message'].toString());
        } else if (error.containsKey('message')) {
          // Try to extract field name from message
          final message = error['message'].toString();
          _tryExtractFieldFromMessage(message, fieldMappings);
        }
      } else if (error is String) {
        // Try to extract field name from string message
        _tryExtractFieldFromMessage(error, fieldMappings);
      }
    }
  }
  
  /// Try to extract field name from error message
  void _tryExtractFieldFromMessage(
    String message,
    Map<String, String> fieldMappings
  ) {
    // Common patterns in validation messages
    final patterns = [
      RegExp(r'"([^"]+)"'),  // Text in double quotes
      RegExp(r"'([^']+)'"), // Text in single quotes
      RegExp(r'field ([^ ]+)'), // "field" followed by name
      RegExp(r'property ([^ ]+)'), // "property" followed by name
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null && match.groupCount >= 1) {
        final backendField = match.group(1)!.toLowerCase();
        final fieldName = _mapBackendFieldToFormField(backendField, fieldMappings);
        
        setFieldError(fieldName, message);
        return;
      }
    }
    
    // If no field could be identified, store as general error
    setFieldError('_general', message);
  }
  
  /// Map backend field names to form field names
  String _mapBackendFieldToFormField(
    String backendField,
    Map<String, String> fieldMappings
  ) {
    // Remove any array indexes or path separators
    final simplifiedField = backendField
      .replaceAll(RegExp(r'\[\d+\]'), '')
      .split('.')
      .last
      .toLowerCase();
      
    // Check if we have a mapping for this field
    return fieldMappings[simplifiedField] ?? simplifiedField;
  }

  /// Show validation errors in a dialog
  void showValidationErrors(BuildContext context, List<dynamic> errors, {String? title}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Validation Errors'),
        content: SingleChildScrollView(
          child: ValidationErrorWidget(
            validationErrors: errors,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  /// Show validation errors in a snackbar
  void showValidationErrorSnackbar(BuildContext context, List<dynamic> errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${errors.length} validation errors found'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => showValidationErrors(context, errors),
        ),
      ),
    );
  }
  
  /// Display validation errors inline
  Widget buildValidationErrorsWidget(List<dynamic> errors, {VoidCallback? onDismiss}) {
    return ValidationErrorWidget(
      validationErrors: errors,
      onDismiss: onDismiss,
    );
  }
}

/// Validation status for form fields
enum ValidationStatus {
  /// Field has not been validated yet
  notValidated,
  
  /// Field is valid
  valid,
  
  /// Field is invalid
  invalid
}

/// Extension methods for ValidationStatus
extension ValidationStatusExtension on ValidationStatus {
  /// Whether this status represents validity
  bool get isValid => this == ValidationStatus.valid;
  
  /// Whether this status represents invalidity
  bool get isInvalid => this == ValidationStatus.invalid;
  
  /// Whether this status represents that validation has been attempted
  bool get wasValidated => this != ValidationStatus.notValidated;
}
