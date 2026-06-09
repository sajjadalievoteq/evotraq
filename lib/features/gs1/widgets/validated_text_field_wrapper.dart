import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/models/validation_status.dart';

class ValidatedTextFieldWrapper extends StatefulWidget {
  final TextEditingController controller;
  
  final String fieldName;
  
  final InputDecoration decoration;
  
  final String? Function(String?)? validator;
  
  final bool readOnly;
  
  final Function(String?)? onChanged;
  
  final TextInputType? keyboardType;

  final int? maxLength;

  final int maxLines;

  final List<TextInputFormatter>? inputFormatters;
  
  final void Function(String, String?)? setFieldError;
  
  final AutovalidateMode autovalidateMode;

  final FocusNode? focusNode;

  final VoidCallback? onEditingComplete;

  const ValidatedTextFieldWrapper({
    super.key,
    required this.controller,
    required this.fieldName,
    this.decoration = const InputDecoration(),
    this.validator,
    this.readOnly = false,
    this.onChanged,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.setFieldError,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.focusNode,
    this.onEditingComplete,
  });

  @override
  _ValidatedTextFieldWrapperState createState() => _ValidatedTextFieldWrapperState();
}

class _ValidatedTextFieldWrapperState extends State<ValidatedTextFieldWrapper> {
  ValidationStatus _validationStatus = ValidationStatus.notValidated;
  String? _errorText;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.controller.text.isNotEmpty && widget.validator != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        final error = widget.validator!(widget.controller.text);
        
        setState(() {
          _validationStatus = error == null ? ValidationStatus.valid : ValidationStatus.invalid;
          _errorText = error;
        });
        
        if (widget.setFieldError != null) {
          widget.setFieldError!(widget.fieldName, error);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          focusNode: widget.focusNode,
          controller: widget.controller,
          decoration: widget.decoration.copyWith(
            suffixIcon: _buildValidationIcon(widget.decoration.suffixIcon),
            errorText: _validationStatus == ValidationStatus.invalid ? _errorText : null,
          ),
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: widget.autovalidateMode,
          onEditingComplete: widget.onEditingComplete,
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
            
            if (widget.validator != null) {
              final error = widget.validator!(value);
              
              if (widget.setFieldError != null) {
                widget.setFieldError!(widget.fieldName, error);
              }
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                
                setState(() {
                  _validationStatus = error == null ? ValidationStatus.valid : ValidationStatus.invalid;
                  _errorText = error;
                });
              });
            }
          },
          validator: (value) {
            final error = widget.validator != null ? widget.validator!(value) : null;
            
            final newStatus = error == null ? ValidationStatus.valid : ValidationStatus.invalid;
            
            if (_validationStatus != newStatus || _errorText != error) {
              if (widget.setFieldError != null) {
                widget.setFieldError!(widget.fieldName, error);
              }
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _validationStatus = newStatus;
                    _errorText = error;
                  });
                }
              });
            }
            
            return error;
          },
        ),
      ],
    );
  }

  Widget? _buildValidationIcon(Widget? existingIcon) {
    if (_validationStatus == ValidationStatus.notValidated) {
      return existingIcon;
    }

    final Widget validationIcon = _validationStatus == ValidationStatus.valid
      ? const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 18,
        )
      : const Icon(
          Icons.error,
          color: Colors.red,
          size: 18,
        );
    
    final Widget tooltipIcon = Tooltip(
      message: _validationStatus == ValidationStatus.valid 
        ? 'Field is valid' 
        : 'Field has validation errors',
      child: validationIcon,
    );
    
    if (existingIcon == null) {
      return tooltipIcon;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        existingIcon,
        const SizedBox(width: 4),
        tooltipIcon,
      ],
    );
  }
}
