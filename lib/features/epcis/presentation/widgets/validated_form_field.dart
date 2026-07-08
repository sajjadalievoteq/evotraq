import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/field_validation_indicator.dart';

class ValidatedFormField extends StatefulWidget {
  final Widget formField;

  final String? Function(String?) validator;

  final FocusNode? focusNode;

  final String? helpText;

  final bool validateOnChange;

  final bool validateOnBlur;

  final bool initiallyValidated;

  final bool animate;

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

class ValidationNotification extends Notification {
  final String value;

  ValidationNotification(this.value);
}
