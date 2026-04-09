# Form Validation Integration Guide

This guide explains how to integrate the enhanced validation widgets into EPCIS event forms.

## Available Validation Components

### 1. ValidatedTextField

A text field with built-in validation display.

```dart
ValidatedTextField(
  controller: _textController,
  decoration: const InputDecoration(
    labelText: 'Field Label',
    hintText: 'Field hint',
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      // Set error in the mixin for field-level tracking
      setFieldError('fieldName', 'Field is required');
      return 'Field is required';
    }
    // Clear error if valid
    setFieldError('fieldName', null);
    return null;
  },
  helpText: 'Example: Some hint text',
  validateOnChange: true,  // Validate as the user types
  validateOnBlur: true,    // Validate when focus is lost
)
```

### 2. ValidatedFormField

A wrapper for any form field (like DropdownButtonFormField) with validation display.

```dart
ValidatedFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      setFieldError('fieldName', 'Field is required');
      return 'Field is required';
    }
    setFieldError('fieldName', null);
    return null;
  },
  helpText: 'Select an option',
  validateOnChange: true,
  validateOnBlur: true,
  formField: DropdownButtonFormField<String>(
    value: _selectedValue,
    decoration: const InputDecoration(
      labelText: 'Dropdown Field',
      border: OutlineInputBorder(),
    ),
    items: _options.map((option) => DropdownMenuItem(
      value: option,
      child: Text(option),
    )).toList(),
    onChanged: (value) {
      setState(() {
        _selectedValue = value;
      });
    },
  ),
)
```

### 3. FieldValidationIndicator

A standalone widget that shows validation state. Supports animation and different severity levels.

```dart
FieldValidationIndicator(
  isValid: _isFieldValid,
  wasValidated: _wasFieldValidated,
  errorMessage: _fieldErrorMessage,
  severity: ValidationSeverity.error,  // or .warning, .info
  animate: true,
)
```

## Integration Steps

### 1. Add the EventFormValidationMixin to your form

```dart
class _MyFormState extends State<MyForm> with EventFormValidationMixin {
  // Form implementation
}
```

### 2. Use the validation mixin methods

```dart
// Get field error
String? errorText = getFieldError('fieldName');

// Set field error
setFieldError('fieldName', 'Error message');
// Clear field error
setFieldError('fieldName', null);

// Clear all errors
clearFieldErrors();
```

### 3. Connect validation to form submission

```dart
void _validateAndSubmit() {
  if (_formKey.currentState!.validate()) {
    // All fields are valid
    // Process form submission
  } else {
    // Show error message
  }
}
```

## Best Practices

1. **Consistent field names**: Use the same field name in all validation calls
2. **Progressive validation**: Use `validateOnChange` for immediate feedback, or `validateOnBlur` for less intrusive validation
3. **Helpful messages**: Provide clear error messages and helpful examples
4. **Validation levels**: Use appropriate severity levels for different types of validation issues

## Example Implementation

See the following files for complete examples:
- `transaction_event_validation_demo.dart`: Shows a simple form with integrated validation
- `validation_rule_demo_screen.dart`: Shows more advanced validation options
