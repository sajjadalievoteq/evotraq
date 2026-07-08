import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validation_error_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

void showValidationErrors(
  BuildContext context,
  List<dynamic> errors, {
  String? title,
}) {
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
            ...formattedErrors
                .map(
                  (error) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TraqIcon(AppAssets.iconAlert,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
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

mixin EventFormValidationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String?> _fieldValidationErrors = {};

  ValidationCubit get validationProvider => context.read<ValidationCubit>();

  String? getFieldError(String fieldName) => _fieldValidationErrors[fieldName];

  void setFieldError(String fieldName, String? error) {
    if (_fieldValidationErrors[fieldName] != error) {
      setState(() {
        _fieldValidationErrors[fieldName] = error;
      });
    }
  }

  void clearFieldErrors() {
    setState(() {
      _fieldValidationErrors.clear();
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

  bool hasFieldBeenValidated(String fieldName) {
    return _fieldValidationErrors.containsKey(fieldName);
  }

  void markFieldAsValid(String fieldName) {
    setFieldError(fieldName, null);
  }

  bool validateFieldWithFeedback(
    String fieldName,
    String value,
    String? Function(String) validator, {
    bool updateState = true,
  }) {
    final error = validator(value);

    if (updateState) {
      setFieldError(fieldName, error);
    }

    return error == null;
  }

  void processValidationResult(
    Map<String, dynamic>? result,
    Map<String, String> fieldMappings,
  ) {
    if (result == null || result['valid'] == true) {
      return;
    }

    final errors = result.containsKey('validationErrors')
        ? result['validationErrors'] as List<dynamic>? ?? []
        : [];

    mapValidationErrorsToFields(errors, fieldMappings);
  }

  void mapValidationErrorsToFields(
    List<dynamic> errors,
    Map<String, String> fieldMappings,
  ) {
    clearFieldErrors();

    for (final error in errors) {
      if (error is Map<String, dynamic>) {
        if (error.containsKey('field')) {
          final fieldName = _mapBackendFieldToFormField(
            error['field'].toString(),
            fieldMappings,
          );
          setFieldError(fieldName, error['message'].toString());
        } else if (error.containsKey('message')) {
          final message = error['message'].toString();
          _tryExtractFieldFromMessage(message, fieldMappings);
        }
      } else if (error is String) {
        _tryExtractFieldFromMessage(error, fieldMappings);
      }
    }
  }

  void _tryExtractFieldFromMessage(
    String message,
    Map<String, String> fieldMappings,
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

        setFieldError(fieldName, message);
        return;
      }
    }

    setFieldError('_general', message);
  }

  String _mapBackendFieldToFormField(
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

  void showValidationErrors(
    BuildContext context,
    List<dynamic> errors, {
    String? title,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Validation Errors'),
        content: SingleChildScrollView(
          child: ValidationErrorWidget(validationErrors: errors),
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

  void showValidationErrorSnackbar(BuildContext context, List<dynamic> errors) {
    context.showSnackBar(
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

  Widget buildValidationErrorsWidget(
    List<dynamic> errors, {
    VoidCallback? onDismiss,
  }) {
    return ValidationErrorWidget(
      validationErrors: errors,
      onDismiss: onDismiss,
    );
  }
}

enum ValidationStatus {
  notValidated,

  valid,

  invalid,
}

extension ValidationStatusExtension on ValidationStatus {
  bool get isValid => this == ValidationStatus.valid;

  bool get isInvalid => this == ValidationStatus.invalid;

  bool get wasValidated => this != ValidationStatus.notValidated;
}
