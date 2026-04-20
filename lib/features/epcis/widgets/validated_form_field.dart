import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/widgets/field_validation_indicator.dart';

/// A form field wrapper that provides progressive validation feedback
class ValidatedFormField extends StatefulWidget {
  /// The form field to wrap
  final Widget formField;

  /// Validation function
  final String? Function(String?) validator;

  final FocusNode? focusNode;

  /// Optional help text
  final String? helpText;

  /// Whether to validate on change
  final bool validateOnChange;

  /// Whether to validate on focus lost
  final bool validateOnBlur;

  /// Initial validation state
  final bool initiallyValidated;

  /// Whether to animate validation state changes
  final bool animate;

  /// Constructor
  const ValidatedFormField({
    Key? key,
    required this.formField,
    required this.validator,
    this.focusNode,
    this.helpText,
    this.validateOnChange = true,
    this.validateOnBlur = true,
    this.initiallyValidated = false,
    this.animate = true,
  }) : super(key: key);

  @override
  State<ValidatedFormField> createState() => _ValidatedFormFieldState();
}

class _ValidatedFormFieldState extends State<ValidatedFormField> {
  String? _errorMessage;
  bool _wasValidated = false;
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _wasValidated = widget.initiallyValidated;
    if (widget.initiallyValidated) {
      // If we want to validate initially, do it right away
      Future.microtask(() {
        _validate(_currentValue);
      });
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.validateOnBlur) {
      _validate(_currentValue);
    }
  }

  void _validate(String value) {
    final error = widget.validator(value);
    setState(() {
      _errorMessage = error;
      _wasValidated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationListener<ValidationNotification>(
          onNotification: (notification) {
            _currentValue = notification.value;
            if (widget.validateOnChange) {
              _validate(notification.value);
            }
            return true;
          },
          child: widget.formField,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 4.0),
          child: FieldValidationIndicator(
            isValid: _errorMessage == null,
            wasValidated: _wasValidated,
            errorMessage: _errorMessage,
            helpText: widget.helpText,
            animate: widget.animate,
          ),
        ),
      ],
    );
  }
}

/// Notification class for form field value changes
class ValidationNotification extends Notification {
  final String value;

  ValidationNotification(this.value);
}
