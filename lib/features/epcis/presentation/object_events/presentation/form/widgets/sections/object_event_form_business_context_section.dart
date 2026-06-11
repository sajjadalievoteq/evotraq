import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_cbv_dropdown_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';

class ObjectEventFormBusinessContextSection extends StatelessWidget {
  final String? businessStep;
  final String? disposition;
  final bool isViewOnly;
  final bool isBusinessStepMandatory;
  final bool isDispositionMandatory;
  final ObjectEventFormValidationContext validation;
  final ValueChanged<String?> onBusinessStepChanged;
  final ValueChanged<String?> onDispositionChanged;

  const ObjectEventFormBusinessContextSection({
    super.key,
    required this.businessStep,
    required this.disposition,
    required this.isViewOnly,
    required this.isBusinessStepMandatory,
    required this.isDispositionMandatory,
    required this.validation,
    required this.onBusinessStepChanged,
    required this.onDispositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Business Context (required)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ObjectEventCbvDropdownField(
            fieldType: ObjectEventCbvFieldType.businessStep,
            fieldName: 'businessStep',
            label: 'Business Step',
            value: businessStep,
            standardValues: objectEventStandardBusinessSteps,
            isMandatory: isBusinessStepMandatory,
            isViewOnly: isViewOnly,
            validation: validation,
            onChanged: onBusinessStepChanged,
          ),
          const SizedBox(height: 8.0),
          ObjectEventCbvDropdownField(
            fieldType: ObjectEventCbvFieldType.disposition,
            fieldName: 'disposition',
            label: 'Disposition',
            value: disposition,
            standardValues: objectEventStandardDispositions,
            isMandatory: isDispositionMandatory,
            isViewOnly: isViewOnly,
            validation: validation,
            onChanged: onDispositionChanged,
          ),
        ],
      ),
    );
  }
}
