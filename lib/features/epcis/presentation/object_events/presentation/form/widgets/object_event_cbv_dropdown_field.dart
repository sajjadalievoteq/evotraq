import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_field_decoration.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_read_only_field.dart';

enum ObjectEventCbvFieldType { businessStep, disposition }

/// CBV dropdown with custom-value dialog for business step and disposition.
class ObjectEventCbvDropdownField extends StatelessWidget {
  final ObjectEventCbvFieldType fieldType;
  final String fieldName;
  final String label;
  final String? value;
  final List<String> standardValues;
  final bool isMandatory;
  final bool isViewOnly;
  final ObjectEventFormValidationContext validation;
  final ValueChanged<String?> onChanged;

  const ObjectEventCbvDropdownField({
    super.key,
    required this.fieldType,
    required this.fieldName,
    required this.label,
    required this.value,
    required this.standardValues,
    required this.isMandatory,
    required this.isViewOnly,
    required this.validation,
    required this.onChanged,
  });

  String get _cbvPrefix => fieldType == ObjectEventCbvFieldType.businessStep
      ? 'urn:epcglobal:cbv:bizstep:'
      : 'urn:epcglobal:cbv:disp:';

  String get _customDialogTitle => fieldType == ObjectEventCbvFieldType.businessStep
      ? 'Custom Business Step'
      : 'Custom Disposition';

  String get _customHint => '$_cbvPrefix${fieldType == ObjectEventCbvFieldType.businessStep ? 'custom_step' : 'custom_disposition'}';

  String? Function(String?) get _validator =>
      fieldType == ObjectEventCbvFieldType.businessStep
      ? ObjectEventFormValidators.validateBusinessStepCbv
      : ObjectEventFormValidators.validateDispositionCbv;

  String? Function(String) get _customValidator =>
      fieldType == ObjectEventCbvFieldType.businessStep
      ? ObjectEventFormValidators.validateCustomBusinessStep
      : ObjectEventFormValidators.validateCustomDisposition;

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String customValue = '';
        return AlertDialog(
          title: Text(_customDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter a custom ${label.toLowerCase()} following GS1 CBV format:',
              ),
              const SizedBox(height: 8),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: _customHint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => customValue = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (customValue.isNotEmpty) {
                  onChanged(customValue);
                  validation.validateField(
                    fieldName,
                    customValue,
                    _customValidator,
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isViewOnly) {
      return ObjectEventFormReadOnlyText(label: label, value: value);
    }

    return DropdownButtonFormField<String>(
      value: value,
      decoration: ObjectEventFormFieldDecoration.getFieldDecoration(
        fieldName: fieldName,
        label: label,
        hintText: 'Select a ${label.toLowerCase()}',
        isMandatory: isMandatory,
        validation: validation,
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Custom...')),
        ...standardValues
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item.split(':').last),
              ),
            )
            .toList(),
      ],
      validator: (v) {
        final error = _validator(v);
        validation.setFieldError(fieldName, error);
        return error;
      },
      onChanged: (selected) {
        if (selected == null) {
          _showCustomDialog(context);
        } else {
          onChanged(selected);
          validation.markFieldAsValid(fieldName);
        }
      },
    );
  }
}
