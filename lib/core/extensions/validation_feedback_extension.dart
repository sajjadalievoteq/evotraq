import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/features/epcis/widgets/validation_error_widget.dart';

extension ValidationFeedbackX on BuildContext {
  void showValidationErrors(
    List<dynamic> errors, {
    String? title,
  }) {
    showDialog<void>(
      context: this,
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

  void showValidationErrorSnackbar(List<dynamic> errors) {
    showSnackBar(
      SnackBar(
        content: Text('${errors.length} validation errors found'),
        backgroundColor: AppColorMapper.errorColor(this),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => showValidationErrors(errors),
        ),
      ),
    );
  }
}
