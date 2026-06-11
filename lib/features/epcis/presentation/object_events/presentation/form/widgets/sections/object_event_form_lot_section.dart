import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_field_decoration.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_read_only_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';

class ObjectEventFormLotSection extends StatelessWidget {
  final String? lotNumber;
  final String? action;
  final bool isViewOnly;
  final bool isMandatory;
  final ObjectEventFormValidationContext validation;
  final ValueChanged<String?> onChanged;

  const ObjectEventFormLotSection({
    super.key,
    required this.lotNumber,
    required this.action,
    required this.isViewOnly,
    required this.isMandatory,
    required this.validation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Lot/Batch Information',
      child: isViewOnly
          ? ObjectEventFormReadOnlyText(
              label: 'Lot Number',
              value: lotNumber ?? 'Not provided',
            )
          : TextFormField(
              initialValue: lotNumber,
              decoration: ObjectEventFormFieldDecoration.getFieldDecoration(
                fieldName: 'lotNumber',
                label: 'Lot Number',
                hintText:
                    'Enter lot/batch number for pharmaceutical tracking',
                isMandatory: isMandatory,
                validation: validation,
              ),
              validator: (value) {
                final error = ObjectEventFormValidators.validateLotNumber(
                  value,
                  isAddAction: action == 'ADD',
                );
                validation.setFieldError('lotNumber', error);
                return error;
              },
              onChanged: (value) {
                onChanged(value.trim().isEmpty ? null : value.trim());
                validation.validateField(
                  'lotNumber',
                  value,
                  (val) => ObjectEventFormValidators.validateLotNumber(
                    val,
                    isAddAction: action == 'ADD',
                  ),
                );
              },
              readOnly: isViewOnly,
            ),
    );
  }
}
