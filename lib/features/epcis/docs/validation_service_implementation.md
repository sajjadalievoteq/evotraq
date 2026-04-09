# EPCIS Event Validation Service Implementation and Integration

This document provides guidance on how to implement and integrate the enhanced event validation service in the TraqTrace application.

## Validation Framework Components

### Core Components:

1. **ValidationServiceProvider**: Manages validation requests and responses, with caching support
2. **ValidationRuleProvider**: Manages validation rules, with CRUD operations and persistence
3. **EventFormValidationMixin**: Integrates validation into form screens with field-level error mapping

### UI Components:

1. **FieldValidationIndicator**: Visual indicator for field validation status
2. **ValidatedTextField**: Text input with integrated validation display
3. **ValidatedFormField**: Generic form field wrapper with validation display

### Models:

1. **ValidationRule**: Model for validation rules with severity levels and targeting
2. **ValidationSeverity**: Enum for validation severity levels (info, warning, error)

## Integrating Validation in Forms

### Step 1: Add the EventFormValidationMixin to your form

```dart
class _MyEventFormState extends State<MyEventForm> with EventFormValidationMixin {
  // Form implementation
}
```

### Step 2: Replace regular form fields with validated ones

Replace standard text fields:

```dart
// Before
TextField(
  controller: _controller,
  decoration: InputDecoration(labelText: 'Field Name'),
  onChanged: (value) => setState(() => _fieldValue = value),
)

// After
ValidatedTextField(
  controller: _controller,
  decoration: InputDecoration(labelText: 'Field Name'),
  validator: (value) {
    // Validation logic
    if (value == null || value.isEmpty) {
      setFieldError('fieldName', 'Field is required');
      return 'Field is required';
    }
    setFieldError('fieldName', null);
    return null;
  },
  helpText: 'Helpful example or guidance',
  validateOnChange: true,
  validateOnBlur: true,
)
```

For dropdowns and other complex fields:

```dart
ValidatedFormField(
  validator: (value) {
    // Validation logic with setFieldError calls
    return errorMessage;
  },
  helpText: 'Helpful text',
  validateOnChange: true,
  validateOnBlur: true,
  formField: DropdownButtonFormField<String>(
    // Standard dropdown implementation
  ),
)
```

### Step 3: Use the validation information in form submission

```dart
void _saveEvent() {
  if (_formKey.currentState!.validate()) {
    // All fields are valid, proceed with save
  } else {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fix validation errors')),
    );
  }
}
```

## Managing Validation Rules

### Creating Custom Rules

Use the ValidationRuleManagementScreen to:

1. Create new validation rules
2. Edit existing rules
3. Enable/disable rules
4. Set rule severity levels

### Rule Types

- **Field Rules**: Target specific fields in specific event types
- **Event Rules**: Target entire events of specific types
- **Global Rules**: Apply to all events

## Examples

For complete examples, see:

1. `transaction_event_validation_demo.dart`: Basic form with validation
2. `object_event_form_screen.dart`: Complex form with field-level validation
3. `validation_rule_management_screen.dart`: UI for managing rules

## Performance Considerations

- **Use Caching**: The ValidationServiceProvider includes caching to improve performance
- **Progressive Validation**: Consider using validateOnBlur for complex validations
- **Rule Targeting**: Target rules to specific event types for better performance

For more detailed implementation guidance, see `form_validation_integration_guide.md`.
