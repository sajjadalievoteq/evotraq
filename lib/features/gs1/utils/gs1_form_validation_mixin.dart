import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/gs1/models/validation_status.dart';

mixin GS1FormValidationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String?> _fieldValidationErrors = {};

  ValidationCubit get validationProvider => context.read<ValidationCubit>();

  String? getFieldError(String fieldName) => _fieldValidationErrors[fieldName];

  void setFieldError(String fieldName, String? error) {
    if (_fieldValidationErrors[fieldName] != error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _fieldValidationErrors[fieldName] = error;
        });
      });
    }
  }

  void clearFieldErrors() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _fieldValidationErrors.clear();
      });
    });
  }

  void clearFieldError(String fieldName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _fieldValidationErrors.remove(fieldName);
      });
    });
  }

  bool validateField(
    String fieldName,
    String value,
    String? Function(String) validator,
  ) {
    final error = validator(value);
    setFieldError(fieldName, error);
    return error == null;
  }

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

  String? validateGTIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'GTIN Code is required';
    }
    if (!RegExp(r'^\d{8}$|^\d{12,14}$').hasMatch(value)) {
      return 'Invalid GTIN format. Must be 8, 12, 13, or 14 digits.';
    }
    return null;
  }

  String? validateGLN(String? value) {
    if (value == null || value.isEmpty) {
      return 'GLN Code is required';
    }
    if (!RegExp(r'^\d{13}$').hasMatch(value)) {
      return 'Invalid GLN format. Must be exactly 13 digits.';
    }
    return null;
  }

  String? validateSGTIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'SGTIN is required';
    }
    if (Gs1CanonicalIdentifier.isSgtin(value) ||
        RegExp(r'\(01\)\d{14}\(21\)\w+').hasMatch(value)) {
      return null;
    }
    return 'Invalid SGTIN format. Expected https://id.gs1.org/01/…/21/…';
  }

  String? validateSSCC(String? value) {
    if (value == null || value.isEmpty) {
      return 'SSCC is required';
    }
    if (Gs1CanonicalIdentifier.isSscc(value) ||
        RegExp(r'\(00\)\d{18}').hasMatch(value)) {
      return null;
    }
    return 'Invalid SSCC format. Expected https://id.gs1.org/00/…';
  }

  String? validateCompanyPrefix(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company prefix is required';
    }
    if (!RegExp(r'^\d{6,12}$').hasMatch(value)) {
      return 'Invalid company prefix. Must be 6-12 digits.';
    }
    return null;
  }

  String? validateItemReference(String? value) {
    if (value == null || value.isEmpty) {
      return 'Item reference is required';
    }
    if (!RegExp(r'^\d{1,8}$').hasMatch(value)) {
      return 'Invalid item reference. Must be 1-8 digits depending on company prefix length.';
    }
    return null;
  }

  String? validateGS1ApplicationIdentifier(String? value, String ai) {
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }

    switch (ai) {
      case '00':
        if (!RegExp(r'^\d{18}$').hasMatch(value)) {
          return 'Invalid SSCC. Must be exactly 18 digits.';
        }
        break;
      case '01':
        if (!RegExp(r'^\d{14}$').hasMatch(value)) {
          return 'Invalid GTIN. Must be exactly 14 digits.';
        }
        break;
      case '10':
        if (value.length > 20) {
          return 'Batch/Lot number too long. Maximum 20 characters.';
        }
        break;
      case '11':
      case '12':
      case '13':
      case '15':
      case '17':
        if (!RegExp(r'^\d{6}$').hasMatch(value)) {
          return 'Invalid date format. Must be YYMMDD (6 digits).';
        }
        break;
      case '21':
        if (value.length > 20) {
          return 'Serial number too long. Maximum 20 characters.';
        }
        break;
      case '414':
        if (!RegExp(r'^\d{13}$').hasMatch(value)) {
          return 'Invalid GLN. Must be exactly 13 digits.';
        }
        break;
    }

    return null;
  }

  String? validateGS1Barcode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Barcode string is required';
    }

    if (!RegExp(r'\(\d{2,4}\)').hasMatch(value)) {
      return 'Invalid GS1 barcode format. Must contain application identifiers.';
    }

    return null;
  }

  String? validateGS1CheckDigit(
    String? value, {
    bool includesCheckDigit = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Only digits are allowed';
    }

    if (includesCheckDigit) {
      final withoutCheckDigit = value.substring(0, value.length - 1);
      final providedCheckDigit = int.parse(value[value.length - 1]);
      final calculatedCheckDigit = _calculateGS1CheckDigit(withoutCheckDigit);

      if (providedCheckDigit != calculatedCheckDigit) {
        return 'Invalid check digit. Expected: $calculatedCheckDigit';
      }
    }

    return null;
  }

  int _calculateGS1CheckDigit(String digits) {
    return CheckDigitUtils.calculateMod10(digits);
  }

  String? validateEPCURI(String? value) {
    if (value == null || value.isEmpty) {
      return 'EPC URI is required';
    }

    if (Gs1CanonicalIdentifier.isValid(value) ||
        Gs1CanonicalIdentifier.classify(value) != Gs1CanonicalKind.unknown) {
      return null;
    }

    final epcUriPattern = RegExp(
      r'^urn:epc:(id|class|idpat):(sgtin|sscc|sgln|grai|giai|gsrn|gdti|cpi):.+$',
    );
    if (!epcUriPattern.hasMatch(value)) {
      return 'Invalid EPC URI format. Prefer https://id.gs1.org/…';
    }

    return null;
  }

  String? validateGS1Date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Invalid date format. Must be YYMMDD (6 digits).';
    }

    final month = int.parse(value.substring(2, 4));
    final day = int.parse(value.substring(4, 6));

    if (month < 1 || month > 12) {
      return 'Invalid month in date';
    }

    if (day < 1 || day > 31) {
      return 'Invalid day in date';
    }

    if (month == 2 && day > 29) {
      return 'February cannot have more than 29 days';
    }

    if ([4, 6, 9, 11].contains(month) && day > 30) {
      return 'This month cannot have more than 30 days';
    }

    return null;
  }

  String? validateBatchLot(String? value) {
    if (value == null || value.isEmpty) {
      return 'Batch/Lot number is required';
    }

    if (value.length > 20) {
      return 'Batch/Lot number too long. Maximum 20 characters.';
    }

    return null;
  }

  String? validateSerialNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Serial number is required';
    }

    if (value.length > 20) {
      return 'Serial number too long. Maximum 20 characters.';
    }

    return null;
  }

  bool validateAllFields(Map<String, Map<String, dynamic>> fieldValidators) {
    bool isValid = true;

    final Map<String, String?> updatedErrors = {};

    fieldValidators.forEach((fieldName, validatorInfo) {
      final value = validatorInfo['value'] as String?;
      final validator = validatorInfo['validator'] as String? Function(String?);

      final error = validator(value);
      updatedErrors[fieldName] = error;

      if (error != null) {
        isValid = false;
      }
    });

    updatedErrors.forEach((fieldName, error) {
      _fieldValidationErrors[fieldName] = error;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
      });
    });

    return isValid;
  }
}
