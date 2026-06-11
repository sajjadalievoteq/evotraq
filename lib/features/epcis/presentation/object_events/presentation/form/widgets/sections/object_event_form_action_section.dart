import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_field_decoration.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_read_only_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';

class ObjectEventFormActionSection extends StatelessWidget {
  final String? action;
  final bool isViewOnly;
  final bool isMandatory;
  final ObjectEventFormValidationContext validation;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onRevalidateForm;

  const ObjectEventFormActionSection({
    super.key,
    required this.action,
    required this.isViewOnly,
    required this.isMandatory,
    required this.validation,
    required this.onChanged,
    this.onRevalidateForm,
  });

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Action (required)',
      child: isViewOnly
          ? ObjectEventFormReadOnlyText(label: 'Action', value: action)
          : DropdownButtonFormField<String>(
              value: action,
              decoration: ObjectEventFormFieldDecoration.getFieldDecoration(
                fieldName: 'action',
                label: 'Action',
                hintText: 'Select an action',
                isMandatory: isMandatory,
                validation: validation,
              ),
              items: const [
                DropdownMenuItem(value: 'ADD', child: Text('ADD')),
                DropdownMenuItem(value: 'OBSERVE', child: Text('OBSERVE')),
                DropdownMenuItem(value: 'DELETE', child: Text('DELETE')),
              ],
              validator: (value) {
                final error = ObjectEventFormValidators.validateAction(value);
                validation.setFieldError('action', error);
                return error;
              },
              onChanged: (value) {
                onChanged(value);
                validation.markFieldAsValid('action');
                onRevalidateForm?.call();
              },
            ),
    );
  }
}
