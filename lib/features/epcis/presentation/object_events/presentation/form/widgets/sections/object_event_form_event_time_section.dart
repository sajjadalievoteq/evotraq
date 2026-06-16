import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_field_decoration.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';

class ObjectEventFormEventTimeSection extends StatelessWidget {
  final DateTime eventTime;
  final String eventTimeZone;
  final bool isViewOnly;
  final bool isTimeZoneMandatory;
  final ObjectEventFormValidationContext validation;
  final VoidCallback onSelectEventTime;
  final ValueChanged<String> onTimeZoneChanged;

  const ObjectEventFormEventTimeSection({
    super.key,
    required this.eventTime,
    required this.eventTimeZone,
    required this.isViewOnly,
    required this.isTimeZoneMandatory,
    required this.validation,
    required this.onSelectEventTime,
    required this.onTimeZoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Event Time',
      showTitleRequiredIndicator: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Date & Time: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}')),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: isViewOnly ? null : onSelectEventTime,
              ),
            ],
          ),
          TextFormField(
            initialValue: eventTimeZone,
            decoration: ObjectEventFormFieldDecoration.getFieldDecoration(
              context: context,
              fieldName: 'eventTimeZone',
              label: 'Time Zone',
              hintText: 'e.g. +01:00',
              isMandatory: isTimeZoneMandatory,
              validation: validation,
            ),
            validator: (value) {
              final error = ObjectEventFormValidators.validateTimeZone(value);
              validation.setFieldError('eventTimeZone', error);
              return error;
            },
            onChanged: isViewOnly
                ? null
                : (value) {
                    onTimeZoneChanged(value);
                    validation.validateField(
                      'eventTimeZone',
                      value,
                      ObjectEventFormValidators.validateTimeZone,
                    );
                  },
            readOnly: isViewOnly,
          ),
        ],
      ),
    );
  }
}
