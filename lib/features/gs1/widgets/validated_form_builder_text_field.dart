import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:traqtrace_app/features/gs1/models/validation_status.dart';

/// A FormBuilder text field with built-in progressive validation display.
/// 
/// This widget extends the standard FormBuilderTextField with real-time validation feedback
/// including visual indicators (icons) for valid/invalid states. It is designed specifically
/// for use with Flutter FormBuilder while providing the same validation experience as 
/// ValidatedTextField.
/// 
/// Use this component for all text input fields that require validation in FormBuilder-based forms,
/// such as the GLN detail screen.
class ValidatedFormBuilderTextField extends StatefulWidget {
  /// Field name used for the FormBuilder (required for form state management)
  final String name;
  
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
  
  /// Initial field value
  final String? initialValue;
  
  /// When to automatically validate the field
  final AutovalidateMode autovalidateMode;
  
  /// The function to call with the field name and error message.
  /// This is typically the setFieldError method from GS1FormValidationMixin.
  final void Function(String, String?)? setFieldError;

  /// Constructor
  const ValidatedFormBuilderTextField({
    Key? key,
    required this.name,
    this.decoration = const InputDecoration(),
    this.validator,
    this.readOnly = false,
    this.onChanged,
    this.keyboardType,
    this.initialValue,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.setFieldError,
  }) : super(key: key);

  @override
  _ValidatedFormBuilderTextFieldState createState() => _ValidatedFormBuilderTextFieldState();
}

class _ValidatedFormBuilderTextFieldState extends State<ValidatedFormBuilderTextField> {
  ValidationStatus _validationStatus = ValidationStatus.notValidated;
  
  @override
  void initState() {
    super.initState();
    
    // If we have an initial value and a validator, perform initial validation
    // after the widget is built (in the next frame)
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty && widget.validator != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        final error = widget.validator!(widget.initialValue);
        
        // Update validation status based on initial validation
        setState(() {
          _validationStatus = error == null ? ValidationStatus.valid : ValidationStatus.invalid;
        });
        
        // Also notify the form via the callback if provided
        if (widget.setFieldError != null) {
          widget.setFieldError!(widget.name, error);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access validation provider if needed for future features
    // Provider.of<ValidationServiceProvider>(context, listen: false);

    return FormBuilderTextField(
      name: widget.name,
      initialValue: widget.initialValue,
      decoration: widget.decoration.copyWith(
        suffixIcon: _buildValidationIcon(widget.decoration.suffixIcon),
      ),
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      autovalidateMode: widget.autovalidateMode,
      onChanged: (value) {
        // First invoke the user's onChanged handler immediately
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        
        // Then perform validation
        if (widget.validator != null && value != null) {
          final error = widget.validator!(value);
          
          // Update the field error via callback if provided
          // This needs to happen immediately for proper validation flow
          if (widget.setFieldError != null) {
            widget.setFieldError!(widget.name, error);
          }
          
          // Only defer UI updates to prevent setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            
            setState(() {
              _validationStatus = error == null ? ValidationStatus.valid : ValidationStatus.invalid;
            });
          });
        }
      },
      validator: (value) {
        // Store the validation result but don't update state here
        // as validator can be called during build
        final error = widget.validator != null ? widget.validator!(value?.toString()) : null;
        
        // Update the validation status in our internal state tracking
        // This ensures that form-level validation works correctly
        final newStatus = error == null ? ValidationStatus.valid : ValidationStatus.invalid;
        if (_validationStatus != newStatus) {
          // We need this error value for form validation, so set it directly
          if (widget.setFieldError != null) {
            widget.setFieldError!(widget.name, error);
          }
          
          // Defer UI updates only
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _validationStatus = newStatus;
              });
            }
          });
        }
        
        // Return the error to FormBuilder's validation system
        return error;
      },
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
