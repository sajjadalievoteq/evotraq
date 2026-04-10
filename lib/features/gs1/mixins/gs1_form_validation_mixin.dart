import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/widgets/validation_error_widget.dart';
import 'package:traqtrace_app/features/gs1/models/validation_status.dart';

/// Mixin that adds GS1-specific validation capabilities to form screens.
///
/// This mixin provides:
/// 1. Field-level error state management with setFieldError/getFieldError
/// 2. GS1-specific validation methods for various identifiers (GTIN, GLN, SSCC, etc.)
/// 3. Validation for GS1 application identifiers, barcodes, and check digits
/// 4. A comprehensive validateAllFields method for form validation
///
/// Usage:
/// ```dart
/// class MyGS1ScreenState extends State<MyGS1Screen> with GS1FormValidationMixin<MyGS1Screen> {
///   // Use validation methods and error management functions
///   // e.g., setFieldError('fieldName', validateGTIN('1234567890123'));
/// }
/// ```
mixin GS1FormValidationMixin<T extends StatefulWidget> on State<T> {
  /// Field validation state
  final Map<String, String?> _fieldValidationErrors = {};

  /// Get the validation provider from context
  ValidationCubit get validationProvider => context.read<ValidationCubit>();

  /// Get field error by name
  String? getFieldError(String fieldName) => _fieldValidationErrors[fieldName];

  /// Set field error
  void setFieldError(String fieldName, String? error) {
    // Only update if the error value has changed
    if (_fieldValidationErrors[fieldName] != error) {
      // Use addPostFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if widget is still mounted before updating state
        if (!mounted) return;

        setState(() {
          // If error is null, this means the field is valid, so we should
          // explicitly store null (not remove the key) to indicate validation was performed
          _fieldValidationErrors[fieldName] = error;
        });
      });
    }
  }

  /// Clear all field errors
  void clearFieldErrors() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _fieldValidationErrors.clear();
      });
    });
  }

  /// Clear specific field error
  void clearFieldError(String fieldName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _fieldValidationErrors.remove(fieldName);
      });
    });
  }

  /// Validate a field with a specific validation function
  bool validateField(
    String fieldName,
    String value,
    String? Function(String) validator,
  ) {
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

  /// Validate GTIN code format
  String? validateGTIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'GTIN Code is required';
    }
    if (!RegExp(r'^\d{8}$|^\d{12,14}$').hasMatch(value)) {
      return 'Invalid GTIN format. Must be 8, 12, 13, or 14 digits.';
    }
    return null;
  }

  /// Validate GLN code format
  String? validateGLN(String? value) {
    if (value == null || value.isEmpty) {
      return 'GLN Code is required';
    }
    if (!RegExp(r'^\d{13}$').hasMatch(value)) {
      return 'Invalid GLN format. Must be exactly 13 digits.';
    }
    return null;
  }

  /// Validate SGTIN format
  String? validateSGTIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'SGTIN is required';
    }
    if (!value.startsWith('urn:epc:id:sgtin:') &&
        !RegExp(r'\(01\)\d{14}\(21\)\w+').hasMatch(value)) {
      return 'Invalid SGTIN format';
    }
    return null;
  }

  /// Validate SSCC format
  String? validateSSCC(String? value) {
    if (value == null || value.isEmpty) {
      return 'SSCC is required';
    }
    if (!value.startsWith('urn:epc:id:sscc:') &&
        !RegExp(r'\(00\)\d{18}').hasMatch(value)) {
      return 'Invalid SSCC format';
    }
    return null;
  }

  /// Validate GS1 company prefix
  String? validateCompanyPrefix(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company prefix is required';
    }
    if (!RegExp(r'^\d{6,12}$').hasMatch(value)) {
      return 'Invalid company prefix. Must be 6-12 digits.';
    }
    return null;
  }

  /// Validate item reference
  String? validateItemReference(String? value) {
    if (value == null || value.isEmpty) {
      return 'Item reference is required';
    }
    if (!RegExp(r'^\d{1,8}$').hasMatch(value)) {
      return 'Invalid item reference. Must be 1-8 digits depending on company prefix length.';
    }
    return null;
  }

  /// Validate GS1 application identifier
  String? validateGS1ApplicationIdentifier(String? value, String ai) {
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }

    // Common AIs validation
    switch (ai) {
      case '00': // SSCC
        if (!RegExp(r'^\d{18}$').hasMatch(value)) {
          return 'Invalid SSCC. Must be exactly 18 digits.';
        }
        break;
      case '01': // GTIN
        if (!RegExp(r'^\d{14}$').hasMatch(value)) {
          return 'Invalid GTIN. Must be exactly 14 digits.';
        }
        break;
      case '10': // Batch/Lot Number
        if (value.length > 20) {
          return 'Batch/Lot number too long. Maximum 20 characters.';
        }
        break;
      case '11': // Production Date (YYMMDD)
      case '12': // Due Date (YYMMDD)
      case '13': // Packaging Date (YYMMDD)
      case '15': // Best Before Date (YYMMDD)
      case '17': // Expiration Date (YYMMDD)
        if (!RegExp(r'^\d{6}$').hasMatch(value)) {
          return 'Invalid date format. Must be YYMMDD (6 digits).';
        }
        break;
      case '21': // Serial Number
        if (value.length > 20) {
          return 'Serial number too long. Maximum 20 characters.';
        }
        break;
      case '414': // GLN
        if (!RegExp(r'^\d{13}$').hasMatch(value)) {
          return 'Invalid GLN. Must be exactly 13 digits.';
        }
        break;
    }

    return null;
  }

  /// Validate a GS1 barcode string with embedded AIs
  String? validateGS1Barcode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Barcode string is required';
    }

    // GS1 barcodes use () to wrap Application Identifiers
    if (!RegExp(r'\(\d{2,4}\)').hasMatch(value)) {
      return 'Invalid GS1 barcode format. Must contain application identifiers.';
    }

    return null;
  }

  /// Calculate and validate GS1 check digit for GTIN, GLN, etc.
  String? validateGS1CheckDigit(
    String? value, {
    bool includesCheckDigit = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }

    // Only digits allowed
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Only digits are allowed';
    }

    // Calculate check digit
    if (includesCheckDigit) {
      // Remove check digit for calculation
      final withoutCheckDigit = value.substring(0, value.length - 1);
      final providedCheckDigit = int.parse(value[value.length - 1]);
      final calculatedCheckDigit = _calculateGS1CheckDigit(withoutCheckDigit);

      if (providedCheckDigit != calculatedCheckDigit) {
        return 'Invalid check digit. Expected: $calculatedCheckDigit';
      }
    }

    return null;
  }

  /// Helper method to calculate the GS1 check digit
  int _calculateGS1CheckDigit(String digits) {
    int sum = 0;

    // Step 1: Multiply each digit by 1 or 3 alternating from right to left
    for (int i = 0; i < digits.length; i++) {
      final digit = int.parse(digits[digits.length - 1 - i]);
      sum += (i % 2 == 0) ? digit * 3 : digit;
    }

    // Step 2: Take modulo 10
    final remainder = sum % 10;

    // Step 3: If remainder is 0, check digit is 0, otherwise subtract from 10
    return (remainder == 0) ? 0 : 10 - remainder;
  }

  /// Validates a GS1 EPC URI format (e.g., urn:epc:id:sgtin:...)
  String? validateEPCURI(String? value) {
    if (value == null || value.isEmpty) {
      return 'EPC URI is required';
    }

    final epcUriPattern = RegExp(
      r'^urn:epc:(id|class|idpat):(sgtin|sscc|sgln|grai|giai|gsrn|gdti|cpi):.+$',
    );
    if (!epcUriPattern.hasMatch(value)) {
      return 'Invalid EPC URI format';
    }

    return null;
  }

  /// Validates a date in YYMMDD format (commonly used in GS1 Application Identifiers)
  String? validateGS1Date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Invalid date format. Must be YYMMDD (6 digits).';
    }

    // Extract month and day
    final month = int.parse(value.substring(2, 4));
    final day = int.parse(value.substring(4, 6));

    if (month < 1 || month > 12) {
      return 'Invalid month in date';
    }

    if (day < 1 || day > 31) {
      return 'Invalid day in date';
    }

    // Basic validation for days in month (could be enhanced)
    if (month == 2 && day > 29) {
      return 'February cannot have more than 29 days';
    }

    if ([4, 6, 9, 11].contains(month) && day > 30) {
      return 'This month cannot have more than 30 days';
    }

    return null;
  }

  /// Validates a batch/lot number
  String? validateBatchLot(String? value) {
    if (value == null || value.isEmpty) {
      return 'Batch/Lot number is required';
    }

    if (value.length > 20) {
      return 'Batch/Lot number too long. Maximum 20 characters.';
    }

    return null;
  }

  /// Validates a serial number
  String? validateSerialNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Serial number is required';
    }

    if (value.length > 20) {
      return 'Serial number too long. Maximum 20 characters.';
    }

    return null;
  }

  /// Validates all fields using provided validators map
  /// Returns true if all fields are valid, false otherwise
  // Split the validation and UI updates for proper form submission flow
  bool validateAllFields(Map<String, Map<String, dynamic>> fieldValidators) {
    bool isValid = true;

    // Store the updated validation results to be applied after checking all fields
    final Map<String, String?> updatedErrors = {};

    // Validate each field using its validator
    fieldValidators.forEach((fieldName, validatorInfo) {
      final value = validatorInfo['value'] as String?;
      final validator = validatorInfo['validator'] as String? Function(String?);

      // Run validation but don't update state yet
      final error = validator(value);
      updatedErrors[fieldName] = error;

      // Update overall form validity
      if (error != null) {
        isValid = false;
      }
    });

    // Apply the errors to the _fieldValidationErrors map directly
    // This is needed for synchronous validation results
    updatedErrors.forEach((fieldName, error) {
      _fieldValidationErrors[fieldName] = error;
    });

    // Schedule UI update for next frame, but don't let it affect our return value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        // This ensures the UI reflects the validation state, but won't block form submission
      });
    });

    return isValid;
  }
}
