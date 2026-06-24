import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_required_field.dart';

class ObjectEventHelpRequiredFieldsSection extends StatelessWidget {
  const ObjectEventHelpRequiredFieldsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ObjectEventHelpRequiredField(
              title: 'Event Time & Time Zone',
              description:
                  'The date, time, and time zone when the event occurred. Must be specified in ISO 8601 format.',
            ),
            ObjectEventHelpRequiredField(
              title: 'Action',
              description:
                  'Specifies how this event relates to the lifecycle of the objects. Must be one of: ADD, OBSERVE, or DELETE.',
            ),
            ObjectEventHelpRequiredField(
              title: 'Business Step',
              description:
                  'Identifies the specific business step within a business process that this event represents. Standard values are defined in the GS1 Core Business Vocabulary (CBV).',
            ),
            ObjectEventHelpRequiredField(
              title: 'Disposition',
              description:
                  'Indicates the business condition of the objects following the event. Standard values are defined in the GS1 Core Business Vocabulary (CBV).',
            ),
            ObjectEventHelpRequiredField(
              title: 'Business Location GLN',
              description:
                  'The location where the objects are after the event occurred, specified as a Global Location Number (GLN).',
            ),
            ObjectEventHelpRequiredField(
              title: 'EPCs, EPC Classes, or Quantity',
              description:
                  'At least one of these must be present to identify what objects the event pertains to.',
            ),
          ],
        ),
      ),
    );
  }
}
