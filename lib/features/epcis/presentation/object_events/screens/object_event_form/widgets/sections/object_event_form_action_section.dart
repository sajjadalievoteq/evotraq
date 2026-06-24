import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_field_decoration.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_read_only_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';

class ObjectEventFormActionSection extends StatelessWidget {
  final String? action;
  final List<String> allowedActions;
  final bool isViewOnly;
  final bool isMandatory;
  final ObjectEventFormValidationContext validation;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onRevalidateForm;

  const ObjectEventFormActionSection({
    super.key,
    required this.action,
    required this.allowedActions,
    required this.isViewOnly,
    required this.isMandatory,
    required this.validation,
    required this.onChanged,
    this.onRevalidateForm,
  });

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Action',
      showTitleRequiredIndicator: isMandatory,
      child: allowedActions.isEmpty
          ? const Text(
              'No actions are available for this item state.',
              style: TextStyle(color: Colors.grey),
            )
          : isViewOnly
              ? ObjectEventFormReadOnlyText(label: 'Action', value: action)
              : DropdownButtonFormField<String>(
                  value: allowedActions.contains(action) ? action : null,
                  decoration: ObjectEventFormFieldDecoration.getFieldDecoration(
                    context: context,
                    fieldName: 'action',
                    label: 'Action',
                    hintText: 'Select an action',
                    isMandatory: isMandatory,
                    validation: validation,
                  ),
                  items: allowedActions
                      .map(
                        (a) => DropdownMenuItem(value: a, child: Text(a)),
                      )
                      .toList(),
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
