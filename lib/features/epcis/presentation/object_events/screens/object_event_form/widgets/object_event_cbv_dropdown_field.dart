import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_field_decoration.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_read_only_field.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';

enum ObjectEventCbvFieldType { businessStep, disposition }

class ObjectEventCbvDropdownField extends StatelessWidget {
  final ObjectEventCbvFieldType fieldType;
  final String fieldName;
  final String label;
  final String? value;
  final List<String> standardValues;
  final Map<String, String> valueLabels;
  final bool isMandatory;
  final bool isViewOnly;
  final ObjectEventFormValidationContext validation;
  final EPCISVersion epcisVersion;
  final ValueChanged<String?> onChanged;

  const ObjectEventCbvDropdownField({
    super.key,
    required this.fieldType,
    required this.fieldName,
    required this.label,
    required this.value,
    required this.standardValues,
    this.valueLabels = const {},
    required this.isMandatory,
    required this.isViewOnly,
    required this.validation,
    required this.epcisVersion,
    required this.onChanged,
  });

  String? Function(String?) get _validator =>
      fieldType == ObjectEventCbvFieldType.businessStep
          ? (v) => ObjectEventFormValidators.validateBusinessStepCbv(
                v,
                epcisVersion: epcisVersion,
              )
          : ObjectEventFormValidators.validateDispositionCbv;

  @override
  Widget build(BuildContext context) {
    if (isViewOnly) {
      final display = value != null
          ? (valueLabels[value!] ?? CbvVocabularyFormatter.shortName(value!))
          : null;
      return ObjectEventFormReadOnlyText(
        label: label,
        value: display ?? value,
      );
    }

    final dropdownValue =
        (value != null && standardValues.contains(value)) ? value : null;

    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: ObjectEventFormFieldDecoration.getFieldDecoration(
        context: context,
        fieldName: fieldName,
        label: label,
        hintText: 'Select a ${label.toLowerCase()}',
        isMandatory: isMandatory,
        validation: validation,
      ),
      items: standardValues
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                valueLabels[item] ?? CbvVocabularyFormatter.shortName(item),
              ),
            ),
          )
          .toList(),
      validator: (v) {
        final error = _validator(v);
        validation.setFieldError(fieldName, error);
        return error;
      },
      onChanged: (selected) {
        onChanged(selected);
        if (selected != null) {
          validation.markFieldAsValid(fieldName);
        }
      },
    );
  }
}
