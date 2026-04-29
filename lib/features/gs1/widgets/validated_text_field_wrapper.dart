import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/models/validation_status.dart';

/// A wrapper for TextFormField that provides real-time validation feedback similar to ValidatedFormBuilderTextField.
/// 
/// This component bridges the gap between regular TextFormField and FormBuilder fields by adding
/// consistent validation indicators and error handling. It's designed to work with the 
/// GS1FormValidationMixin to provide the same validation experience across different form types.
class ValidatedTextFieldWrapper extends StatefulWidget {
  /// The controller for the text field
  final TextEditingController controller;
  
  /// Field name used for validation tracking
  final String fieldName;
  
  /// Decoration for the text field
  final InputDecoration decoration;
  
  /// Validator function that returns an error string or null if valid
  final String? Function(String?)? validator;
  
  /// Whether the field is read only (disables editing)
  final bool readOnly;
  
  /// Field value change callback
  final Function(String?)? onChanged;
  
  /// Text input type (e.g., number, email, etc.)
  final TextInputType? keyboardType;

  /// Optional max length for the field (shows counter when enabled by Flutter).
  final int? maxLength;

  /// Number of visible text lines.
  final int maxLines;

  /// Optional input formatters (e.g., to restrict characters).
  final List<TextInputFormatter>? inputFormatters;
  
  /// The function to call with the field name and error message.
  /// This is typically the setFieldError method from GS1FormValidationMixin.
  final void Function(String, String?)? setFieldError;
  
  /// When to automatically validate the field
  final AutovalidateMode autovalidateMode;

  final FocusNode? focusNode;

  final VoidCallback? onEditingComplete;

  /// Constructor
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
    
    // If we have an initial value and a validator, perform initial validation
    if (widget.controller.text.isNotEmpty && widget.validator != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        final error = widget.validator!(widget.controller.text);
        
        // Update validation status based on initial validation
        setState(() {
          _validationStatus = error == null ? ValidationStatus.valid : ValidationStatus.invalid;
          _errorText = error;
        });
        
        // Also notify the form via the callback if provided
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
            // First invoke the user's onChanged handler immediately
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
            
            // Then perform validation
            if (widget.validator != null) {
              final error = widget.validator!(value);
              
              // Update the field error via callback if provided
              if (widget.setFieldError != null) {
                widget.setFieldError!(widget.fieldName, error);
              }
              
              // Defer UI updates to prevent setState during build
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
            // Run validation but don't update state directly during build
            final error = widget.validator != null ? widget.validator!(value) : null;
            
            // Track the error for our internal state
            final newStatus = error == null ? ValidationStatus.valid : ValidationStatus.invalid;
            
            // If status changed, schedule UI update
            if (_validationStatus != newStatus || _errorText != error) {
              // Notify the form about the error directly
              if (widget.setFieldError != null) {
                widget.setFieldError!(widget.fieldName, error);
              }
              
              // Schedule UI update
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

    // Get the appropriate icon based on validation status
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
    
    // Add a tooltip to provide more context
    final Widget tooltipIcon = Tooltip(
      message: _validationStatus == ValidationStatus.valid 
        ? 'Field is valid' 
        : 'Field has validation errors',
      child: validationIcon,
    );
    
    // If there's no existing icon, just return the validation icon with tooltip
    if (existingIcon == null) {
      return tooltipIcon;
    }
    
    // Otherwise, combine them in a row
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        existingIcon,
        const SizedBox(width: 4), // Add a small spacing between icons
        tooltipIcon,
      ],
    );
  }
}
